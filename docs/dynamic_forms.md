# Sistema de Formularios Dinámicos

## 📌 Contexto

Este documento describe cómo se generan, gestionan y rellenan los formularios dinámicos en la aplicación.

Los formularios no están definidos de forma estática, sino que se construyen en tiempo de ejecución a partir de:

- `AssetType`
- `CustomFieldDefinition`

---

## 🧠 Visión General

El formulario se construye dinámicamente en función del tipo de activo (`AssetType`) y sus definiciones de campos.

```text
AssetType.fieldDefinitions
        ↓
CustomFieldDefinition[]
        ↓
UI dinámica (CustomFieldsSectionWidget)