import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../models/comercio.dart';
import '../services/api_service.dart';
import 'comercio_detail_screen.dart';

class RecommendedBusiness {
  final int id;
  final String nombre;
  final String foto;
  RecommendedBusiness({required this.id, required this.nombre, required this.foto});
}

class ChatMessage {
  final String text;
  final bool isUser;
  final List<RecommendedBusiness> recommendations;

  ChatMessage({required this.text, required this.isUser, this.recommendations = const []});
}

class AsistentechatPage extends StatefulWidget {
  @override
  _AsistentechatPageState createState() => _AsistentechatPageState();
}

class _AsistentechatPageState extends State<AsistentechatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(onResult: (val) => setState(() {
          _controller.text = val.recognizedWords;
          if (val.finalResult) {
            _isListening = false;
            _sendMessage(_controller.text);
          }
        }));
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.isEmpty) return;
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://tuccomercial.uno/asistente_ia.php'),
        body: {'pregunta': text},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<RecommendedBusiness> recs = [];
        if (data['recomendaciones'] != null) {
          for (var item in data['recomendaciones']) {
            recs.add(RecommendedBusiness(
                id: int.parse(item['id'].toString()),
                nombre: item['nombre'],
                foto: item['foto'] ?? ''
            ));
          }
        }
        setState(() {
          _messages.add(ChatMessage(text: data['respuesta'], isUser: false, recommendations: recs));
        });
      }
    } catch (e) { print(e); }
    finally {
      setState(() => _isLoading = false);
      _controller.clear();
    }
  }

  // FUNCIÓN PARA CARGAR EL COMERCIO COMPLETO
  Future<void> _irAlPerfil(int id) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.amber)),
    );

    try {
      final ApiService apiService = ApiService();
      Comercio? comercioCompleto = await apiService.getComercioById(id);

      Navigator.pop(context); // Quitar carga

      if (comercioCompleto != null) {
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => ComercioDetailScreen(comercio: comercioCompleto)
        ));
      }
    } catch (e) {
      Navigator.pop(context);
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Asistente Tuc Comercial", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.amber,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Column(
                  crossAxisAlignment: msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    _buildBubble(msg),
                    // Lista de tarjetas recomendadas
                    ...msg.recommendations.map((biz) => _buildBusinessCard(biz)).toList(),
                  ],
                );
              },
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(color: Colors.amber),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildBubble(ChatMessage msg) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: msg.isUser ? Colors.amber[100] : Colors.grey[200],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(msg.text),
    );
  }

  Widget _buildBusinessCard(RecommendedBusiness biz) {
    String imageUrl = "https://tuccomercial.uno/uploads/${biz.foto}"; //

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: ListTile(
          leading: CircleAvatar(backgroundImage: NetworkImage(imageUrl)),
          title: Text(biz.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: const Text("¡Ver ubicación y contacto!"),
          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.amber, size: 18),
          onTap: () => _irAlPerfil(biz.id), // Carga real de datos
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: _isListening ? Colors.red : Colors.amber),
            onPressed: _listen,
          ),
          Expanded(child: TextField(controller: _controller, decoration: InputDecoration(hintText: "Hola, te ayudo a buscar un comercio? ", border: OutlineInputBorder(borderRadius: BorderRadius.circular(23))))),
          IconButton(icon: const Icon(Icons.send, color: Colors.amber), onPressed: () => _sendMessage(_controller.text)),
        ],
      ),
    );
  }
}