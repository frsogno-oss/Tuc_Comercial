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
import 'asistente_chat_page.dart'; // <-- 1. IMPORTACIÓN DEL ASISTENTE
import '../theme.dart';

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
      // Opcional: Manejo de errores
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
    final screenHeight = MediaQuery.of(context).size.height;
    final carouselHeight = screenHeight * 0.45;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tuc Comercial'),
        actions: [
          TextButton.icon(
            onPressed: () => _showCityPicker(context),
            icon: const Icon(Icons.location_on, size: 20),
            label: Text(widget.ciudadActual.nombre),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textOnPrimary,
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: _buildSearchBar(),
          ),
          Expanded(
            child: _isSearching
                ? _buildSearchResults()
                : _buildMainContent(carouselHeight),
          ),
        ],
      ),

      // --- 2. BOTÓN FLOTANTE DEL ASISTENTE IA ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>  AsistentechatPage()),
          );
        },
        label: const Text('Asistente IA'),
        icon: const Icon(Icons.auto_awesome),
        backgroundColor: Colors.yellow,
      ),
      // -----------------------------------------
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
      height: height,
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
        pagination: const SwiperPagination(
          builder: DotSwiperPaginationBuilder(
            color: Colors.white70,
            activeColor: AppColors.primaryYellow,
          ),
        ),
        autoplay: true,
        viewportFraction: 0.85,
        scale: 0.9,
      ),
    );
  }

  Widget _buildCategoriesSection(BuildContext context) {
    final List<Color> categoryColors = [
      const Color(0xFFEBF4FF),
      const Color(0xFFFFFBEB),
      const Color(0xFFF0FFF4),
      const Color(0xFFFFF5F5),
      const Color(0xFFF9F5FF),
      const Color(0xFFFFF8E1),
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
              color: categoryColors[index % categoryColors.length],
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
