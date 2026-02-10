import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/ciudad.dart';
import '../models/comercio.dart';
import '../models/rubro.dart';
import '../models/sub_rubro.dart';

class ApiService {
  static const String baseUrl = "https://tuccomercial.uno/";

  Future<List<Ciudad>> getCiudades() async {
    final response = await http.get(Uri.parse('${baseUrl}obtener_ciudades.php'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Ciudad.fromJson(json)).toList();
    } else {
      throw Exception('Falló al cargar las ciudades');
    }
  }

  Future<Map<String, dynamic>> getDatosCompletos(int ciudadId) async {
    final response = await http.get(Uri.parse('${baseUrl}obtener_datos_completos.php?ciudad_id=$ciudadId'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return {
        'rubros': (data['rubros'] as List).map((item) => Rubro.fromJson(item)).toList(),
        'subRubros': (data['sub_rubros'] as List).map((item) => SubRubro.fromJson(item)).toList(),
        'comercios': (data['comercios'] as List).map((item) => Comercio.fromJson(item)).toList(),
      };
    } else {
      throw Exception('Falló al cargar los datos de la ciudad');
    }
  }

  Future<Map<String, dynamic>> getDatosDeContacto() async {
    final response = await http.get(Uri.parse('${baseUrl}obtener_contacto.php'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Falló al cargar los datos de contacto');
    }
  }

  Future<List<Comercio>> buscarComercios(String termino, int ciudadId) async {
    final encodedTermino = Uri.encodeComponent(termino);
    final url = Uri.parse('${baseUrl}buscar.php?termino=$encodedTermino&ciudad_id=$ciudadId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Comercio.fromJson(json)).toList();
    } else {
      throw Exception('Falló la búsqueda de comercios');
    }
  }
// Agregá este método al final de tu clase ApiService existente
  Future<Comercio?> getComercioById(int id) async {
    final response = await http.get(Uri.parse('${baseUrl}obtener_comercio.php?id=$id'));
    if (response.statusCode == 200) {
      final dynamic jsonData = json.decode(response.body);
      if (jsonData != null) {
        return Comercio.fromJson(jsonData);
      }
    }
    return null;
  }
  Future<List<Comercio>> getComerciosCercanos({required double lat, required double lon, int? idSubRubro}) async {
    String url = '${baseUrl}buscar_cercanos.php?lat=$lat&lon=$lon';
    if (idSubRubro != null) {
      url += '&id_sub_rubro=$idSubRubro';
    }
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true) {
        return (jsonResponse['comercios'] as List).map((json) => Comercio.fromJson(json)).toList();
      } else {
        throw Exception(jsonResponse['message'] ?? 'Error desconocido del servidor');
      }
    } else {
      throw Exception('Falló la búsqueda de comercios cercanos');
    }
  }

  Future<Map<String, dynamic>> crearSolicitud(Map<String, String> data, List<XFile> images) async {
    var request = http.MultipartRequest('POST', Uri.parse('${baseUrl}crear_solicitud.php'));
    request.fields.addAll(data);

    for (var image in images) {
      request.files.add(await http.MultipartFile.fromPath('fotos[]', image.path));
    }

    var streamedResponse = await request.send();
    final responseBody = await streamedResponse.stream.bytesToString();

    if (streamedResponse.statusCode == 200) {
      return json.decode(responseBody);
    } else {
      throw Exception('Error del servidor: ${streamedResponse.statusCode}');
    }
  }

  Future getDatosPorCiudad(int id) async {}
}