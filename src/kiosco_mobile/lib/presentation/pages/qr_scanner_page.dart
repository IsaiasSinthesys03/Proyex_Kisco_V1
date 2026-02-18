import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> with WidgetsBindingObserver {
  late MobileScannerController _controller;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Initialize controller with specific settings
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      returnImage: false,
    );
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  // Handle app lifecycle to manage camera resources
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_controller.value.isInitialized) {
      return;
    }

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;
      case AppLifecycleState.resumed:
        _controller.start();
      case AppLifecycleState.inactive:
        _controller.stop();
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return; // Prevent multiple scans

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;
      
      if (code != null) {
        debugPrint('Código: $code');
        setState(() => _isProcessing = true);
        
        // Asumimos que el QR contiene el ID del proyecto directamente
        // o una URL tipo "proyex://project/{id}"
        String projectId = code;
        
        // Lógica simple de extracción
        if (code.contains('/')) {
            projectId = code.split('/').last;
        }

        // Navegar al detalle usando GoRouter
        if (mounted) {
            context.push('/project/$projectId');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Escanear Proyecto', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, state, child) {
                if (!state.isInitialized || !state.isRunning) {
                  return const SizedBox();
                }
                return Icon(
                  state.torchState == TorchState.off ? Icons.flash_off : Icons.flash_on,
                  color: Colors.white,
                );
              },
            ),
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, state, child) {
                if (!state.isInitialized || !state.isRunning) {
                  return const SizedBox();
                }
                return Icon(
                   _controller.facing == CameraFacing.front
                      ? Icons.camera_front
                      : Icons.camera_rear,
                  color: Colors.white,
                );
              },
            ),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          // Sombra oscura semitransparente con recorte
          CustomPaint(
            painter: ScannerOverlayPainter(borderColor: Theme.of(context).primaryColor),
            child: Container(),
          ),
          // Instrucciones
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'Apunta al código QR',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  final Color borderColor;
  final double borderRadius;
  final double borderLength;
  final double borderWidth;
  final double cutOutSize;

  ScannerOverlayPainter({
    required this.borderColor,
    this.borderRadius = 10,
    this.borderLength = 30,
    this.borderWidth = 5,
    this.cutOutSize = 280,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;
    
    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round;

    final boxPaint = Paint()
      ..color = Colors.transparent
      ..blendMode = BlendMode.clear;

    final rect = Rect.fromLTWH(0, 0, width, height);
    final cutOutRect = Rect.fromCenter(
      center: Offset(width / 2, height / 2),
      width: cutOutSize,
      height: cutOutSize,
    );

    // 1. Dibujar fondo oscuro con el recorte
    canvas.saveLayer(rect, backgroundPaint);
    canvas.drawRect(rect, backgroundPaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius)), 
      boxPaint
    );
    canvas.restore();

    // 2. Dibujar las esquinas del borde
    final path = Path();
    
    // Top Left
    path.moveTo(cutOutRect.left, cutOutRect.top + borderLength);
    path.lineTo(cutOutRect.left, cutOutRect.top);
    path.lineTo(cutOutRect.left + borderLength, cutOutRect.top);

    // Top Right
    path.moveTo(cutOutRect.right - borderLength, cutOutRect.top);
    path.lineTo(cutOutRect.right, cutOutRect.top);
    path.lineTo(cutOutRect.right, cutOutRect.top + borderLength);

    // Bottom Right
    path.moveTo(cutOutRect.right, cutOutRect.bottom - borderLength);
    path.lineTo(cutOutRect.right, cutOutRect.bottom);
    path.lineTo(cutOutRect.right - borderLength, cutOutRect.bottom);

    // Bottom Left
    path.moveTo(cutOutRect.left + borderLength, cutOutRect.bottom);
    path.lineTo(cutOutRect.left, cutOutRect.bottom);
    path.lineTo(cutOutRect.left, cutOutRect.bottom - borderLength);

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
