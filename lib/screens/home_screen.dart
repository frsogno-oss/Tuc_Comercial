import 'dart:async';
import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/ciudad.dart';
import '../models/comercio.dart';
import '../models/rubro.dart';
import '../models/sub_rubro.dart';
import '../services/api_service.dart';
import '../widgets/terms_dialog.dart';
import 'all_categories_screen.dart';
import 'comercio_detail_screen.dart';
import 'sub_rubros_screen.dart';
import '../theme.dart'; // Importamos nuestro tema

class HomeScreen extends StatefulWidget {
  final List<Ciudad> ciudades;
  final Ciudad ciudadActual;
  final Function(Ciudad) onCiudadCambiada;
  final List<Rubro> rubros;
  final List<SubRubro> subRubros;
  final List<Comercio> comercios;

  const HomeScreen({
    super.key,
    required this.ciudades,
    required this.ciudadActual,
    required this.onCiudadCambiada,
    required this.rubros,
    required this.subRubros,
    required this.comercios,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _apiService = ApiService();
  final _searchController = TextEditingController();

  List<Comercio> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.length > 2) {
        if (mounted) setState(() => _isSearching = true);
        _performSearch(query);
      } else {
        if (mounted) {
          setState(() {
            _isSearching = false;
            _searchResults = [];
          });
        }
      }
    });
  }

  Future<void> _performSearch(String query) async {
    try {
      final results = await _apiService.buscarComercios(query, widget.ciudadActual.id);
      if (mounted) {
        setState(() => _searchResults = results);
      }
    } catch (e) {
      // Opcional: Mostrar un mensaje de error si la búsqueda falla
    }
  }

  void _showCityPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return ListView.builder(
          itemCount: widget.ciudades.length,
          itemBuilder: (context, index) {
            final ciudad = widget.ciudades[index];
            return ListTile(
              title: Text(ciudad.nombre),
              onTap: () {
                widget.onCiudadCambiada(ciudad);
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculamos la altura del carrusel para que ocupe la mitad de la pantalla
    final screenHeight = MediaQuery.of(context).size.height;
    final carouselHeight = screenHeight * 0.45; // 45% de la pantalla

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tuc Comercial'),
        actions: [
          // Selector de Ciudad ahora está en el AppBar para un look más limpio
          TextButton.icon(
            onPressed: () => _showCityPicker(context),
            icon: const Icon(Icons.location_on, size: 20),
            label: Text(widget.ciudadActual.nombre),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textOnPrimary, // Color del tema
            ),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Términos y Condiciones',
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => const TermsDialog(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // La barra de búsqueda ahora tiene su propio padding
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: _buildSearchBar(),
          ),
          Expanded(
            child: _isSearching
                ? _buildSearchResults()
                : _buildMainContent(carouselHeight), // Pasamos la altura al widget
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: _onSearchChanged,
      decoration: InputDecoration(
        hintText: 'Buscar en ${widget.ciudadActual.nombre}...',
        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: AppColors.shadow, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: AppColors.shadow, width: 1.5),
        ),
        filled: true,
        fillColor: AppColors.cardBackground,
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              setState(() {
                _isSearching = false;
                _searchResults = [];
              });
            })
            : null,
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return const Center(child: Text('No se encontraron resultados.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final comercio = _searchResults[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            title: Text(comercio.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(comercio.descripcion ?? ''),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ComercioDetailScreen(comercio: comercio)));
            },
          ),
        );
      },
    );
  }

  Widget _buildMainContent(double carouselHeight) {
    return SingleChildScrollView(
      // Ya no necesitamos padding aquí porque el body ya lo tiene
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFeaturedCarousel(context, carouselHeight),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildCategoriesSection(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCarousel(BuildContext context, double height) {
    final comerciosDestacados = widget.comercios.where((c) => c.esDestacado).toList();
    if (comerciosDestacados.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: height, // Usamos la altura calculada
      child: Swiper(
        itemBuilder: (BuildContext context, int index) {
          final comercio = comerciosDestacados[index];
          final fotoUrl = comercio.foto1 ?? '';
          final imageUrl = fotoUrl.startsWith('https')
              ? fotoUrl
              : '${ApiService.baseUrl}uploads/$fotoUrl';

          return GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ComercioDetailScreen(comercio: comercio)));
            },
            child: Container(
              // El margen ahora es vertical para dar espacio arriba y abajo
              margin: const EdgeInsets.symmetric(vertical: 10.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: Colors.grey[300]),
                      errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
                    ),
                    // Degradado para asegurar la legibilidad del texto
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.center,
                        ),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        comercio.nombre,
                        style: const TextStyle(fontSize: 22.0, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        itemCount: comerciosDestacados.length,
        // Indicadores de puntos
        pagination: const SwiperPagination(
          builder: DotSwiperPaginationBuilder(
            color: Colors.white70,
            activeColor: AppColors.primaryYellow,
          ),
        ),
        autoplay: true,
        viewportFraction: 0.85, // Un poco más grande para que se vea más imponente
        scale: 0.9,
      ),
    );
  }

  Widget _buildCategoriesSection(BuildContext context) {
    // Colores sobrios para las tarjetas de categorías
    final List<Color> categoryColors = [
      const Color(0xFFEBF4FF), // Azul claro
      const Color(0xFFFFFBEB), // Amarillo claro
      const Color(0xFFF0FFF4), // Verde claro
      const Color(0xFFFFF5F5), // Rojo claro
      const Color(0xFFF9F5FF), // Púrpura claro
      const Color(0xFFFFF8E1), // Naranja claro
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Rubros', style: Theme.of(context).textTheme.titleLarge),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AllCategoriesScreen(rubros: widget.rubros, subRubros: widget.subRubros, comercios: widget.comercios)));
              },
              child: const Text('Ver todos'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: widget.rubros.length > 6 ? 6 : widget.rubros.length,
          itemBuilder: (context, index) {
            final rubro = widget.rubros[index];
            return Card(
              // Usamos los colores sobrios definidos arriba
              color: categoryColors[index % categoryColors.length],
              // Quitamos el borde de la tarjeta para un look más integrado
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SubRubrosScreen(rubro: rubro, todosLosSubRubros: widget.subRubros, todosLosComercios: widget.comercios)));
                },
                borderRadius: BorderRadius.circular(15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_getIconData(rubro.icono), size: 35, color: AppColors.textPrimary),
                    const SizedBox(height: 8),
                    Text(
                      rubro.nombre,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'local_hospital': return Icons.local_hospital;
      case 'build': return Icons.build;
      case 'restaurant': return Icons.restaurant;
      case 'storefront': return Icons.storefront;
      case 'school': return Icons.school;
      case 'sports_soccer': return Icons.sports_soccer;
      case 'checkroom': return Icons.checkroom;
      case 'east': return Icons.east;
      default: return Icons.category;
    }
  }
}
