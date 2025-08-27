import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

Future<String> getDeviceName() async {
  final deviceInfo = DeviceInfoPlugin();

  if (Platform.isAndroid) {
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.model ?? "Dispositivo Android";
  } else if (Platform.isIOS) {
    final iosInfo = await deviceInfo.iosInfo;
    return iosInfo.name ?? "Dispositivo iOS";
  } else {
    return "Dispositivo desconhecido";
  }
}
