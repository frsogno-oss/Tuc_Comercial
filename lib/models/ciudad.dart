class Ciudad {
  final int id;
  final String nombre;

  Ciudad({
    required this.id,
    required this.nombre,
  });

  factory Ciudad.fromJson(Map<String, dynamic> json) {
    return Ciudad(
      id: int.parse(json['id'].toString()),
      nombre: json['nombre'],
    );
  }
}