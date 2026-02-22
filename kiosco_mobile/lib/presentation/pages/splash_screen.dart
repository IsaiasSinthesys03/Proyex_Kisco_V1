import 'package:flutter/material.dart';
import '../../main.dart'; // Para navegar a MainNavigationScreen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startHandshake();
  }

  Future<void> _startHandshake() async {
    // Simulamos la validación inicial con el backend y la precarga de configuración
    await Future.delayed(const Duration(seconds: 3));

    // Validamos que el widget siga montado antes de hacer el pushReplacement
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos el tema actual
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo representativo de Proyex
            Image.asset(
              'assets/images/logo.png', // Usaremos el logo oficial
              height: 120,
            ),
            const SizedBox(height: 24),
            // Título de la app
            Text(
              'PROYEX',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 48),
            // Indicador de Progreso
            CircularProgressIndicator(color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            // Mensaje de carga
            Text(
              'Cargando sistema de votación...',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
