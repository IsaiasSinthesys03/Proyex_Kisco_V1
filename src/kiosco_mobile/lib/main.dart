import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uni_links/uni_links.dart';
import 'core/constants.dart';
import 'core/sync_service.dart';
import 'data/datasources/api_service.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/ranking_page.dart';
import 'presentation/pages/ranking_wait_page.dart';

void main() {
  runApp(const KioscoApp());
}

class KioscoApp extends StatelessWidget {
  const KioscoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appTitle,
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      home: const MainNavigationScreen(),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    bool isDark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1B5E20),
        brightness: brightness,
        primary: isDark ? const Color(0xFF81C784) : const Color(0xFF1B5E20),
        surface: isDark ? const Color(0xFF101411) : const Color(0xFFF5F9F6),
        background: isDark ? const Color(0xFF050505) : Colors.white,
      ),
      textTheme: GoogleFonts.interTextTheme(isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: isDark ? const Color(0xFF424940) : const Color(0xFFE0E0E0), width: 1),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? const Color(0xFF050505) : Colors.white,
        indicatorColor: (isDark ? const Color(0xFF81C784) : const Color(0xFF1B5E20)).withOpacity(0.1),
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  final ApiService _apiService = ApiService(baseUrl: AppConstants.baseUrl);
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
    _startSyncTask();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _initDeepLinks() async {
    _sub = uriLinkStream.listen((Uri? uri) {
      if (uri != null && uri.scheme == 'kiosco' && uri.host == 'project') {
        // Handle: kiosco://project/{id} (RF-FRONT-07)
        String? projectId = uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;
        if (projectId != null) {
          // In a real app, you'd fetch the project and navigate
          debugPrint('Navegar al proyecto: $projectId');
        }
      }
    }, onError: (err) {});
  }

  void _startSyncTask() {
    // Sync offline evaluations every minute or on start
    SyncService.syncQueue(_apiService);
    Timer.periodic(const Duration(minutes: 2), (timer) {
      SyncService.syncQueue(_apiService);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const HomePage(),
          const RankingScreen(), // Internally handles visibility based on settings
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view_rounded),
            label: 'Proyectos',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events_rounded),
            label: 'Ranking',
          ),
        ],
      ),
    );
  }
}
