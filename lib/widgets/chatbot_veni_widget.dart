import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/services/veni_chatbot_service.dart';
import 'package:invenicum/widgets/typing_bubbles_widget.dart';
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
      final response = await chatService.sendMessageToVeni(
        message: text,
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
    if (action == 'NAVIGATE') {
      final path = data['path'];
      if (path != null && path is String) {
        final safePath = path.contains('default') ? '/dashboard' : path;
        context.go(safePath); // Navega en el fondo sin cerrar el chat
      }
    }
    // Añadir más acciones aquí...
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
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
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
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isUser
              ? theme.primaryColor
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: TextStyle(color: isUser ? Colors.white : null),
        ),
      ),
    );
  }
}
