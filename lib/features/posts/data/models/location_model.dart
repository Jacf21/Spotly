import 'package:spotly/features/destinations/domain/entities/post_location.dart';

class LocationModel extends PostLocation {
  const LocationModel({
    required super.latitude,
    required super.longitude,
    required super.city,
    required super.department,
    required super.country,
  });

  // Convierte el JSON que viene de Supabase a nuestro modelo
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      city: json['city'] ?? '',
      department: json['department'] ?? '',
      country: json['country'] ?? 'Bolivia',
    );
  }

  // Convierte nuestro modelo a JSON para guardarlo en Supabase
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'department': department,
      'country': country,
    };
  }
}