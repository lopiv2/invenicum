# Flujo de Datos

## 📌 Contexto

Este documento describe cómo fluye la información dentro de la aplicación, desde la interacción del usuario hasta la actualización de la UI, incluyendo Providers, Services y Backend.

Está diseñado para servir como referencia tanto para desarrollo como para herramientas automatizadas (IA, asistentes de código, etc.).

---

## 🧠 Visión General

La aplicación sigue un flujo unidireccional de datos con separación clara de capas:

UI → Provider → Service → Backend → Service → Provider → UI

---

## 🔄 Flujo Principal

```text
Usuario interactúa con la UI
        ↓
Screen / Widget detecta la acción
        ↓
Llamada a Provider
        ↓
Provider ejecuta lógica básica y delega
        ↓
Service procesa la operación
        ↓
(Si aplica) llamada a Backend
        ↓
Backend ejecuta lógica y devuelve respuesta
        ↓
Service transforma/valida datos
        ↓
Provider actualiza estado
        ↓
UI se reconstruye automáticamente