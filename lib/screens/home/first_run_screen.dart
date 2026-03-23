import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/core/routing/route_names.dart';
import 'package:invenicum/data/services/api_service.dart';
import 'package:invenicum/providers/first_run_provider.dart';
import 'package:provider/provider.dart';

class FirstRunSetupScreen extends StatefulWidget {
  const FirstRunSetupScreen({super.key});

  @override
  State<FirstRunSetupScreen> createState() => _FirstRunSetupScreenState();
}

class _FirstRunSetupScreenState extends State<FirstRunSetupScreen>
    with TickerProviderStateMixin {
  // ── Wizard ──────────────────────────────────────────────────────────────────
  int _currentStep = 0; // 0 = welcome, 1 = form, 2 = success

  // ── Form ────────────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorMessage;

  // ── Animations ───────────────────────────────────────────────────────────────
  late AnimationController _pageController;
  late AnimationController _successController;
  late AnimationController _floatController;

  late Animation<double> _pageFade;
  late Animation<Offset> _pageSlide;
  late Animation<double> _successScale;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();

    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _pageFade = CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeOut,
    );
    _pageSlide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _pageController, curve: Curves.easeOut));

    _successScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
          parent: _successController, curve: Curves.elasticOut),
    );
    _floatAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _pageController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _successController.dispose();
    _floatController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    _pageController.reset();
    setState(() {
      _currentStep = step;
      _errorMessage = null;
    });
    _pageController.forward();
    if (step == 2) _successController.forward();
  }

  Future<void> _createAdmin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiService = context.read<ApiService>();
      await apiService.createFirstAdmin(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        // 🔑 markAsComplete() en lugar de check() para evitar la condición
        // de carrera entre el POST /setup y el GET /first-run.
        context.read<FirstRunProvider>().markAsComplete();
        _goToStep(2);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Build principal ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [const Color(0xFF0A0E27), const Color(0xFF1a1f3a)]
                : [const Color(0xFF667eea), const Color(0xFF764ba2)],
          ),
        ),
        child: Stack(
          children: [
            // ── Círculos decorativos (mismo estilo que LoginScreen) ───────────
            Positioned(
              top: -120,
              right: -80,
              child: _DecorCircle(size: 280, opacity: 0.06),
            ),
            Positioned(
              top: 80,
              right: -40,
              child: _DecorCircle(size: 140, opacity: 0.04),
            ),
            Positioned(
              bottom: -80,
              left: -60,
              child: _DecorCircle(size: 220, opacity: 0.06),
            ),
            Positioned(
              bottom: 120,
              right: 20,
              child: _DecorCircle(size: 80, opacity: 0.05),
            ),

            // ── Contenido ─────────────────────────────────────────────────────
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo flotante animado
                      AnimatedBuilder(
                        animation: _floatAnimation,
                        builder: (context, child) => Transform.translate(
                          offset: Offset(0, _floatAnimation.value),
                          child: child,
                        ),
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.15),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.inventory_2_outlined,
                              size: 42,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Título encima de la card
                      Text(
                        _currentStep == 2
                            ? '¡Todo listo!'
                            : 'Configuración inicial',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _currentStep == 0
                            ? 'Bienvenido a Invenicum'
                            : _currentStep == 1
                                ? 'Paso 2 de 2 · Crear administrador'
                                : 'Tu cuenta ha sido creada',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),

                      // Step indicator
                      if (_currentStep < 2) ...[
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(2, (i) {
                            final isActive = i == _currentStep;
                            final isDone = i < _currentStep;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: isActive ? 24 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: isActive || isDone
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }),
                        ),
                      ],

                      const SizedBox(height: 28),

                      // Card animada
                      FadeTransition(
                        opacity: _pageFade,
                        child: SlideTransition(
                          position: _pageSlide,
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 400),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? const Color(0xFF1E2235)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 32,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(32),
                            child: _buildCurrentStep(isDarkMode),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      Text(
                        'Invenicum © ${DateTime.now().year}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep(bool isDarkMode) {
    switch (_currentStep) {
      case 0:
        return _buildWelcomeStep(isDarkMode);
      case 1:
        return _buildFormStep(isDarkMode);
      case 2:
        return _buildSuccessStep(isDarkMode);
      default:
        return const SizedBox.shrink();
    }
  }

  // ── STEP 0: Bienvenida ───────────────────────────────────────────────────────

  Widget _buildWelcomeStep(bool isDarkMode) {
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subtitleColor = isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Primera configuración',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Parece que es la primera vez que arrancas la app. Vamos a crear tu cuenta de administrador para empezar.',
          style: TextStyle(
              fontSize: 14, color: subtitleColor, height: 1.6),
        ),
        const SizedBox(height: 28),

        ...[
          (Icons.manage_accounts_outlined, 'Crea tu usuario administrador'),
          (Icons.lock_outline_rounded, 'Acceso seguro con contraseña'),
          (Icons.rocket_launch_outlined, 'Listo para usar en segundos'),
        ].map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF667eea).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.$1,
                      size: 18, color: const Color(0xFF667eea)),
                ),
                const SizedBox(width: 14),
                Text(
                  item.$2,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),
        _PrimaryButton(
          label: 'Comenzar configuración',
          icon: Icons.arrow_forward_rounded,
          onPressed: () => _goToStep(1),
        ),
      ],
    );
  }

  // ── STEP 1: Formulario ───────────────────────────────────────────────────────

  Widget _buildFormStep(bool isDarkMode) {
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subtitleColor = isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Crear administrador',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Este usuario tendrá acceso total a la plataforma.',
            style: TextStyle(
                fontSize: 14, color: subtitleColor, height: 1.5),
          ),
          const SizedBox(height: 24),

          _LoginStyleField(
            controller: _nameController,
            label: 'Nombre completo',
            icon: Icons.person_outline_rounded,
            isDarkMode: isDarkMode,
            enabled: !_isLoading,
            textCapitalization: TextCapitalization.words,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Introduce tu nombre.';
              if (v.trim().length < 2) return 'Mínimo 2 caracteres.';
              return null;
            },
          ),
          const SizedBox(height: 16),

          _LoginStyleField(
            controller: _emailController,
            label: 'Correo electrónico',
            icon: Icons.email_outlined,
            isDarkMode: isDarkMode,
            enabled: !_isLoading,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Introduce un email.';
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v.trim())) {
                return 'Email no válido.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          _LoginStyleField(
            controller: _passwordController,
            label: 'Contraseña',
            icon: Icons.lock_outline_rounded,
            isDarkMode: isDarkMode,
            enabled: !_isLoading,
            obscureText: _obscurePassword,
            suffixIcon: GestureDetector(
              onTap: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              child: Icon(
                _obscurePassword
                    ? Icons.visibility_rounded
                    : Icons.visibility_off_rounded,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                size: 20,
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Introduce una contraseña.';
              if (v.length < 8) return 'Mínimo 8 caracteres.';
              return null;
            },
          ),
          const SizedBox(height: 16),

          _LoginStyleField(
            controller: _confirmController,
            label: 'Confirmar contraseña',
            icon: Icons.lock_outline_rounded,
            isDarkMode: isDarkMode,
            enabled: !_isLoading,
            obscureText: _obscureConfirm,
            suffixIcon: GestureDetector(
              onTap: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
              child: Icon(
                _obscureConfirm
                    ? Icons.visibility_rounded
                    : Icons.visibility_off_rounded,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                size: 20,
              ),
            ),
            validator: (v) {
              if (v != _passwordController.text) {
                return 'Las contraseñas no coinciden.';
              }
              return null;
            },
          ),

          // Error banner
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.red.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.red, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                          fontSize: 13, color: Colors.red, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          Row(
            children: [
              SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : () => _goToStep(0),
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text('Volver'),
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16),
                    side: BorderSide(
                      color: isDarkMode
                          ? Colors.grey[600]!
                          : Colors.grey[300]!,
                    ),
                    foregroundColor: isDarkMode
                        ? Colors.grey[300]
                        : Colors.grey[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PrimaryButton(
                  label: 'Crear cuenta',
                  icon: Icons.check_rounded,
                  isLoading: _isLoading,
                  onPressed: _createAdmin,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── STEP 2: Confirmación ─────────────────────────────────────────────────────

  Widget _buildSuccessStep(bool isDarkMode) {
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subtitleColor = isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;
    final cardBg = isDarkMode
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.grey[50]!;
    final cardBorder = isDarkMode
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.grey[200]!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icono animado
        ScaleTransition(
          scale: _successScale,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF667eea).withValues(alpha: 0.12),
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Color(0xFF667eea),
              size: 36,
            ),
          ),
        ),
        const SizedBox(height: 20),

        Text(
          '¡Cuenta creada!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tu cuenta de administrador está lista.\nYa puedes iniciar sesión.',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 14, color: subtitleColor, height: 1.6),
        ),
        const SizedBox(height: 24),

        // Resumen cuenta creada
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CUENTA CREADA',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: Color(0xFF667eea),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.person_outline_rounded,
                      size: 16, color: subtitleColor),
                  const SizedBox(width: 8),
                  Text(
                    _nameController.text.trim(),
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: textColor),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.email_outlined,
                      size: 16, color: subtitleColor),
                  const SizedBox(width: 8),
                  Text(
                    _emailController.text.trim(),
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: textColor),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        _PrimaryButton(
          label: 'Ir al inicio de sesión',
          icon: Icons.login_rounded,
          onPressed: () => context.goNamed(RouteNames.login),
        ),
      ],
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────────────────────────

/// Círculo decorativo de fondo (mismo patrón que LoginScreen)
class _DecorCircle extends StatelessWidget {
  final double size;
  final double opacity;
  const _DecorCircle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}

/// Campo de texto con el estilo exacto de LoginScreen
class _LoginStyleField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isDarkMode;
  final bool enabled;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;

  const _LoginStyleField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.isDarkMode,
    this.enabled = true,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      enabled: enabled,
      validator: validator,
      style: TextStyle(
        fontSize: 15,
        color: isDarkMode ? Colors.white : Colors.black87,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        ),
        prefixIcon: Icon(
          icon,
          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          size: 20,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFF667eea), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDarkMode
                ? Colors.grey[800]!
                : Colors.grey[100]!,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }
}

/// Botón primario con el mismo estilo que el botón de login
class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _PrimaryButton({
    required this.label,
    required this.icon,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF667eea),
          disabledBackgroundColor:
              const Color(0xFF667eea).withValues(alpha: 0.5),
          elevation: 4,
          shadowColor: const Color(0xFF667eea).withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 20, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}