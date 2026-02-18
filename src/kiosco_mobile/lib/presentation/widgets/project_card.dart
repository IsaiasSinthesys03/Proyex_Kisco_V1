import 'package:flutter/material.dart';
import '../../data/models/project_model.dart';
import '../pages/project_detail_page.dart';

class ProjectCard extends StatelessWidget {
  final ProjectModel project;

  const ProjectCard({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectDetailPage(project: project),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          // Sombra suave estilo Figma
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen de Portada (Ocupa la mayor parte de la tarjeta)
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  project.coverImageUrl != null && project.coverImageUrl!.isNotEmpty
                        ? Image.network(
                            project.coverImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.image_not_supported_outlined, 
                                    size: 30, 
                                    color: Theme.of(context).colorScheme.outline
                                  ),
                                  const SizedBox(height: 4),
                                  Text('Imagen no disponible', 
                                    style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.outline)
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Container(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            child: Icon(Icons.image, size: 40, color: Theme.of(context).colorScheme.outline),
                          ),
                    
                    // Badge de Categoría Flotante (Top Left)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(context, project.category),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          project.category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
  
                    // Logo del Proyecto (Bottom Left overlay)
                    if (project.iconUrl != null)
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 2),
                            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                          ),
                          child: ClipOval(
                            child: Image.network(
                              project.iconUrl!, 
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Theme.of(context).colorScheme.surface,
                                child: Icon(Icons.business, size: 20, color: Theme.of(context).colorScheme.primary),
                              ),
                            ),
                          ),
                        ),
                      ),
                ],
              ),
            ),
            
            // Información del Proyecto
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w800, 
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Nombre de la Empresa o Autor (Texto secundario/verde opaco)
                  Text(
                    project.companyName ?? 'Equipo Independiente', // Asumo que el modelo tiene este campo o similar
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary, // Usa el color primary para el autor
                      fontSize: 12,
                      fontWeight: FontWeight.w500
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(BuildContext context, String category) {
    // Colores específicos por categoría según diseño, fallback al primary
    switch (category.toLowerCase()) {
      case 'gaming': return const Color(0xFF2E7D32); // Verde oscuro gaming
      case 'software': return const Color(0xFF1B5E20); // Verde corporativo
      case 'urbano': return const Color(0xFF00695C); // Teal
      case 'social': return const Color(0xFF558B2F); // Light Green
      case 'salud': return const Color(0xFF2E7D32);
      case 'ambiente': return const Color(0xFF43A047); 
      default: return Theme.of(context).colorScheme.primary;
    }
  }
}
