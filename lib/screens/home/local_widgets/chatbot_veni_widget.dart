import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/core/routing/route_names.dart';
import 'package:invenicum/data/models/custom_field_definition.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/data/models/asset_template_model.dart';
import 'package:invenicum/data/models/custom_field_definition_model.dart';
import 'package:invenicum/data/services/veni_chatbot_service.dart';
import 'package:invenicum/screens/home/local_widgets/typing_bubbles_widget.dart';
import 'package:provider/provider.dart';

class VeniChatbot extends StatefulWidget {
  final String? initialPath;
  final VoidCallback? onClose; // Callback para cerrar desde el Stack
  final Function(Offset)? onDrag;

  const VeniChatbot({super.key, this.initialPath, this.onClose, this.onDrag});

  @override
  State<VeniChatbot> createState() => _VeniChatbotState();
}

class _VeniChatbotState extends State<VeniChatbot> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    // 1. Obtenemos el service
    final chatService = Provider.of<ChatService>(context, listen: false);

    // 2. Cargamos el historial de la base de datos
    await chatService.loadRemoteHistory();

    // 3. Verificamos si realmente está vacío
    if (chatService.messages.isEmpty && mounted) {
      // Pequeño delay de seguridad para asegurar que la UI está lista
      await Future.delayed(const Duration(milliseconds: 500));

      final String currentLocale = Localizations.localeOf(context).languageCode;

      if (mounted) setState(() => _isLoading = true);

      try {
        await chatService.sendMessageToVeni(
          message:
              "SAY_HELLO_INITIAL", // 👈 Este comando dispara la lógica en el back
          locale: currentLocale,
          contextData: {'currentPath': widget.initialPath ?? '/dashboard'},
        );
      } catch (e) {
        debugPrint("Error en saludo inicial: $e");
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
    _scrollToBottom();
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    final chatService = Provider.of<ChatService>(context, listen: false);
    final String currentLocale = Localizations.localeOf(context).languageCode;
    setState(() {
      _isLoading = true;
      _controller.clear();
    });
    _scrollToBottom();

    try {
      final String currentFullLocation = widget.initialPath ?? '/dashboard';
      final response = await chatService.sendMessageToVeni(
        message: text,
        locale: currentLocale,
        contextData: {'currentPath': currentFullLocation},
      );

      if (response != null && mounted && response.action != null) {
        _handleAction(response.action!, response.data ?? {});
      }
    } catch (e) {
      debugPrint("❌ Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  void _handleAction(String action, Map<String, dynamic> data) {
    debugPrint(
      "🎯 _handleAction → action: $action | data keys: ${data.keys.toList()}",
    );

    if (action == 'NAVIGATE') {
      final path = data['path'];
      if (path != null && path is String) {
        final safePath = path.contains('default') ? '/dashboard' : path;
        context.go(safePath);
      }
    }

    if (action == 'CREATE_TEMPLATE') {
      try {
        debugPrint("🧠 CREATE_TEMPLATE data bruta: $data");

        // El backend puede anidar los datos de la plantilla de distintas maneras:
        // 1. data = { name, fields, ... }              → directo
        // 2. data = { data: { name, fields, ... } }    → un nivel anidado
        Map<String, dynamic> templateData = data;

        if (!data.containsKey('name') && !data.containsKey('fields')) {
          if (data['data'] is Map<String, dynamic>) {
            templateData = data['data'] as Map<String, dynamic>;
          } else if (data['template'] is Map<String, dynamic>) {
            templateData = data['template'] as Map<String, dynamic>;
          }
        }

        debugPrint(
          "🧠 templateData resuelto: name=${templateData['name']} fields=${templateData['fields']?.length ?? 0}",
        );

        final draft = _mapAiDataToTemplate(templateData);
        debugPrint("✅ Draft: ${draft.name} — ${draft.fields.length} campos");

        // Delay para que Veni muestre su mensaje antes de navegar
        Future.delayed(const Duration(milliseconds: 600), () {
          if (!mounted) return;
          context.goNamed(RouteNames.templateCreate, extra: draft);
          if (widget.onClose != null) widget.onClose!();
        });
      } catch (e, stack) {
        debugPrint("❌ Error en CREATE_TEMPLATE: $e$stack");
      }
    }
  }

  AssetTemplate _mapAiDataToTemplate(Map<String, dynamic> data) {
    // 1. Extraemos la lista de campos que viene de la IA
    final List<dynamic> rawFields = data['fields'] ?? [];

    return AssetTemplate(
      id: 'draft_${DateTime.now().millisecondsSinceEpoch}', // ID temporal para el UI
      name: data['name'] ?? 'Nueva Colección',
      description: data['description'] ?? '',
      category: data['category'] ?? 'General',
      author: 'Veni AI',
      tags: List<String>.from(data['tags'] ?? []),
      // 2. Mapeamos a tu lista de fields con el modelo CustomFieldDefinition
      fields: rawFields.map((f) {
        final map = Map<String, dynamic>.from(f);

        return CustomFieldDefinition(
          id: null, // Los campos nuevos no tienen ID de base de datos aún
          name: map['name'] ?? 'Campo',
          // 3. Convertimos el string de la IA al Enum CustomFieldType
          type: _parseAiFieldType(map['type']),
          // Soportamos 'isRequired' o 'required' por si la IA varía el nombre
          isRequired: map['isRequired'] ?? map['required'] ?? false,
          // Aprovechamos tus nuevos campos de sumatorios y moneda
          isSummable: map['isSummable'] ?? map['is_summable'] ?? false,
          isCountable: map['isCountable'] ?? map['is_countable'] ?? false,
          isMonetary: map['isMonetary'] ?? map['is_monetary'] ?? false,
          options: map['options'] != null
              ? List<String>.from(map['options'])
              : null,
        );
      }).toList(),
      isOfficial: false,
      isPublic: false,
      downloadCount: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  CustomFieldType _parseAiFieldType(dynamic type) {
    final typeStr = type?.toString().toLowerCase() ?? 'text';
    switch (typeStr) {
      case 'number':
      case 'numeric':
      case 'decimal':
      case 'double':
        return CustomFieldType.number;
      case 'date':
      case 'datetime':
        return CustomFieldType.date;
      case 'boolean':
      case 'bool':
      case 'checkbox':
        return CustomFieldType.boolean;
      case 'dropdown':
      case 'selection':
        return CustomFieldType.dropdown;
      default:
        return CustomFieldType.text;
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final chatService = context.watch<ChatService>();

    return Container(
      width: 400,
      height: 600,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: GestureDetector(
              onPanUpdate: (details) {
                if (widget.onDrag != null) {
                  widget.onDrag!(details.delta); // Llama a la función del padre
                }
              },
              child: AppBar(
                backgroundColor: theme.primaryColor,
                automaticallyImplyLeading:
                    false, // Quita flecha de atrás automática
                title: Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.veniChatTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: widget.onClose, // USA EL CALLBACK, NO EL POP
                  ),
                ],
              ),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: chatService.messages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == chatService.messages.length)
                      return const TypingIndicator();
                    final msg = chatService.messages[index];
                    return _ChatBubble(
                      text: msg['text'],
                      isUser: msg['isUser'],
                    );
                  },
                ),
              ),
              _buildInputArea(theme, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: l10n.veniChatPlaceholder,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: theme.primaryColor,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 18),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  const _ChatBubble({required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bubbleColor = isUser
        ? theme.primaryColor
        : theme.colorScheme.surfaceContainerHighest;
    final textColor = isUser ? Colors.white : null;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 4,
          bottom: 14, // espacio para el piquito que sobresale abajo
          left: isUser ? 40 : 4,
          right: isUser ? 4 : 40,
        ),
        child: CustomPaint(
          painter: _BubbleShapePainter(isUser: isUser, color: bubbleColor),
          child: Padding(
            padding: const EdgeInsets.only(
              left: 14,
              right: 14,
              top: 10,
              bottom: 10,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 240),
              child: SelectableText(
                text,
                style: TextStyle(color: textColor),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BubbleShapePainter extends CustomPainter {
  final bool isUser;
  final Color color;

  const _BubbleShapePainter({required this.isUser, required this.color});

  // Medidas del piquito y radio de esquinas
  static const double _r = 14; // radio esquinas
  static const double _tw = 9; // ancho base piquito
  static const double _th = 9; // alto piquito

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height - _th; // altura del rectángulo sin el piquito
    final path = Path();

    if (isUser) {
      // Empezamos arriba-izquierda, sentido horario
      // Esquina superior-izquierda
      path.moveTo(_r, 0);
      // Borde superior
      path.lineTo(w - _r, 0);
      // Esquina superior-derecha
      path.arcToPoint(
        Offset(w, _r),
        radius: const Radius.circular(_r),
        clockwise: true,
      );
      // Borde derecho
      path.lineTo(w, h - _r);
      // Esquina inferior-derecha → piquito sale aquí
      path.arcToPoint(
        Offset(w - _r, h),
        radius: const Radius.circular(_r),
        clockwise: true,
      );
      // Piquito abajo-derecha: base → punta → regreso
      path.lineTo(w - _r, h);
      path.lineTo(w - _r + _tw * 0.4, h + _th * 0.4);
      path.lineTo(w - _r + _tw, h + _th); // punta del piquito
      path.lineTo(w - _r - _tw * 0.8, h); // regreso a la base
      // Borde inferior hacia la izquierda
      path.lineTo(_r, h);
      // Esquina inferior-izquierda
      path.arcToPoint(
        Offset(0, h - _r),
        radius: const Radius.circular(_r),
        clockwise: true,
      );
      // Borde izquierdo
      path.lineTo(0, _r);
      // Esquina superior-izquierda (cierre)
      path.arcToPoint(
        Offset(_r, 0),
        radius: const Radius.circular(_r),
        clockwise: true,
      );
    } else {
      // Empezamos arriba-izquierda, sentido horario
      // Esquina superior-izquierda
      path.moveTo(_r, 0);
      // Borde superior
      path.lineTo(w - _r, 0);
      // Esquina superior-derecha
      path.arcToPoint(
        Offset(w, _r),
        radius: const Radius.circular(_r),
        clockwise: true,
      );
      // Borde derecho
      path.lineTo(w, h - _r);
      // Esquina inferior-derecha
      path.arcToPoint(
        Offset(w - _r, h),
        radius: const Radius.circular(_r),
        clockwise: true,
      );
      // Borde inferior hacia la izquierda
      path.lineTo(_r + _tw * 0.2, h);
      // Piquito abajo-izquierda: base → punta → regreso
      path.lineTo(_r - _tw + _tw * 0.8, h + _th * 0.4);
      path.lineTo(_r - _tw, h + _th); // punta del piquito
      path.lineTo(_r - _tw * 0.4, h); // regreso a la base
      path.lineTo(_r, h);
      // Esquina inferior-izquierda
      path.arcToPoint(
        Offset(0, h - _r),
        radius: const Radius.circular(_r),
        clockwise: true,
      );
      // Borde izquierdo
      path.lineTo(0, _r);
      // Esquina superior-izquierda (cierre)
      path.arcToPoint(
        Offset(_r, 0),
        radius: const Radius.circular(_r),
        clockwise: true,
      );
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BubbleShapePainter old) =>
      old.isUser != isUser || old.color != color;
}
