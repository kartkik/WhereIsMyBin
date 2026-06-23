import 'package:latlong2/latlong.dart';
import 'location_service_stub.dart'
    if (dart.library.html) 'location_service_web.dart';

abstract class LocationService {
  factory LocationService() => getLocationService();
  Future<LatLng?> getCurrentLocation();
}
