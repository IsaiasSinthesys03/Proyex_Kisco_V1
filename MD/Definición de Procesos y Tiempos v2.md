# **Definición de Procesos Operativos y Tiempos Estándar (Actualizado)** 
**Proyecto:** App Kiosco de Evaluación (Flutter) **Versión:** 2.1 (Formato Corregido) 

**Objetivo:** Validar que el nuevo flujo de "10 Preguntas" sea viable en un entorno de evento con tiempo limitado. 
1. ## **Proceso de Evaluación Completa (Flujo Principal)** 
Este proceso describe el camino desde que el evaluador decide calificar hasta que envía los datos. 



|**Paso** |**Acción del Usuario** |**Respuesta del Sistema (App)** |**Tiempo Estimado (Usuario)** |
| - | :- | - | :- |
|**1** |Escanea QR o Selecciona Proyecto. |Valida UUID y abre Pantalla de Evaluación (Carga Plantilla JSON). |2 seg |
|**2** |Visualiza la **Sección 1: Propuesta** (Preguntas 1-3). Lee y selecciona 3 respuestas. |**Autoguardado:** Cada toque guarda el estado en LocalStorage (Draft). |20 - 30 seg |
|**3** |Hace scroll a **Sección 2: Técnica** (Preguntas 4-7). Lee y selecciona 4 respuestas. |**Autoguardado:** Continúa actualizando el borrador. |30 - 45 seg |
|**4** |Hace scroll a **Sección 3: Comunicación** (Preguntas 8-10). Lee y selecciona 3 |**Autoguardado:** Continúa actualizando el borrador. |20 - 30 seg |



||respuestas. |||
| :- | - | :- | :- |
|**5** |(Opcional) Escribe un comentario de retroalimentación. |Valida longitud (Máx 280 chars) en tiempo real. |15 - 30 seg |
|**6** |Presiona botón **"Enviar Evaluación"**. |Valida completitud (10/10)  ![ref1] Envía a API ![ref1] Limpia Borrador. |1 seg |
|**7** |Ve modal de éxito y presiona "Aceptar". |Redirige a la ficha y bloquea la interfaz. |2 seg |
|**TOTAL** |||**~ 1.5 a 2.5 Minutos** |

**Análisis de Impacto:** El tiempo subió de 30 segundos (modelo anterior) a **2 minutos promedio**. Esto es aceptable para una evaluación seria, pero implica que un juez solo podrá evaluar unos 15-20 proyectos por hora. 
2. ## **Proceso de Recuperación de Borrador (Resiliencia)** 
Este flujo ocurre si el usuario cierra la App por error a mitad de la evaluación o si el sistema crashea. 



|**Paso** |**Acción del Usuario** |**Respuesta del Sistema (App)** |**Tiempo Sistema** |
| - | :- | - | - |
|**1** |Vuelve a abrir la App y entra al mismo proyecto. |<p>1. Detecta clave draft\_eval\_{id} en LocalStorage. </p><p>2. Compara versión de plantilla. </p><p>3. **Restaura** las estrellas marcadas previamente. </p>|< 0.5 seg |
|**2** |El usuario ve sus respuestas anteriores ya |Muestra SnackBar: *"Tu progreso anterior ha sido* |Inmediato |



||marcadas. |*restaurado"*. ||
| :- | - | - | :- |
|**3** |Continúa evaluando donde se quedó. ||N/A |
3. ## **Proceso de Edición (Corrección de Voto)** 
El usuario se da cuenta de un error después de enviar. 



|**Paso** |**Acción del Usuario** |**Respuesta del Sistema (App)** |**Tiempo Estimado** |
| - | :- | - | - |
|**1** |En la ficha del proyecto (ya evaluado), presiona **"Editar Evaluación"**. |Recupera el voto enviado desde la BD Local y pre-llena el cuestionario. |1 seg |
|**2** |Cambia la respuesta de la Pregunta X (de 5 estrellas a 3 estrellas). |Actualiza el estado visual. |5 seg |
|**3** |Presiona **"Actualizar"**. |Envía PUT /evaluate, actualiza el registro local y reinicia el timer de 30 min. |1 seg |
|**TOTAL** |||**~ 10 segundos** |
## **Métricas de Rendimiento Técnico (KPIs)** 
Para garantizar que la App se sienta fluida a pesar de manejar formularios más grandes: 

1. **Tiempo de Carga del Formulario:** < 1 segundo (La plantilla JSON debe estar cacheada). 
1. **Latencia de Autoguardado:** La escritura en LocalStorage debe ser asíncrona y no bloquear la UI (no debe sentirse "lag" al tocar una estrella). 
1. **Feedback de Validación:** Si el usuario intenta enviar con 9/10 preguntas, la App debe hacer **Scroll Automático** a la pregunta faltante en < 500ms. 

[ref1]: Aspose.Words.16decb0e-f79d-40d6-8582-d6385abaa287.001.png
