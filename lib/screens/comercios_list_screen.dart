// lib/screens/comercios_list_screen.dart

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/sub_rubro.dart';
import '../models/comercio.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import 'comercio_detail_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Importación necesaria para LatLng
import 'mapa_comercios.dart'; // Importación necesaria para la pantalla del mapa

class ComerciosListScreen extends StatefulWidget {
  final SubRubro subRubro;
  final List<Comercio> todosLosComercios;

  const ComerciosListScreen({
    super.key,
    required this.subRubro,
    required this.todosLosComercios,
  });

  @override
  State<ComerciosListScreen> createState() => _ComerciosListScreenState();
}

class _ComerciosListScreenState extends State<ComerciosListScreen> {
  final ApiService _apiService = ApiService();
  final LocationService _locationService = LocationService();
  bool _isFinding = false;
  late List<Comercio> _comerciosDelSubRubro;

  @override
  void initState() {
    super.initState();
    _comerciosDelSubRubro = widget.todosLosComercios.where((c) => c.idSubRubro == widget.subRubro.id).toList();
  }

  Future<void> _findNearest() async {
    setState(() => _isFinding = true);
    try {
      final position = await _locationService.getCurrentPosition();

      // Aquí abres el mapa con la ubicación del usuario
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MapaComerciosPage(
              initialPosition: LatLng(position.latitude, position.longitude),
              idSubRubro: widget.subRubro.id,
            ),
          ),
        );
      }

    } catch (e) {
      Fluttertoast.showToast(msg: "Error: ${e.toString()}", backgroundColor: Colors.red);
    } finally {
      if (mounted) setState(() => _isFinding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subRubro.nombre),
        actions: [
          if (_isFinding)
            const Padding(padding: EdgeInsets.only(right: 16.0), child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white)))
          else
            IconButton(
              icon: const Icon(Icons.my_location),
              tooltip: 'Buscar más cercano',
              onPressed: _findNearest,
            ),
        ],
      ),
      body: _comerciosDelSubRubro.isEmpty
          ? const Center(child: Text('No hay comercios en esta categoría.'))
          : ListView.builder(
        itemCount: _comerciosDelSubRubro.length,
        itemBuilder: (context, index) {
          final comercio = _comerciosDelSubRubro[index];
          final fotoUrl = comercio.foto1 ?? '';
          final imageUrl = fotoUrl.startsWith('http')
              ? fotoUrl
              : '${ApiService.baseUrl}uploads/$fotoUrl';

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              leading: CircleAvatar(backgroundImage: NetworkImage(imageUrl)),
              title: Text(comercio.nombre),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ComercioDetailScreen(comercio: comercio)));
              },
            ),
          );
        },
      ),
    );
  }
}