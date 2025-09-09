import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

import 'package:Tuc_Comercial/models/rubro.dart';
import 'package:Tuc_Comercial/models/sub_rubro.dart';
import 'package:Tuc_Comercial/models/ciudad.dart';
import 'package:Tuc_Comercial/screens/mapa_selector.dart';

class PublishScreen extends StatefulWidget {
  final List<Rubro> rubros;
  final List<SubRubro> subRubros;
  final Ciudad ciudadActual;
  final List<Ciudad> ciudades;

  const PublishScreen({
    super.key,
    required this.rubros,
    required this.subRubros,
    required this.ciudadActual,
    required this.ciudades,
  });

  @override
  _PublishScreenState createState() => _PublishScreenState();
}

class _PublishScreenState extends State<PublishScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _horariosController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();

  LatLng? _selectedLocation;
  List<XFile> _selectedPhotos = [];

  Rubro? _selectedRubro;
  SubRubro? _selectedSubRubro;
  Ciudad? _selectedCiudad;

  @override
  void initState() {
    super.initState();
    _selectedCiudad = widget.ciudades.isNotEmpty ? widget.ciudades.first : null;
  }

  void _openMapSelector() async {
    final selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MapaSelectorPage(),
      ),
    );

    if (selectedLocation != null && selectedLocation is LatLng) {
      setState(() {
        _selectedLocation = selectedLocation;
      });
      Fluttertoast.showToast(msg: 'Ubicación guardada con éxito.');
    }
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? images = await picker.pickMultiImage();
    if (images != null) {
      setState(() {
        _selectedPhotos = images.take(3).toList();
      });
    }
  }

  void _enviarFormulario() async {
    // 1. Validar que los campos obligatorios estén llenos
    if (_nombreController.text.isEmpty ||
        _selectedRubro == null ||
        _selectedSubRubro == null ||
        _selectedCiudad == null ||
        _selectedLocation == null) {
      Fluttertoast.showToast(msg: "Por favor, completa los campos obligatorios.");
      return;
    }

    // 2. Crear la petición multipart para enviar datos y fotos
    final uri = Uri.parse('https://tuccomercial.uno/crear_solicitud.php'); // Asegúrate que la ruta sea correcta
    var request = http.MultipartRequest('POST', uri);

    // 3. Añadir los campos de texto
    request.fields['nombre'] = _nombreController.text;
    request.fields['descripcion'] = _descripcionController.text;
    request.fields['horarios'] = _horariosController.text;
    request.fields['whatsapp'] = _whatsappController.text;
    request.fields['instagram'] = _instagramController.text;
    request.fields['facebook'] = _facebookController.text;
    request.fields['latitud'] = _selectedLocation!.latitude.toString();
    request.fields['longitud'] = _selectedLocation!.longitude.toString();
    request.fields['id_rubro'] = _selectedRubro!.id.toString();
    request.fields['id_sub_rubro'] = _selectedSubRubro!.id.toString();
    request.fields['id_ciudad'] = _selectedCiudad!.id.toString();

    // 4. Añadir las fotos
    for (var i = 0; i < _selectedPhotos.length; i++) {
      final foto = _selectedPhotos[i];
      request.files.add(await http.MultipartFile.fromPath('fotos[]', foto.path));
    }

    // 5. Enviar la petición y manejar la respuesta
    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "Solicitud enviada con éxito.");
        _limpiarFormulario(); // Limpiar el formulario si todo sale bien
      } else {
        Fluttertoast.showToast(msg: "Error al enviar la solicitud.");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error de conexión: ${e.toString()}");
    }
  }

  void _limpiarFormulario() {
    _nombreController.clear();
    _descripcionController.clear();
    _horariosController.clear();
    _whatsappController.clear();
    _instagramController.clear();
    _facebookController.clear();
    setState(() {
      _selectedLocation = null;
      _selectedPhotos.clear();
      _selectedRubro = null;
      _selectedSubRubro = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<SubRubro> subrubrosFiltrados = _selectedRubro != null
        ? widget.subRubros.where((sr) => sr.idRubro == _selectedRubro!.id).toList()
        : [];

    return Scaffold(
      appBar: AppBar(title: const Text('Publica tu negocio')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre del comercio'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Ciudad>(
              decoration: const InputDecoration(labelText: 'Ciudad'),
              initialValue: _selectedCiudad,
              items: widget.ciudades.map((Ciudad ciudad) {
                return DropdownMenuItem<Ciudad>(
                  value: ciudad,
                  child: Text(ciudad.nombre),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedCiudad = newValue;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Rubro>(
              decoration: const InputDecoration(labelText: 'Rubro'),
              initialValue: _selectedRubro,
              items: widget.rubros.map((Rubro rubro) {
                return DropdownMenuItem<Rubro>(
                  value: rubro,
                  child: Text(rubro.nombre),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedRubro = newValue;
                  _selectedSubRubro = null;
                });
              },
            ),
            if (_selectedRubro != null)
              ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<SubRubro>(
                  decoration: const InputDecoration(labelText: 'Sub-rubro'),
                  initialValue: _selectedSubRubro,
                  items: subrubrosFiltrados.map((SubRubro subrubro) {
                    return DropdownMenuItem<SubRubro>(
                      value: subrubro,
                      child: Text(subrubro.nombre),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedSubRubro = newValue;
                    });
                  },
                ),
              ],
            const SizedBox(height: 16),
            TextField(
              controller: _descripcionController,
              decoration: const InputDecoration(labelText: 'Descripción'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _horariosController,
              decoration: const InputDecoration(labelText: 'Horarios'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _whatsappController,
              decoration: const InputDecoration(labelText: 'Número de WhatsApp'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _instagramController,
              decoration: const InputDecoration(labelText: 'Usuario de Instagram'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _facebookController,
              decoration: const InputDecoration(labelText: 'Usuario o link de Facebook'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _openMapSelector,
              child: const Text('Seleccionar ubicación en el mapa'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickImages,
              child: const Text('Agregar Fotos (Max 3)'),
            ),
            const SizedBox(height: 8),
            if (_selectedPhotos.isNotEmpty)
              Text('${_selectedPhotos.length} fotos seleccionadas.'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _enviarFormulario,
              child: const Text('Enviar'),
            ),
          ],
        ),
      ),
    );
  }
}