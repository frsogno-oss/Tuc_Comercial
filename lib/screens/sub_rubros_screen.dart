import 'package:flutter/material.dart';
import '../models/rubro.dart';
import '../models/sub_rubro.dart';
import '../models/comercio.dart';
import 'comercios_list_screen.dart';

class SubRubrosScreen extends StatelessWidget {
  final Rubro rubro;
  final List<SubRubro> todosLosSubRubros;
  final List<Comercio> todosLosComercios;

  const SubRubrosScreen({
    super.key,
    required this.rubro,
    required this.todosLosSubRubros,
    required this.todosLosComercios,
  });

  @override
  Widget build(BuildContext context) {
    // Filtramos los sub-rubros que pertenecen al rubro seleccionado
    final subRubrosDelRubro = todosLosSubRubros.where((sr) => sr.idRubro == rubro.id).toList();

    return Scaffold(
      appBar: AppBar(title: Text(rubro.nombre)),
      // CAMBIO: Reemplazamos el ListView.builder simple por uno con Cards.
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        itemCount: subRubrosDelRubro.length,
        itemBuilder: (context, index) {
          final subRubro = subRubrosDelRubro[index];

          // CAMBIO: Cada item es ahora una Card para darle el efecto 3D.
          return Card(
            elevation: 2.0, // La sombra que crea el efecto 3D
            margin: const EdgeInsets.only(bottom: 12.0), // Espacio entre los botones
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            clipBehavior: Clip.antiAlias, // Asegura que el efecto al tocar no se salga del borde
            child: InkWell(
              onTap: () {
                // La acción de tocar el botón sigue siendo la misma.
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ComerciosListScreen(
                      subRubro: subRubro,
                      todosLosComercios: todosLosComercios,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Usamos Expanded para que el texto ocupe el espacio disponible
                    Expanded(
                      child: Text(
                        subRubro.nombre,
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Mantenemos el icono de flecha
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

