import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart'; // <-- 1. IMPORTAMOS EL NUEVO PAQUETE
import '../models/comercio.dart';
import '../services/api_service.dart';

class ComercioDetailScreen extends StatelessWidget {
  final Comercio comercio;

  const ComercioDetailScreen({super.key, required this.comercio});

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // Manejar error
    }
  }

  // --- 2. NUEVA FUNCIÓN PARA COMPARTIR ---
  void _shareComercio(BuildContext context) {
    // ¡IMPORTANTE! Reemplaza esto con los links reales de tu app cuando la publiques
    final String playStoreLink = "https://play.google.com/store/apps/details?id=tu.paquete.android";
    final String appStoreLink = "https://apps.apple.com/app/id-de-tu-app";

    final String shareText =
        "¡Mira este lugar que encontré en Tuc Comercial!\n\n"
        "*${comercio.nombre}*\n"
        "${comercio.descripcion ?? ''}\n\n"
        "Descarga la app para descubrir más comercios locales:\n"
        "Android: $playStoreLink\n"
        "iPhone: $appStoreLink";

    Share.share(shareText);
  }

  @override
  Widget build(BuildContext context) {
    final List<String> images = [comercio.foto1, comercio.foto2, comercio.foto3]
        .where((f) => f != null && f.isNotEmpty)
        .map((f) {
      final fotoUrl = f ?? '';
      return fotoUrl.startsWith('http')
          ? fotoUrl
          : '${ApiService.baseUrl}uploads/$fotoUrl';
    })
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(comercio.nombre)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (images.isNotEmpty)
              SizedBox(
                height: 250,
                child: Swiper(
                  itemBuilder: (BuildContext context, int index) {
                    return CachedNetworkImage(
                      imageUrl: images[index],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: Colors.grey[300]),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    );
                  },
                  itemCount: images.length,
                  pagination: const SwiperPagination(),
                  control: const SwiperControl(color: Colors.white),
                ),
              )
            else
              Container(height: 250, color: Colors.grey[300], child: const Center(child: Icon(Icons.image, size: 50, color: Colors.grey))),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(comercio.nombre, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (comercio.whatsapp != null && comercio.whatsapp!.isNotEmpty)
                        _buildActionButton(FontAwesomeIcons.whatsapp, 'WhatsApp', Colors.green, () {
                          final String mensaje = Uri.encodeComponent("Hola, vi tu comercio en Tuc Comercial y quiero consultarte...");
                          _launchURL('https://wa.me/${comercio.whatsapp}?text=$mensaje');
                        }),
                      if (comercio.instagram != null && comercio.instagram!.isNotEmpty)
                        _buildActionButton(FontAwesomeIcons.instagram, 'Instagram', Colors.purple, () => _launchURL(comercio.instagram!)),
                      if (comercio.facebook != null && comercio.facebook!.isNotEmpty)
                        _buildActionButton(FontAwesomeIcons.facebook, 'Facebook', Colors.blue, () => _launchURL(comercio.facebook!)),
                      if (comercio.ubicacionUrl != null && comercio.ubicacionUrl!.isNotEmpty)
                        _buildActionButton(FontAwesomeIcons.mapLocationDot, 'Ubicación', Colors.red, () => _launchURL(comercio.ubicacionUrl!)),

                      // --- 3. AÑADIMOS EL NUEVO BOTÓN DE COMPARTIR ---
                      _buildActionButton(Icons.share, 'Compartir', Colors.blue, () => _shareComercio(context)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (comercio.descripcion != null && comercio.descripcion!.isNotEmpty) ...[
                    const Divider(),
                    const SizedBox(height: 16),
                    Text('Sobre nosotros', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(comercio.descripcion!, style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5)),
                    const SizedBox(height: 24),
                  ],
                  if (comercio.horarios != null && comercio.horarios!.isNotEmpty) ...[
                    Text('Horarios de atención', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(comercio.horarios!, style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onPressed) {
    return Column(
      children: [
        IconButton(icon: FaIcon(icon), iconSize: 30, color: color, onPressed: onPressed),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
