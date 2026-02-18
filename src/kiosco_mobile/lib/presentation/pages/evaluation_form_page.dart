import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/local_data_manager.dart';
import '../../data/datasources/api_service.dart';
import '../../data/models/evaluation_template_model.dart';
import '../../data/models/project_model.dart';
import 'feedback_page.dart';

class EvaluationFormPage extends StatefulWidget {
  final ProjectModel project;

  const EvaluationFormPage({super.key, required this.project});

  @override
  State<EvaluationFormPage> createState() => _EvaluationFormPageState();
}

class _EvaluationFormPageState extends State<EvaluationFormPage> {
  final ApiService _apiService = ApiService(baseUrl: AppConstants.baseUrl);
  late Future<EvaluationTemplateModel> _templateFuture;
  
  int _currentStep = 0;
  final Map<String, int> _answers = {};
  EvaluationTemplateModel? _template;

  @override
  void initState() {
    super.initState();
    _templateFuture = _apiService.getActiveTemplate();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<EvaluationTemplateModel>(
      future: _templateFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        
        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No se pudo cargar la plantilla de evaluación.'),
                  ElevatedButton(
                    onPressed: () => setState(() => _templateFuture = _apiService.getActiveTemplate()),
                    child: const Text('Reintentar'),
                  )
                ],
              ),
            ),
          );
        }

        _template = snapshot.data;
        var section = _template!.sections[_currentStep];

        return Scaffold(
          appBar: AppBar(
            title: const Text('Evaluación'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => _handleExit(),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Text(
                    '${_currentStep + 1}/${_template!.sections.length}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
          body: Column(
            children: [
              // Progress steps
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: List.generate(_template!.sections.length, (index) {
                    bool isPast = index < _currentStep;
                    bool isCurrent = index == _currentStep;
                    return Expanded(
                      child: Container(
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: isPast || isCurrent 
                              ? Theme.of(context).colorScheme.primary 
                              : Theme.of(context).colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sección ${_currentStep + 1}: ${section.title}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      const SizedBox(height: 24),
                      ... section.questions.map((q) => _buildQuestion(q)),
                    ],
                  ),
                ),
              ),

              // Footer buttons
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: _canGoNext() ? _handleNext : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_currentStep == _template!.sections.length - 1 ? 'Finalizar' : 'Siguiente'),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuestion(TemplateQuestionModel q) {
    int? selectedValue = _answers[q.id];

    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            q.text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              int val = index + 1;
              bool selected = selectedValue == val;
              return InkWell(
                onTap: () {
                  setState(() => _answers[q.id] = val);
                  LocalDataManager.saveDraft(widget.project.id, _answers);
                },
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                    border: Border.all(
                      color: selected 
                          ? Theme.of(context).colorScheme.primary 
                          : Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$val',
                      style: TextStyle(
                        color: selected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  bool _canGoNext() {
    if (_template == null) return false;
    var questions = _template!.sections[_currentStep].questions;
    return questions.every((q) => _answers.containsKey(q.id));
  }

  void _handleNext() {
    if (_currentStep < _template!.sections.length - 1) {
      setState(() => _currentStep++);
    } else {
      _showConfirmation();
    }
  }

  void _handleExit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Salir de evaluación'),
        content: const Text('¿Deseas guardar un borrador para continuar después?'),
        actions: [
          TextButton(
            onPressed: () {
              LocalDataManager.clearDraft(widget.project.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('No guardar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar envío'),
        content: const Text('¿Estás seguro de enviar tu calificación?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _submitEvaluation();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitEvaluation() async {
    final uuid = await LocalDataManager.getOrCreateUuid();
    final answersList = _answers.entries.map((e) => {'questionId': e.key, 'value': e.value}).toList();
    
    // RNF-08: Control de integridad SHA256
    final rawData = '${widget.project.id}|$uuid|${json.encode(answersList)}|K10SK0_S3CR3T';
    final signature = sha256.convert(utf8.encode(rawData)).toString();

    final data = {
      'projectId': widget.project.id,
      'deviceUuid': uuid,
      'templateVersion': _template!.version,
      'answers': answersList,
      'clientTimestamp': DateTime.now().toIso8601String(),
      'signature': signature,
    };

    final success = await _apiService.submitEvaluation(data);
    
    if (success) {
      await LocalDataManager.markAsVoted(widget.project.id);
      await LocalDataManager.clearDraft(widget.project.id);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FeedbackPage()),
      );
    } else {
      // Manejar error de red / offline (RF-FRONT-18)
      await SyncService.addToQueue(data);
      await LocalDataManager.markAsVoted(widget.project.id); // Mark as voted even if offline
      await LocalDataManager.clearDraft(widget.project.id);
      
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FeedbackPage()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sin conexión. Tu voto se enviará automáticamente al recuperar internet.')),
      );
    }
  }
}
