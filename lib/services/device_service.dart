import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfoPayload {
  const DeviceInfoPayload({
    required this.deviceId,
    required this.deviceName,
    required this.platform,
  });

  final String deviceId;
  final String deviceName;
  final String platform;

  Map<String, dynamic> toJson() => {
        'deviceId': deviceId,
        'deviceName': deviceName,
        'platform': platform,
      };
}

class DeviceService {
  final DeviceInfoPlugin _plugin = DeviceInfoPlugin();

  Future<DeviceInfoPayload> getDeviceInfo() async {
    if (Platform.isAndroid) {
      final info = await _plugin.androidInfo;
      return DeviceInfoPayload(
        deviceId: info.id,
        deviceName: '${info.brand} ${info.model}',
        platform: 'android',
      );
    }
    return const DeviceInfoPayload(
      deviceId: 'unknown',
      deviceName: 'Unknown Device',
      platform: 'android',
    );
  }
}
