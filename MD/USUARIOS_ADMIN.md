# 🔐 Credenciales de Acceso - PX Forge

Este documento contiene las credenciales de acceso administrativas para el equipo de desarrollo y administración del sistema Kiosco 2026.

## 👥 Usuarios del Equipo

| Nombre | Correo Electrónico | Contraseña | Rol |
| :--- | :--- | :--- | :--- |
| **Isaias** | `isaias@kiosco.com` | `isaias2026` | SuperAdmin |
| **Erick** | `erick@kiosco.com` | `erick2026` | SuperAdmin |
| **Jonathan** | `jonathan@kiosco.com` | `jonathan2026` | SuperAdmin |
| **Lee** | `lee@kiosco.com` | `lee2026` | SuperAdmin |
| **Admin General** | `admin@kiosco.com` | `admin123` | SuperAdmin |

---

## 🛠️ Notas de Seguridad
- Estos usuarios se crean automáticamente al iniciar la aplicación si no existen en la base de datos (vía `DbSeeder.cs`).
- Cada acción realizada por estos usuarios quedará registrada en la **Bitácora de Acciones** con su respectivo correo e IP.
- Se recomienda cambiar las contraseñas una vez los usuarios hayan accedido por primera vez (Funcionalidad pendiente en Roadmap).

## 🚀 Cómo Acceder
1. Ejecutar el servidor (API).
2. Abrir el Dashboard Web.
3. Ingresar las credenciales proporcionadas en la pantalla de "Acceso al Núcleo".
