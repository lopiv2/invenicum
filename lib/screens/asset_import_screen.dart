import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/providers/inventory_item_provider.dart';
import 'package:provider/provider.dart';
import 'package:csv/csv.dart'; // Asegúrate de tener esta dependencia: csv: ^5.0.1
import 'dart:io';
import 'dart:convert';
import 'package:file_picker/file_picker.dart'; // Asegúrate de tener esta dependencia: file_picker: ^5.2.5

import '../models/asset_type_model.dart';
import '../providers/container_provider.dart';
// Importa tu modelo de campo (si existe) y tu provider de items

// Definición simple para el mapeo
class ColumnMapping {
  final String assetFieldName; // e.g., 'Nombre', 'Marca'
  String? csvHeader; // El encabezado del CSV seleccionado
  // 🔑 NUEVO: ID del campo. Será null para campos estándar (name, description)
  // y la ID numérica (e.g., '6') para campos personalizados.
  final String? assetFieldId;

  ColumnMapping({
    required this.assetFieldName,
    this.csvHeader,
    this.assetFieldId, // Debe ser cargado desde el backend (metadatos del AssetType)
  });
}

class AssetImportScreen extends StatefulWidget {
  final String containerId;
  final String assetTypeId;

  const AssetImportScreen({
    super.key,
    required this.containerId,
    required this.assetTypeId,
  });

  @override
  State<AssetImportScreen> createState() => _AssetImportScreenState();
}

class _AssetImportScreenState extends State<AssetImportScreen> {
  // --- ESTADO ---
  AssetType? _assetType;
  List<String> _csvHeaders = [];
  List<List<dynamic>> _csvData = [];
  List<ColumnMapping> _mappings = [];
  bool _isLoading = false;
  String? _filePath;

  @override
  void initState() {
    super.initState();
    _loadAssetType();
  }

  void _loadAssetType() {
    final containerProvider = context.read<ContainerProvider>();
    final cIdInt = int.tryParse(widget.containerId);
    final atIdInt = int.tryParse(widget.assetTypeId);

    if (cIdInt == null || atIdInt == null) return;

    final container = containerProvider.containers.cast<dynamic>().firstWhere(
      (c) => c?.id == cIdInt,
      orElse: () => null,
    );

    _assetType = container?.assetTypes.cast<AssetType?>().firstWhere(
      (at) => at?.id == atIdInt,
      orElse: () => null,
    );

    if (_assetType != null) {
      _initializeMappings();
    }
  }

  // Inicializa el mapeo con todos los campos definidos en AssetType
  void _initializeMappings() {
    if (_assetType == null) return;

    // 1. 🔑 CAMPOS FIJOS: Nombre y Descripción
    _mappings = [
      ColumnMapping(assetFieldName: 'Nombre'),
      ColumnMapping(assetFieldName: 'Descripción'),
      // Agrega cualquier otro campo fijo aquí (ej: 'quantity', 'location', etc.)
    ];

    // 2. CAMPOS CUSTOM/DINÁMICOS: Definiciones de campo del AssetType
    final customMappings = _assetType!.fieldDefinitions
        .map(
          (def) => ColumnMapping(
            assetFieldName: def.name, // e.g., 'Marca'
            // 🔑 CORRECCIÓN CLAVE: Usamos el ID del campo como clave final.
            assetFieldId: def.id.toString(), // e.g., '6'
          ),
        )
        .toList();

    // 3. Combinar las listas
    _mappings.addAll(customMappings);

    // 4. Si ya tenemos encabezados CSV cargados (porque el usuario seleccionó un archivo antes
    // de limpiar/reiniciar), aplicamos el mapeo automático de nuevo.
    if (_csvHeaders.isNotEmpty) {
      _attemptAutomaticMapping();
    }
  }

  // --- LÓGICA DE ARCHIVOS CSV ---

  Future<void> _pickFile() async {
    setState(() {
      _isLoading = true;
      _csvHeaders = [];
      _mappings.clear();
      _filePath = null; // We won't use this on web, but it's okay for display
      _csvData = [];
    });

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      try {
        final PlatformFile file = result.files.single;
        String content;

        if (kIsWeb) {
          // 🔑 FIX PARA WEB: Leer el archivo directamente desde los bytes
          final bytes = file.bytes;
          if (bytes == null)
            throw Exception("No se pudieron leer los bytes del archivo.");

          try {
            content = utf8.decode(
              bytes,
            ); // Intentar UTF-8 primero (el estándar)
          } catch (e) {
            // Si UTF-8 falla, intentar con Latin-1/ISO-8859-1
            content = latin1.decode(bytes);
          }

          // Aunque no hay path real en web, guardamos el nombre para mostrarlo
          _filePath = file.name;
        } else {
          // 🔑 LÓGICA PARA MOBILE/DESKTOP (Si lo necesitas en el futuro)
          final filePath = file.path;
          if (filePath == null) throw Exception("Ruta de archivo no válida");

          final ioFile = File(filePath);
          content = await ioFile.readAsString(encoding: utf8);
          _filePath = filePath;
        }

        // --- LÓGICA DE PROCESAMIENTO CSV (Igual para Web y Nativo) ---

        // Convertir el contenido del CSV a una lista de listas
        final List<List<dynamic>> rowsAsListOfLists = const CsvToListConverter(
          fieldDelimiter: ';', // 👈 Revisa si es ',' o ';'
          eol: '\n',
        ).convert(content);

        if (rowsAsListOfLists.isNotEmpty) {
          _csvData = rowsAsListOfLists;
          // La primera fila es el encabezado
          _csvHeaders = rowsAsListOfLists.first
              .map((e) => e.toString())
              .toList();
        } else {
          throw Exception("El archivo CSV está vacío.");
        }

        setState(() {
          _isLoading = false;
          _initializeMappings();
          _attemptAutomaticMapping();
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al leer el archivo: ${e.toString()}'),
            ),
          );
        }
        setState(() => _isLoading = false);
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  // Intenta mapear automáticamente si los nombres coinciden (case-insensitive)
  void _attemptAutomaticMapping() {
    if (_csvHeaders.isEmpty) return;

    for (var mapping in _mappings) {
      final match = _csvHeaders.firstWhere(
        (header) =>
            header.toLowerCase() == mapping.assetFieldName.toLowerCase(),
        orElse: () => '',
      );
      if (match.isNotEmpty) {
        mapping.csvHeader = match;
      }
    }
  }

  // --- LÓGICA DE IMPORTACIÓN FINAL ---

  void _startImport() async {
    // 1. **Validación de Datos Básica**
    if (_csvData.isEmpty || _csvData.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor, selecciona un archivo CSV con encabezados y al menos una fila de datos.',
          ),
        ),
      );
      return;
    }

    // 2. **Validación de Mapeo del Campo 'Nombre'**
    // El campo 'Nombre' debe estar mapeado a alguna columna CSV.
    final nameMapping = _mappings.firstWhere(
      (m) => m.assetFieldName == 'Nombre',
      orElse: () => ColumnMapping(assetFieldName: 'Nombre', csvHeader: null),
    );

    if (nameMapping.csvHeader == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El campo "Nombre" es obligatorio y debe ser mapeado.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // 3. **Preparar el Mapeo de Índices**
    final List<dynamic> csvHeaders = _csvData.first;

    // 🔑 Mapeamos el índice de la columna CSV a la CLAVE FINAL (name, description, o el ID numérico)
    final Map<int, String> csvIndexToFinalKey = {};

    for (var map in _mappings) {
      final csvHeaderName = map.csvHeader;
      if (csvHeaderName != null) {
        final index = csvHeaders.indexOf(csvHeaderName);
        if (index != -1) {
          final assetField = map.assetFieldName;

          if (assetField == 'Nombre') {
            csvIndexToFinalKey[index] = 'name'; // Clave final estándar
          } else if (assetField == 'Descripción') {
            csvIndexToFinalKey[index] = 'description'; // Clave final estándar
          } else if (map.assetFieldId != null) {
            // 🔑 CORRECCIÓN CLAVE: Usar el ID numérico como clave final
            csvIndexToFinalKey[index] = map.assetFieldId!;
          }
        }
      }
    }

    // 4. **Extraer las Filas de Datos** (excluyendo el encabezado)
    final List<List<dynamic>> dataRows = _csvData.sublist(1);

    // 5. **Iterar y Construir los Items de Activo con la Estructura de Backend**
    final List<Map<String, dynamic>> itemsToUpload = [];
    int failedItems = 0;

    for (var row in dataRows) {
      // 🔑 ESTRUCTURA FINAL REQUERIDA POR EL BACKEND
      final Map<String, dynamic> itemData = {
        'containerId': widget.containerId.toString(),
        'assetTypeId': widget.assetTypeId.toString(),
        'customFieldValues': {}, // Inicializado
      };
      bool isValid = true;

      // Iteramos sobre el mapeo de índices ya resuelto
      csvIndexToFinalKey.forEach((csvIndex, finalKey) {
        if (csvIndex < row.length) {
          final rawValue = row[csvIndex]?.toString().trim() ?? '';

          if (finalKey == 'name') {
            itemData['name'] = rawValue;
          } else if (finalKey == 'description') {
            itemData['description'] = rawValue;
          } else {
            // 🔑 Aquí, finalKey es el ID numérico (ej: '6')
            // que se asigna directamente al objeto customFieldValues.
            itemData['customFieldValues'][finalKey] = rawValue;
          }

          // Validación de nulidad del nombre
          if (finalKey == 'name' && rawValue.isEmpty) {
            isValid = false;
          }
        }
      });

      // Validación final
      if (itemData['name'] == null || itemData['name'].toString().isEmpty) {
        isValid = false;
      }

      if (isValid) {
        itemsToUpload.add(itemData);
      }
    }

    // 6. LLAMADA AL PROVIDER/SERVICIO
    try {
      final inventoryItemProvider = context.read<InventoryItemProvider>();

      await inventoryItemProvider.createBatchFromCSV(
        containerId: int.parse(widget.containerId),
        assetTypeId: int.parse(widget.assetTypeId),
        itemsToUpload: itemsToUpload, // ¡Ahora con la estructura correcta!
      );

      if (mounted) {
        // Si la llamada no lanzó una excepción, la importación fue exitosa
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '🎉 ¡Importación Exitosa! ${itemsToUpload.length} activos creados. ${failedItems > 0 ? '$failedItems filas ignoradas.' : ''}',
            ),
            backgroundColor: Colors.green,
          ),
        );
        // Volver a la pantalla anterior (AssetListScreen)
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        // Mostrar el error retornado por el servicio
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error durante la importación: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // --- WIDGET BUILD ---

  @override
  Widget build(BuildContext context) {
    if (_assetType == null) {
      return const Scaffold(
        body: Center(child: Text('Cargando Tipo de Activo o ID inválido...')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Importar Activos a "${_assetType!.name}"')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. SELECTOR DE ARCHIVO
            const Text(
              'Paso 1: Seleccionar Archivo CSV',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _pickFile,
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Elegir Archivo CSV'),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    _filePath ?? 'Ningún archivo seleccionado',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _filePath != null ? Colors.green : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // 2. ENCABEZADOS Y MAPEO
            const Text(
              'Paso 2: Mapeo de Columnas (CSV -> Sistema)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_csvHeaders.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    'Por favor, selecciona un archivo CSV con encabezados.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              // Lista de Mapeos
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _mappings.length,
                itemBuilder: (context, index) {
                  final mapping = _mappings[index];
                  final assetFieldName = mapping.assetFieldName;

                  // Opciones del Dropdown: Encabezados del CSV + Opción para ignorar
                  final List<String?> dropdownOptions = [
                    null, // Opción "Ignorar/No Mapear"
                    ..._csvHeaders,
                  ];

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Campo del Sistema
                        SizedBox(
                          width: 150,
                          child: Text(
                            assetFieldName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(
                          Icons.arrow_right_alt,
                          color: Colors.blueGrey,
                        ),
                        const SizedBox(width: 10),
                        // Dropdown para elegir la columna CSV
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: mapping.csvHeader,
                            hint: const Text('Seleccionar Columna CSV'),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            items: dropdownOptions.map((header) {
                              return DropdownMenuItem<String>(
                                value: header,
                                child: Text(header ?? '🚫 Ignorar Campo'),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                mapping.csvHeader = newValue;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

            const SizedBox(height: 40),

            // 3. BOTÓN DE INICIAR IMPORTACIÓN
            Center(
              child: ElevatedButton.icon(
                onPressed: (_isLoading || _csvHeaders.isEmpty)
                    ? null
                    : _startImport,
                icon: const Icon(Icons.cloud_upload),
                label: const Text('Iniciar Importación'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
