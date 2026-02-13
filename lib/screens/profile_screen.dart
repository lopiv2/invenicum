import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:web/web.dart' as web;
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:invenicum/models/user_data_model.dart';
import 'package:invenicum/services/toast_service.dart';
import 'package:provider/provider.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';
import '../l10n/app_localizations.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _githubController;
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameController = TextEditingController(text: user?.name);
    _usernameController = TextEditingController(text: user?.username);
    _githubController = TextEditingController(text: user?.githubHandle);

    _initDeepLinks();

    if (kIsWeb) {
      // Esto le dice a Flutter: "Espera a terminar de dibujar y luego ejecuta esto"
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkWebQueryParams();
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _githubController.dispose();
    _linkSubscription?.cancel();
    super.dispose();
  }

  // NUEVO MÉTODO PARA WEB
  void _checkWebQueryParams() {
    if (!kIsWeb) return;

    // 1. Obtenemos la URL real que ve el navegador (la que tiene el ?code=)
    final String fullUrl = web.window.location.href;

    // 2. Usamos una RegExp para sacar el código sin importar dónde esté
    final regExp = RegExp(r'code=([a-zA-Z0-9]+)');
    final match = regExp.firstMatch(fullUrl);

    if (match != null) {
      final String? code = match.group(1);

      if (code != null && code.isNotEmpty) {
        // 🚩 PRIMERO: Limpiamos la URL para que el usuario la vea bien
        // Esto quita el ?code=... de la vista pero el valor ya está en nuestra variable 'code'
        web.window.history.replaceState(null, 'Profile', '/#/myprofile');

        // 🚩 SEGUNDO: Procesamos la vinculación con el código que ya guardamos
        _processGitHubCode(code);
      }
    }
  }

  void _initDeepLinks() {
    _appLinks = AppLinks();

    // Escucha links mientras la app está abierta en segundo plano
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    });
  }

  void _handleDeepLink(Uri uri) async {
    // Verificamos que el link sea el de nuestro callback
    if (uri.scheme == 'invenicum' && uri.host == 'auth-callback') {
      final code = uri.queryParameters['code'];
      if (code != null) {
        // Cerramos el navegador (esto ocurre automáticamente en la mayoría de OS)
        // Llamamos al backend para validar el código
        _processGitHubCode(code);
      }
    }
  }

  Future<void> _handleDisconnectGitHub() async {
    final authProvider = context.read<AuthProvider>();

    // Opcional: Mostrar un diálogo de confirmación
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Desconectar GitHub"),
        content: const Text(
          "¿Estás seguro de que quieres desvincular tu cuenta de GitHub?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("CANCELAR"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "DESCONECTAR",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await authProvider.disconnectGitHubAccount();
      if (mounted) {
        _usernameController.clear(); // Limpiamos el campo de username
        _githubController.clear(); // Limpiamos el input visualmente
        ToastService.success("GitHub desvinculado correctamente");
      }
    }
  }

  Future<void> _processGitHubCode(String code) async {
    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.linkGitHubAccount(code);

      if (success && mounted) {
        // 🚩 EL CAMBIO: No dependas solo del updatedUser del provider aquí
        // porque a veces el notifyListeners() y el context.go chocan.

        final newUser = authProvider.user;
        if (newUser != null) {
          // Actualizamos los controladores ANTES de cualquier navegación
          _usernameController.text = newUser.username ?? '';
          _githubController.text = newUser.githubHandle ?? '';

          // Forzamos un refresco visual
          setState(() {});
        }

        ToastService.success("¡GitHub vinculado correctamente!");

        // Usar pushReplacement o simplemente esperar un frame antes de irnos
        // para que la UI no se limpie antes de tiempo
        Future.delayed(Duration.zero, () {
          if (mounted) context.go('/myprofile');
        });
      }
    } catch (e) {
      if (mounted) {
        ToastService.error("Error al procesar la vinculación: $e");
        // Incluso si falla, limpiamos la URL para que el código usado no se quede ahí
        context.go('/myprofile');
      }
    }
  }

  Future<void> _handleGitHubOAuth() async {
    try {
      // 1. Obtenemos la configuración desde tu backend
      final response = await context.read<AuthProvider>().getGitHubConfig();
      final String? clientId = response['clientId'];
      if (clientId == null || clientId.isEmpty) {
        ToastService.error("Error: Configuración de GitHub no disponible");
        return;
      }

      // 2. Construimos la URL con el ID que nos dio el server
      final String redirectUri = kIsWeb
          ? "${Uri.base.origin}/" // Mandamos a la raíz, el script o el router se encargarán
          : "invenicum://auth-callback";

      final url = Uri.parse(
        'https://github.com/login/oauth/authorize'
        '?client_id=$clientId'
        '&redirect_uri=$redirectUri'
        '&scope=read:user',
      );

      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: kIsWeb
              ? LaunchMode.platformDefault
              : LaunchMode.externalApplication,
          webOnlyWindowName: kIsWeb ? '_self' : null,
        );
      }
    } catch (e) {
      ToastService.error("No se pudo conectar con el servidor: $e");
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await context.read<AuthProvider>().updateProfile(
        name: _nameController.text.trim(),
        username: _usernameController.text.trim().isEmpty
            ? null
            : _usernameController.text.trim(),
        githubHandle: _githubController.text.trim().isEmpty
            ? null
            : _githubController.text.trim(),
      );
      if (mounted) {
        ToastService.success("Perfil actualizado correctamente");
      }
    } catch (e) {
      if (mounted) {
        ToastService.error("Error al actualizar el perfil: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent, // El fondo lo da el MainLayout
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          margin: const EdgeInsets.all(24),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(
                color: colorScheme.outlineVariant.withOpacity(0.5),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildAvatarPreview(authProvider),
                    const SizedBox(height: 32),

                    Text(
                      l10n?.myProfile ?? 'Mi Perfil',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 32),

                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: l10n?.name ?? 'Name',
                        prefixIcon: const Icon(Icons.person_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'El nombre es requerido' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _usernameController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Username (Comunidad)',
                        helperText: 'Requerido para publicar plugins.',
                        prefixIcon: const Icon(Icons.alternate_email_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildGitHubSection(
                      authProvider,
                      authProvider.user,
                      colorScheme,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton.icon(
                        onPressed: authProvider.isLoading ? null : _handleSave,
                        icon: authProvider.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save_rounded),
                        label: const Text('GUARDAR CAMBIOS'),
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarPreview(AuthProvider authProvider) {
    final user = authProvider.user;
    final String seed = user?.name ?? 'Guest';

    // Prioridad: 1. URL de la base de datos, 2. URL validada en sesión, 3. Null
    final String? avatarUrl =
        user?.avatarUrl ?? authProvider.validatedAvatarUrl;

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 3,
            ),
          ),
          child: ClipOval(
            child: (avatarUrl != null && avatarUrl.isNotEmpty)
                ? Image.network(
                    avatarUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        RandomAvatar(seed, width: 100, height: 100),
                  )
                : RandomAvatar(seed, width: 100, height: 100),
          ),
        ),
        // Solo mostramos el check si el backend confirma que está verificado
        if (user?.githubHandle != null && user!.githubHandle!.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.verified, color: Colors.white, size: 20),
          ),
      ],
    );
  }

  Widget _buildGitHubSection(
    AuthProvider authProvider,
    UserData? user,
    ColorScheme colorScheme,
  ) {
    final bool isLinked =
        user?.githubHandle != null && user!.githubHandle!.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLinked ? Colors.green.withAlpha(50) : colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLinked ? Colors.black : colorScheme.outlineVariant,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Logo de GitHub (puedes usar un icono de FontAwesome o una imagen asset)
              const FaIcon(
                FontAwesomeIcons.github,
                color: Colors.black,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "GitHub Identity",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      isLinked
                          ? "Vinculado como @${user.githubHandle}"
                          : "Vincula tu cuenta para publicar plugins",
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              if (isLinked)
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          // El campo de texto estilizado
          TextFormField(
            controller: _githubController,
            readOnly: isLinked,
            enabled: !isLinked,
            decoration: InputDecoration(
              hintText: "Tu usuario de GitHub",
              filled: true,
              fillColor: Colors.white,
              prefixText: "github.com/ ",
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Botón para verificar la cuenta
          ElevatedButton(
            onPressed: authProvider.isLoading
                ? null
                : (isLinked
                      ? _handleDisconnectGitHub // Si está vinculado, desconecta
                      : _handleGitHubOAuth), // Si no, vincula
            style: ElevatedButton.styleFrom(
              // Si está vinculado, lo ponemos en un tono rojo/gris para indicar "acción de desconexión"
              backgroundColor: isLinked
                  ? Colors.redAccent.withOpacity(0.8)
                  : Colors.black,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 40),
            ),
            child: authProvider.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FaIcon(
                        isLinked
                            ? FontAwesomeIcons.linkSlash
                            : FontAwesomeIcons.github,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isLinked ? "Desconectar GitHub" : "Vincular con GitHub",
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
