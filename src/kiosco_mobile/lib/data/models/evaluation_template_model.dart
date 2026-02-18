class EvaluationTemplateModel {
  final String version;
  final List<TemplateSectionModel> sections;

  EvaluationTemplateModel({required this.version, required this.sections});

  factory EvaluationTemplateModel.fromJson(Map<String, dynamic> json) {
    return EvaluationTemplateModel(
      version: json['version'] ?? '',
      sections: (json['sections'] as List? ?? [])
          .map((s) => TemplateSectionModel.fromJson(s))
          .toList(),
    );
  }
}

class TemplateSectionModel {
  final String title;
  final int order;
  final List<TemplateQuestionModel> questions;

  TemplateSectionModel({
    required this.title, 
    required this.order, 
    required this.questions
  });

  factory TemplateSectionModel.fromJson(Map<String, dynamic> json) {
    return TemplateSectionModel(
      title: json['title'] ?? '',
      order: json['order'] ?? 0,
      questions: (json['questions'] as List? ?? [])
          .map((q) => TemplateQuestionModel.fromJson(q))
          .toList(),
    );
  }
}

class TemplateQuestionModel {
  final String id;
  final String text;
  final String type;

  TemplateQuestionModel({
    required this.id, 
    required this.text, 
    required this.type
  });

  factory TemplateQuestionModel.fromJson(Map<String, dynamic> json) {
    return TemplateQuestionModel(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      type: json['type'] ?? 'scale_1_5',
    );
  }
}
