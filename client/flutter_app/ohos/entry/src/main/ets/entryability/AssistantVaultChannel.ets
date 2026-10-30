import { FlutterEngine, MethodCall, MethodChannel, MethodCallHandler, MethodResult } from '@ohos/flutter_ohos';
import { huks } from '@kit.UniversalKeystoreKit';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { BusinessError } from '@kit.BasicServicesKit';

// App-scoped, non-exported AES key. Only authenticated ciphertext leaves HUKS.
// Envelope: INV1 | random 12-byte nonce | ciphertext | 16-byte GCM tag.
export class AssistantVaultChannel implements MethodCallHandler {
  private channel: MethodChannel;
  private queue: Promise<void> = Promise.resolve();
  private static readonly ALIAS = 'innocence.assistant.vault.aes256.v1';
  private static readonly MAGIC = new Uint8Array([73, 78, 86, 49]);
  private static readonly MAX_PLAIN = 16384;

  constructor(engine: FlutterEngine) {
    this.channel = new MethodChannel(engine.getDartExecutor().getBinaryMessenger(), 'innocence/assistant_vault');
    this.channel.setMethodCallHandler(this);
  }

  detach(): void { this.channel.setMethodCallHandler(null); }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    if (call.method !== 'encrypt' && call.method !== 'decrypt') {
      result.notImplemented();
      return;
    }
    if (!(call.args instanceof Uint8Array)) {
      result.error('invalid_arguments', 'Expected credential bytes.', null);
      return;
    }
    const data = new Uint8Array(call.args as Uint8Array);
    // Serialize key creation and operations; never replace an existing key.
    this.queue = this.queue.then(async () => {
      try {
        const output = call.method === 'encrypt' ? await this.encrypt(data) : await this.decrypt(data);
        result.success(output);
      } catch (error) {
        // No plaintext fallback and no native error/credential logging.
        const code = (error as BusinessError).code;
        result.error('vault_failed', 'Secure credential storage is unavailable.', typeof code === 'number' ? code : 0);
      }
    });
  }

  private keyProperties(): huks.HuksParam[] {
    return [
      { tag: huks.HuksTag.HUKS_TAG_ALGORITHM, value: huks.HuksKeyAlg.HUKS_ALG_AES },
      { tag: huks.HuksTag.HUKS_TAG_KEY_SIZE, value: huks.HuksKeySize.HUKS_AES_KEY_SIZE_256 },
      { tag: huks.HuksTag.HUKS_TAG_PURPOSE,
        value: huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_ENCRYPT | huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_DECRYPT },
      { tag: huks.HuksTag.HUKS_TAG_PADDING, value: huks.HuksKeyPadding.HUKS_PADDING_NONE },
      { tag: huks.HuksTag.HUKS_TAG_BLOCK_MODE, value: huks.HuksCipherMode.HUKS_MODE_GCM }
    ];
  }

  private operationProperties(nonce: Uint8Array, decrypt: boolean, tag?: Uint8Array): huks.HuksParam[] {
    const properties = this.keyProperties();
    properties[2] = { tag: huks.HuksTag.HUKS_TAG_PURPOSE,
      value: decrypt ? huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_DECRYPT : huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_ENCRYPT };
    properties.push({ tag: huks.HuksTag.HUKS_TAG_NONCE, value: nonce });
    properties.push({ tag: huks.HuksTag.HUKS_TAG_ASSOCIATED_DATA, value: AssistantVaultChannel.MAGIC });
    if (tag) { properties.push({ tag: huks.HuksTag.HUKS_TAG_AE_TAG, value: tag }); }
    return properties;
  }

  private async encrypt(data: Uint8Array): Promise<Uint8Array> {
    if (data.length < 1 || data.length > AssistantVaultChannel.MAX_PLAIN) { throw new Error('Invalid length'); }
    if (!await this.keyExists()) {
      await huks.generateKeyItem(AssistantVaultChannel.ALIAS, { properties: this.keyProperties() });
    }
    const nonce = cryptoFramework.createRandom().generateRandomSync(12).data;
    const encrypted = await this.operate(data, this.operationProperties(nonce, false));
    let ciphertext = encrypted.outData;
    if (!ciphertext) { throw new Error('Missing ciphertext'); }
    // SDK providers may return the tag separately or appended to outData.
    if (ciphertext.length === data.length) {
      const tag = encrypted.properties?.find((item: huks.HuksParam) => item.tag === huks.HuksTag.HUKS_TAG_AE_TAG)?.value;
      if (!(tag instanceof Uint8Array) || tag.length !== 16) { throw new Error('Missing authentication tag'); }
      const combined = new Uint8Array(ciphertext.length + 16);
      combined.set(ciphertext); combined.set(tag, ciphertext.length); ciphertext = combined;
    }
    if (ciphertext.length !== data.length + 16) { throw new Error('Invalid ciphertext'); }
    const envelope = new Uint8Array(16 + ciphertext.length);
    envelope.set(AssistantVaultChannel.MAGIC); envelope.set(nonce, 4); envelope.set(ciphertext, 16);
    return envelope;
  }

  private async decrypt(data: Uint8Array): Promise<Uint8Array> {
    if (data.length < 33 || data.length > AssistantVaultChannel.MAX_PLAIN + 32) { throw new Error('Invalid envelope'); }
    for (let index = 0; index < 4; index++) {
      if (data[index] !== AssistantVaultChannel.MAGIC[index]) { throw new Error('Unknown envelope'); }
    }
    // Missing keys are an error; creating a new key cannot recover old credentials.
    if (!await this.keyExists()) { throw new Error('Missing key'); }
    const ciphertext = data.slice(16, data.length - 16);
    const tag = data.slice(data.length - 16);
    const output = await this.operate(ciphertext, this.operationProperties(data.slice(4, 16), true, tag));
    if (!output.outData || output.outData.length !== ciphertext.length) { throw new Error('Invalid plaintext'); }
    return output.outData;
  }

  private async operate(data: Uint8Array, properties: huks.HuksParam[]): Promise<huks.HuksReturnResult> {
    const session = await huks.initSession(AssistantVaultChannel.ALIAS, { properties: properties });
    try {
      return await huks.finishSession(session.handle, { properties: properties, inData: data });
    } finally {
      // finishSession releases its handle; abort also covers a failed finish.
      try { await huks.abortSession(session.handle, { properties: [] }); } catch (_) { }
    }
  }

  private async keyExists(): Promise<boolean> {
    try {
      return await huks.isKeyItemExist(AssistantVaultChannel.ALIAS, { properties: [] });
    } catch (error) {
      // Some SDK providers reject a missing key instead of resolving false.
      if ((error as BusinessError).code === 12000011) { return false; }
      throw new Error('Secure key lookup failed');
    }
  }
}
