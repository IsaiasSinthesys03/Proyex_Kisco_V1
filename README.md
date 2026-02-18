# Kiosco de Evaluación de Proyectos - Backend

## Descripción
Backend para el sistema de Kiosco de Evaluación, construido con **ASP.NET Core 8 Web API** y **MongoDB**.
Implementa **Clean Architecture** y **Domain-Driven Design (DDD)**.

## Arquitectura
La solución sigue la estructura:
- `src/Kiosco.Domain`: Entidades del núcleo y lógica de negocio pura.
- `src/Kiosco.Application`: Casos de uso, DTOs, validaciones e interfaces.
- `src/Kiosco.Infrastructure`: Implementación de repositorios, acceso a datos (MongoDB) y servicios externos.
- `src/Kiosco.API`: Controladores REST, configuración de inyección de dependencias y SignalR Hubs.

## Requisitos Previos
- .NET SDK 8.0
- MongoDB (Local o Atlas)

## Configuración Inicial
1. Clonar el repositorio.
2. Navegar a la carpeta `src/Kiosco.API`.
3. Ejecutar `dotnet run`.
   - Por defecto, la API escuchará en `http://localhost:5000` (o el puerto configurado en `launchSettings.json`).

## Entidades Principales
- **User**: Gestión de administradores.
- **Project**: Catálogo de proyectos a evaluar.
- **EvaluationTemplate**: Definición dinámica de preguntas.
- **Evaluation**: Votos y respuestas de los usuarios.
- **GlobalSettings**: Configuración del evento (votación activa, ranking público).

## Seguridad
- **JWT**: Para el Dashboard Web.
- **KioskAuth**: Filtro personalizado para la App Móvil (UUID).
