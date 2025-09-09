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
      body: ListView.builder(
        itemCount: subRubrosDelRubro.length,
        itemBuilder: (context, index) {
          final subRubro = subRubrosDelRubro[index];
          return ListTile(
            title: Text(subRubro.nombre),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
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
          );
        },
      ),
    );
  }
}