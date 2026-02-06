import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/services/veni_chatbot_service.dart';
import 'package:invenicum/widgets/typing_bubbles_widget.dart';
import 'package:provider/provider.dart';

class VeniChatbot extends StatefulWidget {
  final String? initialPath; // Añadimos esto
  const VeniChatbot({super.key, this.initialPath});

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
    // Añadimos el mensaje de bienvenida solo si el historial está vacío
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final chatService = Provider.of<ChatService>(context, listen: false);
      await chatService.loadRemoteHistory();
      if (chatService.messages.isEmpty) {
        chatService.addMessage(
          AppLocalizations.of(context)!.veniChatWelcome,
          false,
        );
      }
      _scrollToBottom();
    });
  }

  /// Envía el mensaje al backend de Node.js
  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    final chatService = Provider.of<ChatService>(context, listen: false);

    setState(() {
      _isLoading = true;
      _controller.clear();
    });

    _scrollToBottom();

    try {
      final String currentFullLocation = widget.initialPath ?? '/dashboard';

      // Extracción del ID del contenedor
      final RegExp regExp = RegExp(r'/container/([^/]+)');
      final match = regExp.firstMatch(currentFullLocation);
      final String? currentContainerId = match?.group(1);

      // Enviamos al backend (el servicio se encarga de actualizar la lista de mensajes)
      final response = await chatService.sendMessageToVeni(
        message: text,
        contextData: {
          'containerId': currentContainerId,
          'currentPath': currentFullLocation,
        },
      );

      if (response != null && mounted) {
        // Si hay una acción (como NAVIGATE), la ejecutamos
        if (response.action != null) {
          _handleAction(response.action!, response.data ?? {});
        }
      }
    } catch (e) {
      debugPrint("❌ Error real: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    // WidgetsBinding asegura que el scroll ocurra DESPUÉS de que el nuevo mensaje
    // se haya dibujado en la pantalla.
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

  /// Router de Acciones: Aquí gestionas las 20+ funciones posibles
  void _handleAction(String action, Map<String, dynamic> data) {
    switch (action) {
      case 'NAVIGATE':
        final path = data['path'];
        if (path != null && path is String) {
          // 1. Limpiamos posibles errores del backend (como el 'default')
          final safePath = path.contains('default') ? '/dashboard' : path;

          // 2. Cerramos el chat y navegamos
          if (mounted) {
            //Navigator.of(context).pop(); // Cerramos el diálogo
            context.go(safePath); // GoRouter hace el resto
          }
        }
        break;

      case 'OPEN_SCANNER':
        if (mounted) {
          Navigator.of(context).pop();
          // Aquí llamas a tu lógica de escaneo, ej:
          // context.push('/scanner');
        }
        break;

      case 'PRODUCT_EXTRACT':
        // Aquí podrías, por ejemplo, abrir un formulario con los datos
        // que Gemini extrajo en data['Nombre'], data['Precio'], etc.
        debugPrint("Datos extraídos listos para usar: ${data.toString()}");
        break;

      default:
        debugPrint("Acción desconocida recibida: $action");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final chatService = context.watch<ChatService>();
    final messages = chatService.messages;

    return Container(
      width: 400,
      height: 600,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: theme.primaryColor,
            elevation: 0,
            title: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.veniChatTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == messages.length) {
                      return const TypingIndicator(); // Se muestra al final mientras carga
                    }

                    final msg = messages[index];
                    return _ChatBubble(
                      text: msg['text'],
                      isUser: msg['isUser'],
                    );
                  },
                ),
              ),
              _buildFooter(theme, l10n),
              _buildInputArea(theme, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l10n.veniChatPoweredBy,
            style: TextStyle(fontSize: 10, color: theme.disabledColor),
          ),
          const SizedBox(width: 4),
          Image.asset(
            'assets/images/Google-Gemini-Logo.webp',
            height: 20,
          ), // Ajustado tamaño
        ],
      ),
    );
  }

  Widget _buildInputArea(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment
            .end, // 🚩 Alinea el botón abajo si el texto crece
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              // 🚩 PROPIEDADES MULTILÍNEA:
              minLines: 1, // Empieza con una línea
              maxLines:
                  5, // Crece hasta un máximo de 5 antes de hacer scroll interno
              keyboardType: TextInputType
                  .multiline, // Cambia el teclado para permitir saltos de línea
              textInputAction: TextInputAction
                  .newline, // Permite "Enter" para bajar de línea

              decoration: InputDecoration(
                hintText: l10n.veniChatPlaceholder,
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest
                    .withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    20,
                  ), // 🚩 Bajamos un poco el radio para que se vea mejor al crecer
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(
              bottom: 4,
            ), // 🚩 Ajuste fino para centrar el botón con la primera línea
            child: CircleAvatar(
              backgroundColor: theme.primaryColor,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 18),
                onPressed: _sendMessage,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widgets auxiliares de Burbuja y Capacidades
class _ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  const _ChatBubble({required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isUser
              ? theme.primaryColor
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 16),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : theme.colorScheme.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _VeniCapabilitiesList extends StatelessWidget {
  final String title;
  const _VeniCapabilitiesList({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
