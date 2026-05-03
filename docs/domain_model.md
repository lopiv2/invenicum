# Modelo de Dominio

## 📌 Contexto

Este documento describe las entidades principales de la aplicación y cómo se estructuran los datos en el sistema.

El objetivo es definir claramente el modelo de datos para desarrollo, mantenimiento y herramientas automatizadas (IA, asistentes de código, etc.).

---

## 🧠 Entidad Principal: InventoryItem

`InventoryItem` es la entidad central de la aplicación.

Representa cualquier elemento dentro del sistema, ya sea:
- Inventario físico
- Objeto coleccionable
- Activo con valor de mercado

---

## 🧩 Estructura General

Un `InventoryItem` está compuesto por:

- Datos básicos
- Identificadores estructurales
- Datos de inventario
- Ubicación
- Imágenes
- Campos personalizados
- Información de mercado
- Historial de precios

---

## 🔑 Campos principales

### Identificación
- `id`
- `name`
- `description`

---

### Relaciones estructurales
- `containerId` → contenedor o colección
- `assetTypeId` → tipo de activo
- `locationId` → referencia a ubicación

---

### Inventario
- `quantity`
- `minStock`

---

### Identificadores físicos
- `barcode`
- `serialNumber`

---

### Estado del item
- `condition` (ej: mint, used, etc.)

---

### Fechas
- `createdAt`
- `updatedAt`

---

## 🖼️ Imágenes

Entidad relacionada: `InventoryItemImage`

Campos:
- `id`
- `url`
- `altText`
- `order`

### Características:
- Lista ordenada de imágenes
- Soporte para múltiples imágenes por item
- Control de orden explícito

---

## 📍 Ubicación

Entidad relacionada: `Location`

- Puede ser null
- Permite organizar físicamente los items

---

## 🧬 Campos personalizados (clave del sistema)

```text
customFieldValues: Map<String, dynamic>