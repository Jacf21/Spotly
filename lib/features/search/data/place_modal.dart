// Este modelo representa un lugar, con su ID, nombre, foto de portada y el ID del departamento al que pertenece
class PlaceModel {
  final int id;
  final String nombre;
  final String? fotoPortada;
  final int? idDepartamento;

  PlaceModel({required this.id, required this.nombre, this.fotoPortada, this.idDepartamento});

  factory PlaceModel.fromMap(Map<String, dynamic> map) {
    return PlaceModel(
      id: map['id_lugar'],
      nombre: map['nombre_lugar'],
      fotoPortada: map['foto_portada_url'],
      idDepartamento: map['id_departamento'],
    );
  }
}