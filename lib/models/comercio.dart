class Comercio {
  final int id;
  final int idSubRubro;
  final int idCiudad;
  final String nombre;
  final String? descripcion;
  final String? horarios;
  final String? foto1;
  final String? foto2;
  final String? foto3;
  final String? whatsapp;
  final String? instagram;
  final String? facebook;
  final String? ubicacionUrl;
  final double? latitud;
  final double? longitud;
  final bool esDestacado;
  final bool tieneOferta;

  Comercio({
    required this.id,
    required this.idSubRubro,
    required this.idCiudad,
    required this.nombre,
    this.descripcion,
    this.horarios,
    this.foto1,
    this.foto2,
    this.foto3,
    this.whatsapp,
    this.instagram,
    this.facebook,
    this.ubicacionUrl,
    this.latitud,
    this.longitud,
    required this.esDestacado,
    required this.tieneOferta,
  });

  factory Comercio.fromJson(Map<String, dynamic> json) {
    return Comercio(
      id: int.parse(json['id'].toString()),
      idSubRubro: int.parse(json['id_sub_rubro'].toString()),
      idCiudad: int.parse(json['id_ciudad'].toString()),
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      horarios: json['horarios'],
      foto1: json['foto1'],
      foto2: json['foto2'],
      foto3: json['foto3'],
      whatsapp: json['whatsapp'],
      instagram: json['instagram'],
      facebook: json['facebook'],
      ubicacionUrl: json['ubicacion_url'],
      latitud: json['latitud'] != null ? double.tryParse(json['latitud'].toString()) : null,
      longitud: json['longitud'] != null ? double.tryParse(json['longitud'].toString()) : null,
      // --- CORRECCIÓN FINAL AQUÍ ---
      // Convertimos el valor a texto ANTES de compararlo.
      // Así funcionará con 1 (número) y "1" (texto).
      esDestacado: json['destacado'].toString() == '1',
      tieneOferta: json['oferta'].toString() == '1',
    );
  }
}

