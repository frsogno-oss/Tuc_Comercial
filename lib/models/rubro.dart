class Rubro {
  final int id;
  final String nombre;
  final String icono;

  Rubro({
    required this.id,
    required this.nombre,
    required this.icono,
  });

  factory Rubro.fromJson(Map<String, dynamic> json) {
    return Rubro(
      id: int.parse(json['id'].toString()),
      nombre: json['nombre'],
      icono: json['icono'] ?? 'category',
    );
  }

  Object? get id_rubro => null;
}