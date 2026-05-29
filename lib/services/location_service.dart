import 'package:geolocator/geolocator.dart';

import '../core/permissions/location_permission_service.dart';

class LocationPayload {
  const LocationPayload({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
  });

  final double latitude;
  final double longitude;
  final double accuracy;
}

class LocationService {
  LocationService(this._permissionService);

  final LocationPermissionService _permissionService;

  Future<LocationPayload> getCurrentLocation() async {
    final hasPermission = await _permissionService.ensurePermission();
    if (!hasPermission) {
      throw Exception('Ứng dụng cần quyền vị trí để chấm công');
    }

    final enabled = await _permissionService.isServiceEnabled();
    if (!enabled) {
      throw Exception('Vui lòng bật GPS trên thiết bị');
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 20),
      ),
    );

    return LocationPayload(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
    );
  }
}
