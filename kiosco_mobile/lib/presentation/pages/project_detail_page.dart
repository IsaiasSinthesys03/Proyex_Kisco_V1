import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/project.dart';
import 'evaluation_form_page.dart';

class ProjectDetailPage extends StatelessWidget {
  final Project project;

  const ProjectDetailPage({super.key, required this.project});

  Future<void> _launchUrl(BuildContext context, String url) async {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Abriendo documento...'),
          duration: Duration(seconds: 1),
        ),
      );
    }

    debugPrint('🚀 Intentando abrir URL: $url');
    final uri = Uri.parse(url);

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('No hay app para abrir este archivo'),
              action: SnackBarAction(
                label: 'COPIAR LINK',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: url));
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            action: SnackBarAction(
              label: 'COPIAR',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: url));
              },
            ),
          ),
        );
      }
    }
  }

  void _showGallery(BuildContext context, List<String> images, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: PageView.builder(
            itemCount: images.length,
            controller: PageController(initialPage: initialIndex),
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: Hero(
                    tag: images[index],
                    child: Image.network(
                      images[index],
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator(color: Colors.white));
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 1. El Logo pequeño debe ser estrictamente el iconUrl
    final String? effectiveLogoUrl = (project.iconUrl != null && project.iconUrl!.isNotEmpty) 
        ? project.iconUrl 
        : null;

    print('🔍 DEBUG LOGO: project.iconUrl = ${project.iconUrl}');
    print('🔍 DEBUG LOGO: effectiveLogoUrl = $effectiveLogoUrl');

    // 2. El Banner (imagen grande) debe ser el coverImageUrl, y ser la primera en la galería
    final List<String> slideshowImages = [
      if (project.coverImageUrl != null && project.coverImageUrl!.isNotEmpty) project.coverImageUrl!,
      ...project.galleryUrls,
    ].toList();

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // 1. CABECERA INTEGRADA (Imagen + Logo Flotante)
              SliverToBoxAdapter(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // La imagen de fondo
                    SizedBox(
                      height: 320,
                      width: double.infinity,
                      child: slideshowImages.isNotEmpty
                          ? PageView.builder(
                              itemCount: slideshowImages.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () => _showGallery(context, slideshowImages, index),
                                  child: Hero(
                                    tag: slideshowImages[index],
                                    child: Image.network(
                                      slideshowImages[index],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            )
                          : Container(color: theme.colorScheme.surfaceVariant),
                    ),
                    
                    // El contenedor de contenido (Blanco/Oscuro)
                    Container(
                      margin: const EdgeInsets.only(top: 280),
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.background,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // FILA PARA TÍTULO Y CATEGORÍA
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                               const SizedBox(width: 125), 
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 10), 
                                    LayoutBuilder(
                                      builder: (context, constraints) {
                                        // Escala mucho más agresiva para nombres largos
                                        double fontSize = 28;
                                        if (project.title.length > 20) fontSize = 18;
                                        else if (project.title.length > 15) fontSize = 20;
                                        else if (project.title.length > 10) fontSize = 22;
                                        
                                        return Text(
                                          project.title,
                                          style: theme.textTheme.headlineSmall?.copyWith(
                                            fontWeight: FontWeight.bold, 
                                            fontSize: fontSize,
                                            height: 1.1,
                                            letterSpacing: -0.5
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.visible, // Permitir que se vea bien
                                        );
                                      }
                                    ),
                                    const SizedBox(height: 14),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: Text(
                                        project.category.toUpperCase(),
                                        style: TextStyle(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 12,
                                          letterSpacing: 0.5
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // EL LOGO: POSICIÓN MÁS BAJA
                    Positioned(
                      top: 258, // Bajado de 240 a 258 para alineación casi total con el título
                      left: 24,
                      child: Container(
                        width: 115,
                        height: 115,
                        decoration: BoxDecoration(
                          color: isDark ? theme.colorScheme.surface : Colors.white,
                          borderRadius: BorderRadius.circular(36),
                          border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.3), width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05), // Sombra más integrada
                              blurRadius: 25,
                              offset: const Offset(0, 10),
                            )
                          ],
                        ),
                        padding: const EdgeInsets.all(8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: effectiveLogoUrl != null
                              ? Image.network(
                                  effectiveLogoUrl,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => Icon(Icons.business, color: theme.colorScheme.primary, size: 60),
                                )
                              : Icon(Icons.apps_rounded, color: theme.colorScheme.primary, size: 60),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. RESTO DEL CONTENIDO
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      if (project.teamMembers.isNotEmpty) ...[
                        RichText(
                          text: TextSpan(
                            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                            children: [
                              TextSpan(
                                text: 'Autores:  ',
                                style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                              ),
                              TextSpan(
                                text: project.teamMembers.join(' - '),
                                style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.8)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],

                      _buildStyledCard(theme, 'Descripción', project.description),
                      const SizedBox(height: 32),

                      if (project.videoUrl != null && project.videoUrl!.isNotEmpty) ...[
                        _buildSectionTitle(theme, 'Vídeo Demo'),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () => _launchUrl(context, project.videoUrl!),
                          child: Container(
                            width: double.infinity,
                            height: 180,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(20),
                              image: (project.coverImageUrl != null)
                                ? DecorationImage(
                                    image: NetworkImage(project.coverImageUrl!), 
                                    fit: BoxFit.cover, 
                                    opacity: 0.5
                                  )
                                : null,
                            ),
                            child: const Center(child: Icon(Icons.play_circle_fill, size: 70, color: Colors.white)),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],

                      if (project.objectives.isNotEmpty) ...[
                        _buildSectionTitle(theme, 'Objetivos'),
                        const SizedBox(height: 12),
                        ...project.objectives.map((obj) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Icon(Icons.fiber_manual_record, size: 8, color: theme.colorScheme.onSurface),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text(obj, style: const TextStyle(fontSize: 15, height: 1.4))),
                            ],
                          ),
                        )),
                        const SizedBox(height: 32),
                      ],

                      if (project.techStack.isNotEmpty) ...[
                        _buildSectionTitle(theme, 'Stack Tecnológico'),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 10,
                          children: project.techStack.map((tech) => Chip(
                            label: Text(tech),
                            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                            labelStyle: TextStyle(
                              color: theme.colorScheme.primary, 
                              fontWeight: FontWeight.bold,
                              fontSize: 13
                            ),
                            side: BorderSide.none,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          )).toList(),
                        ),
                        const SizedBox(height: 32),
                      ],

                      if (project.documents.isNotEmpty) ...[
                        _buildSectionTitle(theme, 'Documentos'),
                        const SizedBox(height: 12),
                        ...project.documents.map((doc) {
                          final isPdf = doc.type.toLowerCase() == 'pdf';
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: OutlinedButton(
                              onPressed: () => _launchUrl(context, doc.url),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                                side: BorderSide(color: theme.colorScheme.primary),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                foregroundColor: theme.colorScheme.primary,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(isPdf ? Icons.download : Icons.open_in_new, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${doc.title}${isPdf ? " (PDF)" : ""}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                      
                      const SizedBox(height: 140),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // BOTÓN ATRÁS
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8)],
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
              ),
            ),
          ),

          // BOTÓN EVALUAR
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              decoration: BoxDecoration(
                color: theme.colorScheme.background,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [theme.colorScheme.background.withOpacity(0), theme.colorScheme.background],
                  stops: const [0, 0.2],
                ),
              ),
              child: FilledButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EvaluationFormPage(project: project))),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  backgroundColor: theme.colorScheme.primary,
                ),
                child: const Text('Evaluar Proyecto', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title, 
      style: TextStyle(
        fontSize: 18, 
        fontWeight: FontWeight.bold, 
        color: theme.colorScheme.primary,
      )
    );
  }

  Widget _buildStyledCard(ThemeData theme, String title, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
