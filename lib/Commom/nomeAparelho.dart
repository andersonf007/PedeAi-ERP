import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

Future<String> getDeviceName() async {
  final deviceInfo = DeviceInfoPlugin();

  if (kIsWeb) {
    final webInfo = await deviceInfo.webBrowserInfo;
    return "${webInfo.browserName.name} (${webInfo.userAgent ?? 'Navegador'})";
  } else if (Platform.isAndroid) {
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.model ?? "Dispositivo Android";
  } else if (Platform.isIOS) {
    final iosInfo = await deviceInfo.iosInfo;
    return iosInfo.name ?? "Dispositivo iOS";
  } else {
    return "Dispositivo desconhecido";
  }
}
