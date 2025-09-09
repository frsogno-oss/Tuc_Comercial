class SubRubro {
  final int id;
  final int idRubro;
  final String nombre;

  SubRubro({
    required this.id,
    required this.idRubro,
    required this.nombre,
  });

  factory SubRubro.fromJson(Map<String, dynamic> json) {
    return SubRubro(
      id: int.parse(json['id'].toString()),
      idRubro: int.parse(json['id_rubro'].toString()),
      nombre: json['nombre'],
    );
  }
}