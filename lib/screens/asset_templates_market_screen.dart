import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:invenicum/providers/template_provider.dart';
import 'package:invenicum/models/asset_template_model.dart';

class AssetTemplatesMarketScreen extends StatefulWidget {
  const AssetTemplatesMarketScreen({super.key});

  @override
  State<AssetTemplatesMarketScreen> createState() => _AssetTemplatesMarketScreenState();
}

class _AssetTemplatesMarketScreenState extends State<AssetTemplatesMarketScreen> {
  @override
  void initState() {
    super.initState();
    // 🚩 Disparamos la carga de datos del backend al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TemplateProvider>().fetchMarketTemplates();
    });
  }

  @override
  Widget build(BuildContext context) {
    // 🚩 Escuchamos los cambios en el provider
    final templateProvider = context.watch<TemplateProvider>();
    final templates = templateProvider.marketTemplates;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comunidad Invenicum'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh), 
            onPressed: () => templateProvider.fetchMarketTemplates()
          ),
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          _buildMarketHeader(context),
          Expanded(
            child: _buildBody(templateProvider, templates),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/templates/create'),
        icon: const Icon(Icons.add_to_photos),
        label: const Text('Publicar Plantilla'),
      ),
    );
  }

  Widget _buildBody(TemplateProvider provider, List<AssetTemplate> templates) {
    // 1. Estado de carga
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. Estado de error
    if (provider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(provider.errorMessage!),
            TextButton(
              onPressed: () => provider.fetchMarketTemplates(), 
              child: const Text("Reintentar")
            )
          ],
        ),
      );
    }

    // 3. Estado vacío
    if (templates.isEmpty) {
      return const Center(
        child: Text("No se encontraron plantillas en el mercado."),
      );
    }

    // 4. Lista de plantillas (Market real)
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // Ideal para web/escritorio
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        return _TemplateCard(template: templates[index]);
      },
    );
  }

  Widget _buildMarketHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
      child: Column(
        children: [
          const Icon(Icons.hub, size: 48, color: Colors.indigo),
          const SizedBox(height: 12),
          Text(
            'Marketplace de Plantillas',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Text(
            'Descarga configuraciones oficiales y de la comunidad',
          ),
        ],
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final AssetTemplate template;

  const _TemplateCard({required this.template});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: () {
          context.go('/templates/details/${template.id}', extra: template);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: template.isOfficial 
                    ? Colors.indigo.withOpacity(0.1) 
                    : Colors.teal.withOpacity(0.1),
                child: Center(
                  child: Icon(
                    template.isOfficial ? Icons.verified_user : Icons.copy_all, 
                    size: 40, 
                    color: template.isOfficial ? Colors.indigo : Colors.teal
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          template.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (template.isOfficial)
                        const Icon(Icons.verified, size: 16, color: Colors.blue),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${template.author}',
                    style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                  ),
                  const SizedBox(height: 8),
                  if (template.tags.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: template.tags.take(3).map((tag) => _badge(tag)).toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10, color: Colors.black87),
      ),
    );
  }
}