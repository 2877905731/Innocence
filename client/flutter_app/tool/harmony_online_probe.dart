import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Separate emulator-only bundle, selected by harmonyos.ps1 -OnlineProbe.
// Uses synthetic bytes and anonymous HTTPS only; never loads user credentials.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(home: Scaffold(body: Center(child: Text('Online native QA')))));
  final receipt = <String, Object>{};
  const vault = MethodChannel('innocence/assistant_vault');
  var step = 'preferences';
  try {
    final prefs = await SharedPreferences.getInstance();
    final plain = Uint8List.fromList(utf8.encode('SYNTHETIC_NATIVE_VAULT_130'));
    final previous = prefs.getString('qa.cipher');
    if (previous != null) {
      final restored = await vault.invokeMethod<Uint8List>('decrypt', base64Decode(previous));
      receipt['restart_decrypt'] = base64Encode(restored!) == base64Encode(plain);
    }
    step = 'encrypt';
    final encrypted = (await vault.invokeMethod<Uint8List>('encrypt', plain))!;
    final again = (await vault.invokeMethod<Uint8List>('encrypt', plain))!;
    final restored = (await vault.invokeMethod<Uint8List>('decrypt', encrypted))!;
    receipt['round_trip'] = base64Encode(restored) == base64Encode(plain);
    receipt['fresh_nonce'] = base64Encode(encrypted) != base64Encode(again);
    final damaged = Uint8List.fromList(encrypted)..[encrypted.length - 1] ^= 1;
    try { await vault.invokeMethod<Uint8List>('decrypt', damaged); receipt['tamper_rejected'] = false; }
    on PlatformException { receipt['tamper_rejected'] = true; }
    final unknown = Uint8List.fromList(encrypted)..[0] ^= 1;
    try { await vault.invokeMethod<Uint8List>('decrypt', unknown); receipt['unknown_version_rejected'] = false; }
    on PlatformException { receipt['unknown_version_rejected'] = true; }
    try { await vault.invokeMethod<Uint8List>('encrypt', Uint8List(0)); receipt['empty_rejected'] = false; }
    on PlatformException { receipt['empty_rejected'] = true; }
    if (!await prefs.setString('qa.cipher', base64Encode(encrypted))) { throw StateError('QA persistence'); }
    final base = Uri.parse(const String.fromEnvironment('INNOCENCE_API_BASE_URL'));
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 20);
    try {
      final health = await (await client.getUrl(base.resolve('/healthz'))).close();
      receipt['trusted_https_health'] = health.statusCode == 200 && jsonDecode(await health.transform(utf8.decoder).join())['status'] == 'UP';
      final anonymous = await (await client.getUrl(base.resolve('/api/app/v1/account/profile'))).close();
      receipt['anonymous_401'] = anonymous.statusCode == 401;
      await anonymous.drain<void>();
    } finally { client.close(force: true); }
    receipt['complete'] = receipt.values.every((value) => value == true);
  } catch (error) {
    receipt['complete'] = false;
    receipt['failed_step'] = step;
    if (error is PlatformException) {
      receipt['platform_code'] = error.code;
      if (error.details is num) receipt['native_code'] = error.details as num;
    }
  }
  final directory = await getApplicationDocumentsDirectory();
  await File('${directory.path}/online-probe-receipt.json').writeAsString(jsonEncode(receipt), flush: true);
  debugPrint('ONLINE_NATIVE_QA ${jsonEncode(receipt)}');
}
