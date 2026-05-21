# State Management

## Contexto

La aplicación utiliza **Provider (ChangeNotifier)** como sistema principal de gestión de estado.

El sistema está diseñado bajo una arquitectura **feature-based modular**, donde cada dominio funcional tiene su propio Provider independiente.

El objetivo es mantener:

- Separación de responsabilidades
- Escalabilidad por features
- Flujo de datos predecible
- Bajo acoplamiento entre módulos

---

## Arquitectura General

```text
┌──────────────────────────────┐
│            UI                │
│  (Screens / Widgets)         │
└─────────────┬────────────────┘
              ↓
┌──────────────────────────────┐
│          PROVIDERS           │
│  (Estado + coordinación)     │
└─────────────┬────────────────┘
              ↓
┌──────────────────────────────┐
│          SERVICES            │
│ (Lógica negocio / API / IO)  │
└─────────────┬────────────────┘
              ↓
┌──────────────────────────────┐
│          BACKEND             │
│ (DB / APIs / persistencia)   │
└──────────────────────────────┘
```

> **Principio clave:** Los Providers NO contienen lógica de negocio compleja. Solo coordinan estado y delegan en Services.

---

## Organización por Features (Providers)

### Core System

| Provider | Responsabilidad |
|---|---|
| `auth` | Login / logout, sesión activa, usuario actual |
| `preferences` | Configuración global del usuario, unidades, moneda, formatos |
| `themes` | Tema visual (light / dark / custom), configuración UI global |
| `first_run` | Estado de onboarding, inicialización de usuario |

### Dominio principal (Inventario)

Este es el núcleo del sistema.

| Provider | Responsabilidad |
|---|---|
| `container` | Estructura jerárquica principal. Contiene AssetTypes, DataLists y Locations. Base organizativa de toda la app |
| `inventory_item` | CRUD de items, estado local, imágenes, campos custom, precios, historial, ubicación |
| `location` | Gestión de ubicaciones físicas o lógicas, relacionado con containers e items |
| `loan` | Sistema de préstamos, control de salida y retorno de items |

### Integraciones y Automatización

| Provider | Responsabilidad |
|---|---|
| `integrations` | Conexión con APIs externas, enriquecimiento de datos (AI + APIs), lookup de barcodes |
| `scraper` | Extracción de datos desde webs, parsing de HTML, conversión a modelo interno |
| `plugin` | Sistema extensible, funcionalidades dinámicas añadidas al runtime |
| `templates` | Plantillas reutilizables, creación rápida de estructuras de datos |

### Experiencia de usuario

| Provider | Responsabilidad |
|---|---|
| `dashboard` | Métricas globales, resumen de inventario, KPIs del sistema |
| `achievements` | Sistema de gamificación, logros del usuario, progresión |
| `alert` | Notificaciones del sistema, eventos importantes, alertas de stock |

---

## Flujo de datos estándar

```
1. Usuario interactúa con UI
2. UI llama a Provider
3. Provider valida estado local
4. Provider delega a Service si es necesario
5. Service ejecuta lógica (API calls, parsing, transformación)
6. Provider recibe resultado
7. Provider actualiza estado interno
8. notifyListeners()
9. UI se reconstruye automáticamente
```

### Flujo real complejo — CREAR ASSET

```
AssetCreateScreen
    ↓
InventoryItemProvider.createInventoryItem()
    ↓
InventoryItemService.createItem()
    ↓
API → Backend guarda item
    ↓
Respuesta con item creado
    ↓
Provider actualiza estado local
    ↓
UI refresca lista / navegación
```

### Flujo de enriquecimiento — AI + Integrations

```
User input (query / barcode / URL)
    ↓
IntegrationsProvider / AIService
    ↓
External API / AI model / scraper
    ↓
Normalización de datos
    ↓
Mapping con custom fields
    ↓
Resultado estructurado
    ↓
Provider aplica datos a UI
```

---

## Gestión de Custom Fields

El sistema soporta campos dinámicos por AssetType:

| Tipo | Descripción |
|---|---|
| `text` | Texto libre |
| `number` | Valor numérico |
| `date` | Fecha |
| `dropdown` | Selección de opciones |
| `boolean` | Verdadero / falso |
| `price` | Valor monetario |
| `url` | Enlace externo |

Cada item guarda:

```dart
customFieldValues: Map<String, dynamic>
```

**Característica clave:**
- Los campos NO están hardcodeados
- Se definen por AssetType
- Se renderizan dinámicamente en UI
- Se mapean automáticamente en imports / AI

---

## Relaciones entre Providers

```
container       →  base estructural de inventory_item
inventory_item  →  núcleo del sistema
integrations    →  alimenta datos a inventory_item
scraper         →  fuente externa de datos
preferences     →  afecta cálculo y visualización
themes          →  afecta UI global
```

---

## Responsabilidades por capa

### UI (Flutter)

- ✅ Renderizar estado
- ✅ Recoger input
- ✅ Llamar a Providers
- ❌ NO lógica de negocio
- ❌ NO llamadas API directas

### Provider

- ✅ Estado reactivo
- ✅ Coordinación de acciones
- ✅ Validación ligera
- ✅ Delegación a Services
- ❌ NO lógica compleja
- ❌ NO parsing pesado
- ❌ NO acceso directo a backend

### Services

- ✅ Lógica de negocio
- ✅ API calls
- ✅ Parsing de respuestas
- ✅ Transformación de datos
- ❌ NO estado UI
- ❌ NO widgets

---

## Reglas de arquitectura

1. **Un Provider = un dominio.** No mezclar responsabilidades.
2. **Services son la única fuente externa.** Toda API o scraping pasa por Services.
3. **UI nunca accede a backend directamente.**
4. **Provider es la fuente de verdad del frontend.**
5. **Estado es siempre reactivo.**

```dart
notifyListeners();
```

---

## Escalabilidad del sistema

Este diseño permite:

- Añadir features sin romper las existentes
- Separar dominios sin dependencias fuertes
- Testear providers individualmente
- Sustituir backend sin tocar UI
- Escalar a sistema multi-módulo (plugin-ready)

---

## Resumen

| Capa | Rol |
|---|---|
| UI | Capa reactiva pura |
| Provider | Orquestador de estado |
| Service | Lógica de negocio |
| Backend | Persistencia |