import 'package:equatable/equatable.dart';

//solo datos, nada de lógica de base de datos
class PostLocation extends Equatable {
  final double latitude;
  final double longitude;
  final String city;
  final String department;
  final String country;

  const PostLocation({
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.department,
    required this.country,
  });

  @override
  List<Object?> get props => [latitude, longitude, city, department, country];
}