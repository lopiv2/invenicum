import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:invenicum/models/integration_field_type.dart';

class IntegrationConfigSheet extends StatefulWidget {
  final IntegrationModel integration;

  const IntegrationConfigSheet({super.key, required this.integration});

  @override
  State<IntegrationConfigSheet> createState() => _IntegrationConfigSheetState();
}

class _IntegrationConfigSheetState extends State<IntegrationConfigSheet> {
  final Map<String, dynamic> _configValues = {};

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24, right: 24, top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(widget.integration.icon, size: 32, color: Colors.blue),
              const SizedBox(width: 12),
              Text(widget.integration.name, style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
          const SizedBox(height: 8),
          Text(widget.integration.description, style: TextStyle(color: Colors.grey[600])),
          const Divider(height: 32),
          
          // Generador dinámico de campos
          ...widget.integration.fields.map((field) {
            if (field.type == IntegrationFieldType.text) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: field.label,
                    helperText: field.helperText,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (val) => _configValues[field.id] = val,
                ),
              );
            }
            // Puedes añadir más tipos aquí (Switch para booleans, etc.)
            return const SizedBox.shrink();
          }).toList(),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                // Aquí guardarías _configValues en tu base de datos o Provider
                print("Guardando configuración para ${widget.integration.id}: $_configValues");
                Navigator.pop(context);
              },
              child: const Text("GUARDAR CONFIGURACIÓN"),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}