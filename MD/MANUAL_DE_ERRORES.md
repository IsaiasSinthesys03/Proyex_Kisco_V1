# 📕 Manual de Errores y Excepciones - Sistema Kiosko

Este documento detalla la estructura de errores del sistema, los códigos utilizados y su significado para facilitar la integración entre el Backend, la Web y la App Móvil.

## 🏗️ Estructura de Respuesta de Error (Backend)

Todas las excepciones capturadas por el servidor devuelven un objeto JSON con el siguiente formato:

```json
{
  "statusCode": 400,
  "errorCode": "VALIDATION_ERROR",
  "message": "Descripción amigable del error para el usuario.",
  "detail": "StackTrace (solo en modo Desarrollo)",
  "timestamp": "2026-02-17T11:30:00Z"
}
```

---

## 📋 Catálogo de Códigos de Error

### 400 Bad Request (Petición Incorrecta)
Se utiliza cuando la petición del cliente no es válida o viola reglas de negocio.

| ErrorCode | Descripción | Causa Común |
| :--- | :--- | :--- |
| `VALIDATION_ERROR` | Los datos enviados no cumplen con los requisitos. | Título de proyecto muy corto, campos obligatorios vacíos. |
| `BUSINESS_RULE_VIOLATION` | Se intentó realizar una acción prohibida por la lógica del negocio. | Intentar eliminar un proyecto que ya tiene votos. |
| `DATA_INTEGRITY_ERROR` | Los datos causarían inconsistencia. | Intentar crear un duplicado de un registro único. |
| `INVALID_ARGUMENT` | Un parámetro de la URL o Query es inválido. | ID de proyecto con formato incorrecto. |

### 401 Unauthorized (No Autorizado)
| ErrorCode | Descripción | Causa Común |
| :--- | :--- | :--- |
| `UNAUTHORIZED_ACCESS` | Se requiere autenticación para acceder. | Token de administrador expirado o ausente. |

**Manejo Automático**: El Frontend detecta este estado y redirige al usuario al Login automáticamente para garantizar la seguridad.

### 403 Forbidden (Prohibido)
| ErrorCode | Descripción | Causa Común |
| :--- | :--- | :--- |
| `ACCESS_DENIED` | El usuario no tiene permisos suficientes. | Intento de un evaluador de acceder a rutas de administración. |

### 404 Not Found (No Encontrado)
| ErrorCode | Descripción | Causa Común |
| :--- | :--- | :--- |
| `RESOURCE_NOT_FOUND` | El recurso solicitado no existe. | Proyecto con ID inexistente, plantilla de evaluación no activa. |
| `KEY_NOT_FOUND` | Una clave de configuración no fue hallada. | Error en appsettings o base de datos. |

### 500 Internal Server Error (Error del Servidor)
| ErrorCode | Descripción | Causa Común |
| :--- | :--- | :--- |
| `INTERNAL_SERVER_ERROR` | Error inesperado en el servidor. | Error de conexión con MongoDB, fallo de hardware. |

---

## 📱 Manejo de Errores en Frontend (Web Admin Premium)

### Sistema de Diálogos Industrial:
Ya no se utilizan alertas nativas del navegador (`alert`, `confirm`). Todo error o interacción se maneja mediante el **Sistema de Modales de PX Forge**:

1. **Alertas de Error**: Modales con borde rojo y título "Fallo Crítico" o "Error de Validación".
2. **Confirmación de Acciones**: Modales de doble paso para acciones destructivas (Eliminar, Limpiar Almacenamiento).
3. **Captura de Inputs (Prompts)**: Modales integrados para añadir enlaces externos o nombres rápidos.

### Ejemplo de Procesamiento Seguro:

```javascript
try {
  const response = await fetch(url, {
    headers: { 'Authorization': `Bearer ${token}` }
  });
  
  if (response.status === 401) {
    logout(); // Seguridad reactiva
    return;
  }
  
  if (!response.ok) throw new Error("Mensaje de servidor");
} catch (err) {
  setDialog({
    show: true,
    title: 'Fallo Crítico',
    message: err.message,
    type: 'alert'
  });
}
```

---

*Última actualización: 17 de Febrero de 2026*
