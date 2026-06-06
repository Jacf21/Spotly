// Este modelo representa la ubicación geográfica con sus coordenadas y nombres geográficos,
// y se utiliza para almacenar la información de ubicación en las publicaciones.
class LocationModel {
  final double latitude;
  final double longitude;
  final String city;
  final String department;
  final String country;

  LocationModel({
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.department,
    required this.country,
  });
}
