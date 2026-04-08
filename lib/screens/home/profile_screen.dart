import 'dart:async';
import 'package:web/web.dart' as web;
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:invenicum/data/models/user_data_model.dart';
import 'package:invenicum/data/services/toast_service.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/auth_provider.dart';

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

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _showPasswordFields = false; // Para expandir/contraer la sección

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameController = TextEditingController(text: user?.name);
    _usernameController = TextEditingController(text: user?.username);
    _githubController = TextEditingController(text: user?.githubHandle);

    _initDeepLinks();

    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkWebQueryParams();
      });
    }
  }

  /// Se llama cada vez que un InheritedWidget del que dependemos cambia.
  /// Usamos esto para sincronizar los controllers cuando AuthProvider
  /// notifica tras vincular GitHub — evita tener que salir y volver
  /// a entrar a la pantalla para ver los datos actualizados.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    // Solo actualizamos si el valor del provider difiere del controller,
    // para no interrumpir ediciones manuales del usuario en curso.
    if (_usernameController.text != (user.username ?? '')) {
      _usernameController.text = user.username ?? '';
    }
    if (_githubController.text != (user.githubHandle ?? '')) {
      _githubController.text = user.githubHandle ?? '';
    }
    if (_nameController.text != (user.name)) {
      _nameController.text = user.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _githubController.dispose();
    _linkSubscription?.cancel();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    final l10n = AppLocalizations.of(context)!;
    // 1. Validaciones básicas de UI
    if (_currentPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty) {
      ToastService.error(l10n.profileFillAllFieldsError);
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ToastService.error(l10n.passwordsDoNotMatch);
      return;
    }

    try {
      // 2. Llamada al AuthProvider (el método que pusiste antes)
      final success = await context.read<AuthProvider>().updatePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (success && mounted) {
        ToastService.success(l10n.profilePasswordUpdatedSuccess);
        // Limpiamos los campos y cerramos la sección
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        setState(() => _showPasswordFields = false);
      }
    } catch (e) {
      // Aquí el error vendrá del backend (ej: "La contraseña actual es incorrecta")
      if (mounted)
        ToastService.error(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // NUEVO MÉTODO PARA WEB
  void _checkWebQueryParams() {
    if (!kIsWeb) return;

    // Parseo robusto del query param `code` sin depender de regex.
    final Uri currentUri = Uri.parse(web.window.location.href);
    final String? code = currentUri.queryParameters['code'];

    if (code != null && code.isNotEmpty) {
      web.window.history.replaceState(null, 'Profile', '/#/myprofile');
      _processGitHubCode(code);
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
    final l10n = AppLocalizations.of(context)!;
    final authProvider = context.read<AuthProvider>();

    // Opcional: Mostrar un diálogo de confirmación
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.unlinkGithubTitle),
          content: Text(l10n.unlinkGithubMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel.toUpperCase()),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                l10n.profileDisconnectActionUpper,
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await authProvider.disconnectGitHubAccount();
      if (mounted) {
        _usernameController.clear(); // Limpiamos el campo de username
        _githubController.clear(); // Limpiamos el input visualmente
        ToastService.success(l10n.profileGithubUnlinkedSuccess);
      }
    }
  }

  Future<void> _processGitHubCode(String code) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.linkGitHubAccount(code);

      if (success && mounted) {
        ToastService.success(l10n.profileGithubLinkedSuccess);
      }
    } catch (e) {
      if (mounted) {
        ToastService.error(l10n.profileGithubProcessError(e.toString()));
      }
    }
  }

  Future<void> _handleGitHubOAuth() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      // 1. Obtenemos la configuración desde backend
      final response = await context.read<AuthProvider>().getGitHubConfig();
      final String? clientId = response['clientId'];
      final bool isConfigured = response['isConfigured'] == true;

      if (!isConfigured || clientId == null || clientId.isEmpty) {
        final List<dynamic> missing = response['missingKeys'] is List
            ? response['missingKeys'] as List<dynamic>
            : const [];
        final String missingText = missing.isEmpty
            ? l10n.profileGithubDefaultMissingKeys
            : missing.join(', ');

        if (!mounted) return;
        ToastService.error(l10n.profileGithubOAuthNotConfigured(missingText));
        return;
      }

      // 2. Construimos la URL con el ID que nos dio el server
      final String redirectUri = kIsWeb
          ? "${Uri.base.origin}/#/myprofile"
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
      ToastService.error(l10n.profileServerConnectionError(e.toString()));
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
      );
      if (mounted) {
        ToastService.success(
          AppLocalizations.of(context)!.profileUpdatedSuccess,
        );
      }
    } catch (e) {
      if (mounted) {
        ToastService.error(
          AppLocalizations.of(context)!.profileUpdateError(e.toString()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          margin: const EdgeInsets.all(24),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildAvatarPreview(authProvider),
                      const SizedBox(height: 32),

                      // Layout responsivo para los campos
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth > 700) {
                            return _buildWideContent(authProvider, colorScheme);
                          }
                          return _buildMobileContent(authProvider, colorScheme);
                        },
                      ),

                      const SizedBox(height: 40),
                      const Divider(), // Una línea sutil de separación
                      const SizedBox(height: 24),

                      // EL BOTÓN AHORA ESTÁ CENTRADO Y DESTACADO ABAJO
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: _buildSaveButton(authProvider),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWideContent(AuthProvider authProvider, ColorScheme colorScheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              _buildGeneralFields(),
              const SizedBox(height: 16),
              _buildGitHubSection(authProvider, authProvider.user, colorScheme),
            ],
          ),
        ),
        const SizedBox(width: 32),
        Expanded(child: _buildSecuritySection(authProvider, colorScheme)),
      ],
    );
  }

  Widget _buildMobileContent(
    AuthProvider authProvider,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        _buildGeneralFields(),
        const SizedBox(height: 16),
        _buildGitHubSection(authProvider, authProvider.user, colorScheme),
        const SizedBox(height: 16),
        _buildSecuritySection(authProvider, colorScheme),
      ],
    );
  }

  // Agrupa los campos de Nombre y Username
  Widget _buildGeneralFields() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: l10n.name,
            prefixIcon: const Icon(Icons.person_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (value) =>
              value!.isEmpty ? l10n.fieldRequiredWithName(l10n.name) : null,
        ),
        const SizedBox(height: 16),
        Tooltip(
          message: l10n.profileUsernameCommunityHelper,
          child: TextFormField(
            controller: _usernameController,
            readOnly: true,
            decoration: InputDecoration(
              labelText: l10n.profileUsernameCommunityLabel,
              prefixIcon: const Icon(Icons.alternate_email_rounded),
              suffixIcon: const Icon(Icons.info_outline_rounded, size: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Botón de guardado extraído
  Widget _buildSaveButton(AuthProvider authProvider) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: double.infinity,
      height: 54,
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
        label: Text(
          l10n.profileUpdateButtonUpper,
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
        ),
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  Widget _buildAvatarPreview(AuthProvider authProvider) {
    final user = authProvider.user;
    final String seed = user?.name ?? AppLocalizations.of(context)!.guest;

    // Prioridad: 1. URL de la base de datos, 2. URL validada en sesión, 3. Null
    final String? avatarUrl =
        user?.avatarUrl ?? authProvider.validatedAvatarUrl;
    final bool isGitHubLinked =
        user?.githubId != null && user!.githubId!.isNotEmpty;

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
        if (isGitHubLinked)
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
    final l10n = AppLocalizations.of(context)!;
    final bool isLinked = user?.githubId != null && user!.githubId!.isNotEmpty;

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
                    Text(
                      l10n.profileGithubIdentityTitle,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      isLinked
                          ? l10n.profileGithubLinkedAs(user.githubHandle ?? '')
                          : l10n.profileGithubLinkPrompt,
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
          // Campo solo informativo: se rellena automáticamente tras OAuth
          Tooltip(
            message: isLinked ? '' : l10n.profileGithubFieldHint,
            child: AbsorbPointer(
              child: TextFormField(
                controller: _githubController,
                readOnly: true,
                enabled: false,
                decoration: InputDecoration(
                  hintText: isLinked
                      ? (user?.githubHandle ?? '')
                      : l10n.profileGithubUsernameHint,
                  filled: true,
                  fillColor: Colors.white,
                  prefixText: 'github.com/ ',
                  suffixIcon: isLinked
                      ? null
                      : const Icon(Icons.info_outline_rounded, size: 18),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
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
                  ? Colors.redAccent.withValues(alpha: 0.8)
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
                        isLinked
                            ? l10n.profileDisconnectGithubButton
                            : l10n.profileLinkGithubButton,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySection(
    AuthProvider authProvider,
    ColorScheme colorScheme,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outlineVariant, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lock_outline_rounded, size: 28),
                const SizedBox(width: 12),
                Text(
                  l10n.profileSecurityTitle,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(
                    () => _showPasswordFields = !_showPasswordFields,
                  ),
                  child: Text(
                    _showPasswordFields
                        ? l10n.cancelUpper
                        : l10n.profileChangeUpper,
                  ),
                ),
              ],
            ),
            if (_showPasswordFields) ...[
              const SizedBox(height: 16),
              _buildPasswordField(
                _currentPasswordController,
                l10n.profileCurrentPasswordLabel,
                Icons.password,
              ),
              const SizedBox(height: 12),
              _buildPasswordField(
                _newPasswordController,
                l10n.profileNewPasswordLabel,
                Icons.security,
              ),
              const SizedBox(height: 12),
              _buildPasswordField(
                _confirmPasswordController,
                l10n.profileConfirmNewPasswordLabel,
                Icons.verified_user_outlined,
              ),
              const SizedBox(height: 16),
              _buildUpdatePasswordButton(context, authProvider, colorScheme),
            ] else ...[
              const SizedBox(height: 8),
              Text(
                l10n.profileChangePasswordHint,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
        isDense: true, // Hace el campo un poco más compacto para Web
      ),
    );
  }

  Widget _buildUpdatePasswordButton(
    BuildContext context,
    AuthProvider authProvider,
    ColorScheme colorScheme,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: authProvider.isLoading ? null : _handleChangePassword,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: colorScheme.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(l10n.updatePasswordButton),
      ),
    );
  }
}
