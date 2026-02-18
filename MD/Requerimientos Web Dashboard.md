# **Documento de Especificación de Requerimientos de Software (SRS)** 
## **Proyecto: Web Dashboard Administrativo (Backend Kiosco)** 
**Versión:** 1.5 (Ajuste Stack MERN & Reglas de Negocio) 

**Fecha:** 10 de Febrero de 2026 

**Tecnología:** Stack MERN (MongoDB, Express, React + Tailwind, Node.js) 

**Alcance:** Este documento define las funciones y la interfaz para el administrador, garantizando la coherencia visual con la App Kiosco (Flutter). 
1. ## **Estándares de UI y Sistema de Diseño** 
Para garantizar que el Dashboard se sienta parte del mismo ecosistema que la App Móvil: 



|**Concepto** |**Especificación Técnica** |
| - | - |
|**Paleta de Colores** |tailwind.config.js debe replicar los colores primarios/secundarios de la App Flutter. |
|**Tipografía** |Utilizar la misma familia tipográfica (ej. Roboto, Inter) que la App Móvil. |
|**Iconografía** |Librería lucide-react o heroicons (equivalentes a Material Icons). |
|**Bordes** |rounded-lg o rounded-xl consistente. |
2. ## **Requerimientos Funcionales y de Interfaz (RF + UI)** 
### **Módulo 0: Estructura General** 


|**ID** |**Requerimiento** |**Prioridad** |
| - | - | - |
|**RF-UI-01** |**Sidebar de Navegación:** |Alta |



||Barra lateral izquierda fija. Menú para: Proyectos, Encuesta, Resultados, Configuración. ||
| :- | :- | :- |
|**RF-UI-02** |**TopBar:** Barra superior minimalista con Breadcrumbs y perfil de usuario. |Media |
### **Módulo 1: Gestión de Proyectos (Catálogo)** 


|**ID** |**Requerimiento** |**Prioridad** |
| - | - | - |
|**RF-UI-03** |**Tabla de Datos (Data Table):** Vista principal con columnas: *Imagen, Nombre, Categoría, Estatus (Activo/Inactivo), Acciones*. |Alta |
|**RF-WEB-01** |**Formulario por Pasos:** Alta/Edición organizada en pestañas: General, Multimedia, Documentos. |Alta |
|**RF-WEB-04** |<p>**Gestión de Estatus (Soft Delete):** Los proyectos NO se eliminan físicamente de la base de datos si tienen votos. Se implementa un interruptor o botón de "Archivar/Desactivar". </p><p>- **Activo:** Visible en la App Móvil. </p><p>- **Inactivo:** Oculto en la App, pero sus datos y votos históricos se conservan en el Dashboard. </p>|Crítica |



|**RF-WEB-03** |**Gestión de Documentos (MongoDB):** Subida de PDFs. El sistema guardará el archivo en el servidor/cloud y almacenará la referencia (URL) en el documento del proyecto en MongoDB. |Media |
| - | :- | - |
|**RF-WEB-04b** |**Ficha PDF:** Botón en la fila de tabla para descargar la ficha de stand con el QR generado. |Alta |
### **Módulo 2: Constructor de Evaluaciones (Survey Builder)** 


|**ID** |**Requerimiento** |**Prioridad** |
| - | - | - |
|**RF-UI-06** |**Mobile Preview:** Panel derecho que renderiza componentes React (<MobileCard />) imitando la UI de Flutter en tiempo real. |Crítica |
|**RF-WEB-05** |**Gestión Dinámica (JSON):** Interfaz para crear secciones y preguntas. Al guardar, el backend genera un documento JSON que se almacena en una colección templates de MongoDB. |Alta |
|**RF-WEB-07** |**Bloqueo de Integridad:** Si el evento tiene votos registrados, se bloquea la adición/eliminación de preguntas. Solo se permite editar textos (typos). |Crítica |



|**RF-WEB-08** |**Versionado:** Cada guardado incrementa la versión (v1.1, v1.2). |Alta |
| - | :- | - |
### **Módulo 3: Control de Evento y Resultados** 


|**ID** |**Requerimiento** |**Prioridad** |
| - | - | - |
|**RF-UI-07** |**Dashboard Home:** Tarjetas KPI (Votos Totales, Proyectos Activos). |Alta |
|**RF-WEB-16** |**Control Maestro de Votación:** Interruptor global "Recibir Votos" (ON/OFF). |Crítica |
|**RF-WEB-11** |**Control Ranking Público:** Interruptor global "Mostrar Resultados en App" (ON/OFF). |Alta |
|**RF-WEB-12** |**Ranking en Vivo:** Tabla interna de resultados ordenados por promedio. |Alta |
### **Módulo 4: Reportes y Feedback** 


|**ID** |**Requerimiento** |**Prioridad** |
| - | - | - |
|**RF-WEB-19** |<p>**Centro de Descargas** </p><p>**PDF:** Panel para generar los reportes de retroalimentación individuales por proyecto (Calificación + Comentarios Privados). </p>|Alta |
### **Módulo 5: Configuración** 


|**ID** |**Requerimiento** |**Prioridad** |
| - | - | - |
|**RF-WEB-17** |**Branding:** Carga de Logo del Evento y Nombre. |Media |
|**RF-WEB-15** |**Logs de Auditoría:** Tabla de historial de cambios. |Alta |
## **2. Requerimientos No Funcionales (RNF)** 


|**ID** |**Requerimiento** |**Descripción** |
| - | - | - |
|**RNF-WEB-05** |**Estrategia de Base de Datos** |Uso de **MongoDB** (NoSQL). Las evaluaciones se almacenarán como documentos anidados o relacionados, aprovechando la flexibilidad del esquema JSON para las preguntas dinámicas. |
|**RNF-WEB-01** |**Responsive Desktop** |Optimizado para >1024px. |
|**RNF-WEB-03** |**Feedback Visual** |Uso de Toasts (Verde/Rojo) para confirmar acciones. |

