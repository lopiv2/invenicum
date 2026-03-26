import 'package:flutter/material.dart';
import 'package:invenicum/core/utils/common_functions.dart';
import 'package:invenicum/providers/integrations_provider.dart';
import 'package:invenicum/data/services/toast_service.dart';
import 'package:provider/provider.dart';
import 'package:invenicum/data/models/integration_field_type.dart';
import 'package:invenicum/l10n/app_localizations.dart';

class IntegrationConfigSheet extends StatefulWidget {
  final IntegrationModel integration;

  const IntegrationConfigSheet({super.key, required this.integration});

  @override
  State<IntegrationConfigSheet> createState() => _IntegrationConfigSheetState();
}

class _IntegrationConfigSheetState extends State<IntegrationConfigSheet> {
  // Mapa para gestionar los controladores de cada campo dinámico
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _obscureTextMap = {};
  final Map<String, String?> _dropdownValues = {};
  bool _isIdLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  Future<void> _initializeFields() async {
    // 1. Creamos los controladores para cada campo definido en el modelo
    for (var field in widget.integration.fields) {
      _controllers[field.id] = TextEditingController();
      if (field.type == IntegrationFieldType.password) {
        _obscureTextMap[field.id] = true;
      }
      if (field.type == IntegrationFieldType.dropdown &&
          field.options.isNotEmpty) {
        _dropdownValues[field.id] = field.options.first;
      }
    }

    // 2. Cargamos los datos guardados del backend mediante el Provider
    final provider = context.read<IntegrationProvider>();
    final savedConfig = await provider.getConfig(widget.integration.id);

    if (savedConfig != null) {
      savedConfig.forEach((key, value) {
        if (_controllers.containsKey(key)) {
          _controllers[key]!.text = value.toString();
        }
        // Si el campo es dropdown, restauramos el valor guardado
        if (_dropdownValues.containsKey(key)) {
          final savedValue = value.toString();
          final field = widget.integration.fields.firstWhere(
            (f) => f.id == key,
            orElse: () => widget.integration.fields.first,
          );
          if (field.options.contains(savedValue)) {
            _dropdownValues[key] = savedValue;
          }
        }
      });
    }

    if (mounted) {
      setState(() => _isIdLoading = false);
    }
  }

  @override
  void dispose() {
    // Es vital limpiar los controladores para evitar fugas de memoria
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLinked = context.watch<IntegrationProvider>().isLinked(
      widget.integration.id,
    );
    return Container(
      // Aplicamos un decorado para que se vea bien el redondeado superior
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(
          context,
        ).viewInsets.bottom, // Evita que el teclado tape el botón
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Cabecera ---
          Row(
            children: [
              SizedBox(width: 32, height: 32, child: widget.integration.icon),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.integration.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              InkWell(
                onTap: () => AppUtils.launchUrlWeb('https://boardgamegeek.com'),
                child: widget.integration.image ?? Container(),
              ),
              if (_isIdLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.integration.description,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const Divider(height: 32),
          // --- Campos Dinámicos ---
          if (_isIdLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text("Cargando configuración...")),
            )
          else
            ...widget.integration.fields.map((field) {
              final bool isPassword =
                  field.type == IntegrationFieldType.password;
              final bool isDropdown =
                  field.type == IntegrationFieldType.dropdown;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isDropdown) ...[
                      DropdownButtonFormField<String>(
                        value: _dropdownValues[field.id],
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: field.label,
                          helperText: field.helperText,
                          border: const OutlineInputBorder(),
                        ),
                        items: field.options
                            .map(
                              (opt) => DropdownMenuItem(
                                value: opt,
                                child: Text(opt),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            _dropdownValues[field.id] = val;
                            // También actualizamos el controller para que
                            // _handleSave lo recoja igual que los demás campos
                            _controllers[field.id]?.text = val ?? '';
                          });
                        },
                      ),
                    ] else ...[
                      TextFormField(
                        controller: _controllers[field.id],
                        obscureText: isPassword
                            ? (_obscureTextMap[field.id] ?? true)
                            : false,
                        decoration: InputDecoration(
                          labelText: field.label,
                          helperText: field.helperText,
                          border: const OutlineInputBorder(),
                          suffixIcon: isPassword
                              ? IconButton(
                                  icon: Icon(
                                    _obscureTextMap[field.id] == true
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureTextMap[field.id] =
                                          !(_obscureTextMap[field.id] ?? true);
                                    });
                                  },
                                )
                              : null,
                        ),
                      ),
                      if (widget.integration.id == 'upcitemdb' &&
                          field.id == 'apiKey')
                        Padding(
                          padding: const EdgeInsets.only(top: 8, left: 4),
                          child: Text(
                            "Deja este campo vacío para usar el modo Gratuito (Limitado).",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blueGrey[400],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              );
            }),
          if (!_isIdLoading)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Consumer<IntegrationProvider>(
                // Usamos Consumer para escuchar el estado isTesting
                builder: (context, provider, child) {
                  return OutlinedButton.icon(
                    onPressed: provider.isTesting
                        ? null
                        : () async {
                            // 1. Recolectamos la configuración actual de los controladores
                            final Map<String, dynamic> currentConfig = {};
                            _controllers.forEach((key, controller) {
                              currentConfig[key] = controller.text;
                            });

                            // 2. Ejecutamos el test
                            final success = await provider.testConnection(
                              widget.integration.id,
                              currentConfig,
                            );

                            // 3. Feedback visual (Los Toasts ya se disparan en el Provider según tu lógica anterior)
                            if (success) {
                              ToastService.success(
                                "¡Conexión verificada con éxito!",
                              );
                            } else {
                              // Aquí usamos el mensaje específico que capturamos en el Provider
                              ToastService.error(
                                provider.lastErrorMessage.isNotEmpty
                                    ? provider.lastErrorMessage
                                    : "La prueba de conexión falló",
                              );
                            }
                          },
                    icon: provider.isTesting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.bolt_outlined),
                    label: Text(
                      provider.isTesting ? "Probando..." : "Probar Conexión",
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(
                        double.infinity,
                        45,
                      ), // Botón ancho completo
                    ),
                  );
                },
              ),
            ),
          // --- Acciones ---
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isIdLoading ? null : _handleSave,
              child: Text(AppLocalizations.of(context)!.saveConfiguration),
            ),
          ),
          const SizedBox(height: 24),
          if (isLinked && !_isIdLoading) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: _handleUnlink,
                icon: const Icon(
                  Icons.delete_forever_outlined,
                  color: Colors.red,
                ),
                label: const Text(
                  "DESVINCULAR INTEGRACIÓN",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  Future<void> _handleUnlink() async {
    final provider = context.read<IntegrationProvider>();

    // Opcional: Podrías añadir un diálogo de confirmación aquí
    final success = await provider.unlinkIntegration(widget.integration.id);

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ToastService.success("Se ha desvinculado ${widget.integration.name}");
      } else {
        ToastService.error("No se pudo desvincular la cuenta");
      }
    }
  }

  Future<void> _handleSave() async {
    // 1. Extraemos los valores de los controladores
    final Map<String, dynamic> configToSave = {};
    _controllers.forEach((key, controller) {
      configToSave[key] = controller.text;
    });

    // 2. Llamamos al Provider
    final provider = context.read<IntegrationProvider>();
    final success = await provider.saveIntegration(
      widget.integration.id,
      configToSave,
    );

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ToastService.success(
          "${widget.integration.name} configurado con éxito",
        );
      } else {
        ToastService.error("Error al guardar la configuración");
      }
    }
  }
}
