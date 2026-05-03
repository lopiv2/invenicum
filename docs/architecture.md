## 📌 Contexto

Este documento describe la arquitectura general de la aplicación Flutter y sirve como guía para desarrollo y herramientas automatizadas (IA, asistentes de código, etc.).

# Arquitectura de la Aplicación

## Visión General

Esta aplicación es un sistema de inventario universal diseñado para gestionar tanto inventarios como colecciones personalizadas.

Permite:

* Crear estructuras de datos flexibles
* Añadir campos personalizados
* Gestionar imágenes
* Definir ubicaciones
* Crear listas de datos adaptadas a distintos casos de uso

La arquitectura sigue un enfoque modular basado en separación de responsabilidades entre UI, estado, lógica de negocio y comunicación con backend.

---

## Estructura General

```
lib/
  screens/
  widgets/
  providers/
  services/
  models/
```

---

## Navegación

La navegación está implementada mediante `go_router`.

### Características:

* Sistema de rutas declarativo
* Soporte para navegación estructurada
* Escalabilidad para nuevas pantallas

### Flujo:

1. El usuario navega entre pantallas
2. `go_router` gestiona la transición y renderizado

---

## Layout Principal

La aplicación utiliza una estructura base compuesta por:

* **Sidebar (Tree View)**
  Permite navegar por la jerarquía de datos (inventarios, colecciones, etc.)

* **Área de contenido central**
  Renderiza dinámicamente la pantalla seleccionada

### Comportamiento:

* El sidebar actúa como punto principal de navegación
* El contenido cambia en función del contexto seleccionado

---

## Gestión de Estado

Se utiliza el patrón basado en `Provider`.

### Responsabilidades:

#### Providers

* Mantienen el estado de la aplicación
* Exponen datos a la UI
* Orquestan llamadas a servicios

#### Ejemplo de flujo:

1. La UI solicita una acción (ej: crear elemento)
2. Se llama a un método del Provider
3. El Provider delega en un Service

---

## Servicios (Services)

Los servicios contienen la lógica de negocio y actúan como capa intermedia entre los Providers y el backend.

### Responsabilidades:

* Procesar datos
* Ejecutar lógica de aplicación
* Gestionar llamadas HTTP al backend (si aplica)

---

## Backend

El backend expone endpoints que realizan operaciones de negocio y persistencia.

### Flujo:

1. Service llama a endpoint
2. Backend procesa la solicitud
3. Devuelve respuesta estructurada
4. Service transforma si es necesario
5. Provider actualiza estado
6. UI se reconstruye

---

## Flujo de Datos Completo

```
UI (Screens / Widgets)
        ↓
Provider (gestión de estado)
        ↓
Service (lógica de negocio)
        ↓
Backend (API / persistencia)
        ↓
Service
        ↓
Provider
        ↓
UI
```

---

## Modelo de Datos

La aplicación soporta estructuras dinámicas:

* Campos personalizados
* Tipos de datos variables
* Relaciones entre elementos
* Listas configurables por el usuario

Esto permite adaptarse a múltiples escenarios:

* Inventarios físicos
* Colecciones (libros, figuras, etc.)
* Bases de datos personalizadas

---

## Principios Clave

* Separación clara de responsabilidades
* UI desacoplada de la lógica de negocio
* Providers como única fuente de verdad en el frontend
* Servicios como capa de abstracción
* Backend como gestor de persistencia y lógica compleja

---

## Escalabilidad

La arquitectura permite:

* Añadir nuevas pantallas fácilmente
* Extender Providers sin afectar la UI
* Incorporar nuevos endpoints sin romper el sistema
* Adaptar el modelo de datos a nuevos tipos de inventario

---

## Notas

* La lógica de negocio no debe implementarse en la UI
* Los Providers no deben contener lógica compleja (delegar en Services)
* Los Services deben ser reutilizables y testeables
