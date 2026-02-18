class AppConstants {
  // Cambia esto por tu IP local si pruebas en un dispositivo físico
  // Para emulador Android usar 10.0.2.2
  // Para iOS Simulator usar http://localhost:5260
  static const String baseUrl = 'http://127.0.0.1:5260'; 
  
  static const String appTitle = 'Proyex';
  
  // Endpoints
  static const String handshakeEndpoint = '/api/kiosk/Config/handshake';
  static const String projectsEndpoint = '/api/kiosk/Content/projects';
  static const String templateEndpoint = '/api/kiosk/Content/template';
  static const String evaluateEndpoint = '/api/kiosk/Evaluation/evaluate';
  static const String rankingEndpoint = '/api/kiosk/Ranking';
}
