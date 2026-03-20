import 'package:flutter/material.dart';
import 'package:invenicum/data/models/integration_field_type.dart'; // Ajusta la ruta si es necesario

class ExternalImportWidget extends StatelessWidget {
  final String? selectedSource;
  final List<IntegrationModel> availableSources;
  final TextEditingController searchController;
  final bool isLoading;
  final Function(String?) onSourceChanged;
  final VoidCallback onSearch;

  const ExternalImportWidget({
    super.key,
    required this.selectedSource,
    required this.availableSources,
    required this.searchController,
    required this.isLoading,
    required this.onSourceChanged,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 480;

        final dropdown = DropdownButtonFormField<String>(
          value: selectedSource,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: "Fuente de datos",
            prefixIcon: Icon(Icons.api),
          ),
          items: availableSources
              .map(
                (source) => DropdownMenuItem(
                  value: source.id,
                  child: Row(
                    children: [
                      SizedBox(width: 20, child: source.icon),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                      Flexible(
                        child: Text(
                          source.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: onSourceChanged,
        );

        final searchField = TextFormField(
          controller: searchController,
          decoration: InputDecoration(
            labelText: "Buscar por nombre",
            hintText: "Ej: Pikachu, Catan, El Quijote...",
            suffixIcon: isLoading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: onSearch,
                  ),
          ),
          onFieldSubmitted: (_) => onSearch(),
        );

        if (isWide) {
          return Row(
            // Cambiamos a CrossAxisAlignment.start o center para que el
            // dropdown y el searchField se alineen mejor visualmente
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Primera columna: Dropdown
              Expanded(child: dropdown),
              const SizedBox(width: 16), // Espacio entre columnas
              // Segunda columna: SearchField
              Expanded(child: searchField),
            ],
          );
        }

        // En móvil (no wide) se mantiene igual
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [dropdown, const SizedBox(height: 12), searchField],
        );
      },
    );
  }
}
