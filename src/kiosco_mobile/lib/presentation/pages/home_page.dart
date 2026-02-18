import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiosco_mobile/core/constants.dart';
import 'package:kiosco_mobile/data/datasources/api_service.dart';
import 'package:kiosco_mobile/data/models/project_model.dart';
import 'package:kiosco_mobile/presentation/widgets/project_card.dart';
import 'qr_scanner_page.dart';
import '../../main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService(baseUrl: AppConstants.baseUrl);
  late Future<List<ProjectModel>> _projectsFuture;
  String _selectedCategory = 'Todos';
  List<String> _dynamicCategories = ['Todos'];

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  void _loadProjects() {
    setState(() {
      _projectsFuture = _apiService.getProjects().then((projects) {
        // Extraer categorías únicas de los proyectos
        final categories = projects.map((p) => p.category).toSet().toList();
        categories.sort();
        setState(() {
          _dynamicCategories = ['Todos', ...categories];
        });
        return projects;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _loadProjects();
          },
          child: CustomScrollView(
            slivers: [
              // ... (Barra de búsqueda omitida por brevedad, se mantiene igual)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          height: 50,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search, color: Colors.grey),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Buscar proyectos...',
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.qr_code_scanner, color: Theme.of(context).colorScheme.primary),
                                onPressed: () {
                                    Navigator.push(
                                        context, 
                                        MaterialPageRoute(builder: (context) => const QRScannerPage())
                                    );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: () {
                          // Ciclo: system -> light -> dark -> system
                          final current = ProyexApp.themeNotifier.value;
                          if (current == ThemeMode.system) {
                            ProyexApp.themeNotifier.value = ThemeMode.light;
                          } else if (current == ThemeMode.light) {
                            ProyexApp.themeNotifier.value = ThemeMode.dark;
                          } else {
                            ProyexApp.themeNotifier.value = ThemeMode.system;
                          }
                        },
                        icon: Icon(
                          ProyexApp.themeNotifier.value == ThemeMode.dark 
                              ? Icons.light_mode 
                              : ProyexApp.themeNotifier.value == ThemeMode.light 
                                  ? Icons.dark_mode 
                                  : Icons.brightness_auto,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                        ),
                      )
                    ],
                  ),
                ),
              ),

              // Categories Chips Dinámicos
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 20),
                    itemCount: _dynamicCategories.length,
                    itemBuilder: (context, index) {
                      bool selected = _selectedCategory == _dynamicCategories[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(_dynamicCategories[index]),
                          selected: selected,
                          onSelected: (val) => setState(() => _selectedCategory = _dynamicCategories[index]),
                          selectedColor: Theme.of(context).colorScheme.primary,
                          labelStyle: TextStyle(
                            color: selected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Project Grid
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: FutureBuilder<List<ProjectModel>>(
                  future: _projectsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SliverToBoxAdapter(child: Center(child: Padding(
                        padding: EdgeInsets.only(top: 100),
                        child: CircularProgressIndicator(),
                      )));
                    } else if (snapshot.hasError) {
                      return SliverToBoxAdapter(
                        child: Center(child: Column(
                          children: [
                            const Icon(Icons.wifi_off_rounded, size: 60, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text('Error de conexión: ${snapshot.error.toString().contains('Failed host') ? 'No se pudo llegar al servidor' : snapshot.error}'),
                            TextButton(onPressed: _loadProjects, child: const Text('Reintentar'))
                          ],
                        )),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const SliverToBoxAdapter(child: Center(child: Text('No hay proyectos disponibles')));
                    }

                    final projects = _selectedCategory == 'Todos' 
                        ? snapshot.data! 
                        : snapshot.data!.where((p) => p.category == _selectedCategory).toList();

                    if (projects.isEmpty) {
                       return const SliverToBoxAdapter(child: Center(child: Text('No hay proyectos en esta categoría')));
                    }

                    return SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => ProjectCard(project: projects[index]),
                        childCount: projects.length,
                      ),
                    );
                  },
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }
}
