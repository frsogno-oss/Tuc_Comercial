// lib/screens/offers_screen.dart (CORREGIDO)

import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/comercio.dart';
import '../services/api_service.dart'; // <-- 1. IMPORTAMOS EL SERVICIO DE API
import 'comercio_detail_screen.dart';

class OffersScreen extends StatelessWidget {
  final List<Comercio> comerciosEnOferta;

  const OffersScreen({super.key, required this.comerciosEnOferta});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ofertas'),
      ),
      body: comerciosEnOferta.isEmpty
      // Si no hay ofertas, muestra un mensaje
          ? const Center(
        child: Text(
          'No hay ofertas disponibles por el momento.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
      // Si hay ofertas, muestra el carrusel
          : Center(
        child: Container(
          constraints: const BoxConstraints(maxHeight: 500), // Limita la altura del carrusel
          child: Swiper(
            itemBuilder: (BuildContext context, int index) {
              final comercio = comerciosEnOferta[index];
              final fotoUrl = comercio.foto2 ?? '';

              // --- 2. LÓGICA DE URL CORREGIDA ---
              // Construye la URL completa usando la dirección del servidor real.
              final imageUrl = fotoUrl.startsWith('http')
                  ? fotoUrl
                  : '${ApiService.baseUrl}uploads/$fotoUrl';

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ComercioDetailScreen(comercio: comercio),
                    ),
                  );
                },
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  clipBehavior: Clip.antiAlias,
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: Colors.grey[300]),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            // --- 3. CORRECCIÓN DE SINTAXIS DEL GRADIENTE ---
                            gradient: LinearGradient(
                              colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                              begin: Alignment.bottomCenter,
                              end: Alignment.center,
                            ),
                          ),
                          padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                          child: Text(
                            comercio.nombre,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold,
                              shadows: [Shadow(blurRadius: 10.0, color: Colors.black)],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            itemCount: comerciosEnOferta.length,
            viewportFraction: 0.8,
            scale: 0.9,
            autoplay: true,
            pagination: const SwiperPagination(
              builder: DotSwiperPaginationBuilder(
                color: Colors.grey,
                activeColor: Colors.red,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
