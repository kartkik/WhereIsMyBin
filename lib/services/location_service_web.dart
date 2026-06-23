import 'dart:html' as html;
import 'package:latlong2/latlong.dart';
import 'location_service.dart';

class WebLocationService implements LocationService {
  @override
  Future<LatLng?> getCurrentLocation() async {
    try {
      if (html.window.navigator.geolocation != null) {
        final pos = await html.window.navigator.geolocation.getCurrentPosition(
          enableHighAccuracy: true,
          timeout: const Duration(seconds: 8),
        );
        final coords = pos.coords;
        if (coords != null && coords.latitude != null && coords.longitude != null) {
          return LatLng(coords.latitude!.toDouble(), coords.longitude!.toDouble());
        }
      }
    } catch (e) {
      // User denied location access or browser error
      print('Browser Geolocation error: $e');
    }
    return null;
  }
}

LocationService getLocationService() => WebLocationService();
