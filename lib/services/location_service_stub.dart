import 'package:latlong2/latlong.dart';
import 'location_service.dart';

class StubLocationService implements LocationService {
  @override
  Future<LatLng?> getCurrentLocation() async {
    // Graceful fallback for non-web environments
    return null;
  }
}

LocationService getLocationService() => StubLocationService();
