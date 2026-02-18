# **Documento de Especificación de Requerimientos de Software (SRS)** 
## **Proyecto: Aplicación Móvil de Evaluación (Cliente Kiosco)** 
**Versión:** 5.2 (Ajuste Stack MongoDB & Estatus Proyecto) 

**Fecha:** 10 de Febrero de 2026 

**Tecnología:** Flutter (Frontend) + Node/Express/MongoDB (Backend) **Alcance:** Definición de requerimientos para la App Móvil. 
1. ## **Requerimientos Funcionales del Frontend (App Móvil Flutter)** 
   ### **Módulo 1: Descubrimiento y Navegación** 
 

|**ID** |**Requerimiento** |**Prioridad** |
| - | - | - |
|**RF-FRONT-01** |**Galería Visual:** Grid de tarjetas con los proyectos obtenidos del API. Solo muestra proyectos activos. |Alta |
|**RF-FRONT-02** |**Buscador Predictivo:** Filtrado local por Título o ID. |Alta |
|**RF-FRONT-03** |**Filtros por Categoría:** Chips de filtrado. |Media |
|**RF-FRONT-04** |**Feedback Búsqueda Vacía:** Ilustración y texto cuando no hay resultados. |Alta |
|**RF-FRONT-05** |**Navegación Inferior:** BottomNavigationBar (Proyectos / Ranking). |Alta |



|**RF-FRONT-06** |**Cambio de Tema:** Toggle Dark/Light Mode. |Baja |
| - | :- | - |
### **Módulo 2: Ficha del Proyecto** 


|**ID** |**Requerimiento** |**Prioridad** |
| - | - | - |
|**RF-FRONT-07** |**Acceso QR:** Deep Linking kiosco://project/{id}. |Alta |
|**RF-FRONT-08** |**Cabecera Hero:** Imagen/Video al 35% de altura. |Alta |
|**RF-FRONT-09** |**Info Identidad:** Icono, Título, Equipo. |Alta |
|**RF-FRONT-10** |**Descripción:** Texto completo con scroll (sin botón "ver más"). |Alta |
|**RF-FRONT-26** |**Documentos:** Botones para descargar PDFs/Links si existen. |Media |
### **Módulo 3: Interfaz de Evaluación (Dinámica)** 


|**ID** |**Requerimiento** |**Prioridad** |
| - | - | - |
|**RF-FRONT-11** |**Cuestionario Dinámico:** Renderizado basado en JSON (GET /evaluation-template). Pantalla dedicada por secciones. |Alta |
|**RF-FRONT-11b** |**Validación Completitud:** Botón "Enviar" deshabilitado hasta responder todo. |Alta |



|**RF-FRONT-11c** |**Salida Segura:** Botón "Cerrar" con alerta de "Guardar Borrador". |Alta |
| - | - | - |
|**RF-FRONT-11d** |**Manejo Errores:** Reintento si falla la carga de la plantilla. |Alta |
|**RF-FRONT-12** |**Comentario Privado:** Campo opcional de texto con aviso de privacidad. |Media |
|**RF-FRONT-13** |**Contador Caracteres:** Límite 280 chars. |Alta |
|**RF-FRONT-14** |**Feedback Envío:** Modal "Gracias" y redirección a ficha. |Alta |
### **Módulo 4: Lógica de Negocio (Kiosco Seguro)** 


|**ID** |**Requerimiento** |**Prioridad** |
| - | - | - |
|**RF-FRONT-15** |**Persistencia Voto:** Registro local de "Voto Completado". |Crítica |
|**RF-FRONT-16** |**Bloqueo Interfaz:** Si ya votó, ocultar formulario. |Alta |
|**RF-FRONT-17** |**Edición Condicional:** Botón "Editar" si tiempo < 30 min. |Alta |
|**RF-FRONT-18** |**Modo Offline:** Cola de envío local si no hay red. |Alta |
|**RF-FRONT-22** |**Autoguardado Borrador:** Guardar respuestas en LocalStorage al tocar. |Crítica |
|**RF-FRONT-23** |**Recuperación Sesión:** |Alta |



||Restaurar borrador si existe y versión coincide. ||
| :- | :- | :- |
|**RF-FRONT-24** |**Limpieza Borrador:** Borrar tras envío exitoso. |Alta |
|**RF-FRONT-25** |**Edición Compleja:** Cargar respuestas previas al editar. |Alta |
### **Módulo 5: Ranking** 


|**ID** |**Requerimiento** |**Prioridad** |
| - | - | - |
|**RF-FRONT-19** |**Pantalla Espera:** Mensaje si ranking\_visible: false. |Alta |
|**RF-FRONT-20** |**Listado Resultados:** ListView ordenado por promedio. |Alta |
|**RF-FRONT-21** |**Detalle Ranking:** Solo muestra Calificación Final (Sin comentarios). |Media |
2. ## **Requerimientos Funcionales del Backend (API - Node/Express)** 
   ### **Gestión de Datos** 
 

|**ID** |**Requerimiento** |**Prioridad** |
| - | - | - |
|**RF-BACK-01** |**Catálogo Filtrado (GET /projects):** Retorna lista de proyectos donde status: "active". Los proyectos archivados/inactivos se excluyen de la respuesta JSON para la App. |Alta |



|**RF-BACK-02** |**Detalle Proyecto:** Retorna info completa + documentos. |Alta |
| - | :- | - |
|**RF-BACK-08** |**Plantilla Evaluación:** Retorna JSON de encuesta con versión. |Alta |
|**RF-BACK-10** |**Seeding:** Inyección inicial de las 10 preguntas estándar en MongoDB. |Alta |
|**RF-BACK-03** |**Ranking:** Endpoint condicional según flag de autorización. |Alta |
### **Procesamiento** 


|**ID** |**Requerimiento** |**Prioridad** |
| - | - | - |
|**RF-BACK-05** |**Recepción Voto:** Guarda documento en colección evaluations con referencia al project\_id. |Alta |
|**RF-BACK-04** |**Cálculo Promedios:** Agregación (MongoDB Aggregation Pipeline) para calcular promedios en tiempo real. |Alta |
|**RF-BACK-06** |**Actualización Voto:** Permite modificar documento si tiempo < 30 min. |Alta |
|**RF-BACK-07** |**Anti-Spam:** Rate limiting por UUID. |Media |
3. ## **Requerimientos No Funcionales (RNF)** 


|**ID** |**Requerimiento** |**Descripción** |
| - | - | - |
|**RNF-01** |**Diseño Vertical** |Optimizado para móviles. |
|**RNF-02** |**Estética Visual** |Material Design 3. |
|**RNF-04** |**Performance** |API < 500ms. MongoDB debe tener índices en project\_id y uuid. |
|**RNF-07** |**Anonimato** |UUID local. |
|**RNF-09** |**Compatibilidad** |Android/iOS. |
4. ## **Matriz de Preguntas (Seeding)** 
*Las 10 preguntas estándar se cargan inicialmente en la colección templates de MongoDB.* **Sección A: Propuesta de Valor** (Q1-Q3) 

**Sección B: Ejecución Técnica** (Q4-Q7) 

**Sección C: Comunicación** (Q8-Q10) 
