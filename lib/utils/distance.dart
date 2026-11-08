import 'dart:math';

/// Small utility: compute great-circle distance between two lat/lng pairs in km.
double haversineDistanceKm(double lat1, double lon1, double lat2, double lon2) {
  const earthRadiusKm = 6371.0;
  final dLat = _deg2rad(lat2 - lat1);
  final dLon = _deg2rad(lon2 - lon1);
  final a = pow(sin(dLat / 2), 2) + cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) * pow(sin(dLon / 2), 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return earthRadiusKm * c;
}

double _deg2rad(double deg) => deg * (pi / 180.0);
