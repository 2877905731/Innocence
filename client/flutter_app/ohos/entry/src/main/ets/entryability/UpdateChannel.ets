import { FlutterEngine, MethodChannel, MethodCall, MethodCallHandler, MethodResult } from '@ohos/flutter_ohos';
import { bundleManager } from '@kit.AbilityKit';

export class UpdateChannel implements MethodCallHandler {
  private channel: MethodChannel;
  constructor(engine: FlutterEngine) {
    this.channel = new MethodChannel(engine.getDartExecutor().getBinaryMessenger(), 'innocence/updates');
    this.channel.setMethodCallHandler(this);
  }
  detach(): void { this.channel.setMethodCallHandler(null); }
  onMethodCall(call: MethodCall, result: MethodResult): void {
    if (call.method === 'info') {
      bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT).then((info: bundleManager.BundleInfo) => {
        const value: Map<string, string | number> = new Map();
        value.set('platform', 'harmonyos'); value.set('arch', 'arm64');
        value.set('version', info.versionName); value.set('build', info.versionCode);
        result.success(value);
      }).catch(() => result.error('update_info_failed', 'Cannot read app version.', null));
    } else if (call.method === 'install') {
      // Developer-device HAPs are not a general distribution/installation entitlement.
      result.error('manual_install_required', 'Use a computer and a valid device profile to update this edition.', null);
    } else { result.notImplemented(); }
  }
}
