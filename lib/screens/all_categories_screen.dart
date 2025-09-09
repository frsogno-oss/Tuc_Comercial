// lib/screens/all_categories_screen.dart

import 'package:flutter/material.dart';
import '../models/rubro.dart';
import '../models/sub_rubro.dart';
import '../models/comercio.dart';
import 'sub_rubros_screen.dart';

class AllCategoriesScreen extends StatelessWidget {
  final List<Rubro> rubros;
  final List<SubRubro> subRubros;
  final List<Comercio> comercios;

  const AllCategoriesScreen({
    super.key,
    required this.rubros,
    required this.subRubros,
    required this.comercios,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todas las Categorías')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: rubros.length,
        itemBuilder: (context, index) {
          final rubro = rubros[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
              side: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            elevation: 4.0,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SubRubrosScreen(
                      rubro: rubro,
                      todosLosSubRubros: subRubros,
                      todosLosComercios: comercios,
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(15.0),
              // --- CÓDIGO AÑADIDO ---
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_getIconData(rubro.icono), size: 40, color: Theme.of(context).primaryColor),
                  const SizedBox(height: 8),
                  Text(
                    rubro.nombre,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              // --- FIN DEL CÓDIGO AÑADIDO ---
            ),
          );
        },
      ),
    );
  }

  // Helper para convertir el nombre del icono en un IconData
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'local_hospital': return Icons.local_hospital;
      case 'build': return Icons.build;
      case 'restaurant': return Icons.restaurant;
      case 'storefront': return Icons.storefront;
      case 'school': return Icons.school;
      case 'sports_soccer':return Icons.sports_soccer;
      case 'checkroom':return Icons.checkroom;
      case 'east':return Icons.east;
      default: return Icons.category;
    }
  }
}