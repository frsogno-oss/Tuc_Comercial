// lib/screens/contact_screen.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final ApiService _apiService = ApiService();
  Future<Map<String, dynamic>>? _contactData;

  @override
  void initState() {
    super.initState();
    _contactData = _apiService.getDatosDeContacto();
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // Manejar error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contacto')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _contactData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar datos: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay información de contacto disponible.'));
          }

          final data = snapshot.data!;
          final whatsapp = data['whatsapp_numero'] ?? '';
          final instagram = data['instagram_url'] ?? '';

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // <-- CAMBIO 1: Reemplazamos el ícono por tu logo
                  const CircleAvatar(
                    radius: 50,
                    // Usamos tu logo como fondo del círculo
                    backgroundImage: AssetImage('assets/logo_foreground.png'),
                    // Fondo transparente por si el logo no carga
                    backgroundColor: Colors.transparent,
                  ),
                  const SizedBox(height: 16),
                  // <-- CAMBIO 2: Reemplazamos el nombre dinámico por el de tu app
                  Text(
                    'Tuc Comercial',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data['slogan'] ?? 'Tu Guía de Confianza', // Mantenemos el slogan
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  if (whatsapp.isNotEmpty)
                    ElevatedButton.icon(
                      onPressed: () {
                        final String mensaje = Uri.encodeComponent("Hola, te contacto desde la app Tuc Comercial...");
                        _launchURL('https://wa.me/$whatsapp?text=$mensaje');
                      },
                      icon: const FaIcon(FontAwesomeIcons.whatsapp),
                      label: const Text('Contactar por WhatsApp'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  const SizedBox(height: 12),
                  if (instagram.isNotEmpty)
                    ElevatedButton.icon(
                      onPressed: () => _launchURL(instagram),
                      icon: const FaIcon(FontAwesomeIcons.instagram),
                      label: const Text('Síguenos en Instagram'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}