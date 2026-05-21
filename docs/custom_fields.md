# Sistema de Campos Personalizados

## 📌 Contexto

Este documento describe el sistema de campos personalizados que permite a la aplicación adaptarse a distintos tipos de inventarios y colecciones.

Este sistema es el núcleo que convierte la app en un **inventario universal**, permitiendo definir estructuras de datos dinámicas sin necesidad de modificar el código base.

---

## 🧠 Visión General

El sistema se basa en dos elementos principales:

1. **Definición del campo** → `CustomFieldDefinition`
2. **Valor del campo** → `customFieldValues` en `InventoryItem`

---

## 🧩 Relación entre entidades

```text
CustomFieldDefinition (define el campo)
            ↓
InventoryItem.customFieldValues (almacena el valor)