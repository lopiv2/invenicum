import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/providers/auth_provider.dart';
import 'package:invenicum/providers/inventory_item_provider.dart';
import 'package:invenicum/widgets/sidebar_layout.dart';
import 'package:provider/provider.dart';
import 'package:random_avatar/random_avatar.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // 🎨 Tu tema personalizado
    return Scaffold(
      body: Column(
        children: [
          _Header(),
          Expanded(
            child: Row(
              children: [
                SidebarLayout(),
                Expanded(
                  child: Container(color: theme.colorScheme.surfaceContainer, child: child),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Obtenemos el nombre del usuario para el avatar de forma segura
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final String avatarSeed = user?.name ?? "Guest";
    //print ("Avatar seed: $avatarSeed");

    return Container(
      height: 60,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        // Esta Row actúa como el contenedor de las 3 columnas
        children: [
          // 1. Columna Izquierda: Logo
          SizedBox(
            width: 150, // Ancho fijo opcional para el área del logo
            child: Image.asset(
              'assets/images/invenicum_logo.png',
              height: 90, // Ajuste proporcional
              fit: BoxFit.contain,
              alignment: Alignment.center,
            ),
          ),

          // 2. Columna Central: Espacio en blanco (flexible)
          const Spacer(), 

          // 3. Columna Derecha: Avatar y Menú
          PopupMenuButton<String>(
            offset: const Offset(0, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) async {
              if (value == 'logout') {
                context.read<InventoryItemProvider>().resetState();
                await context.read<AuthProvider>().logout();
                if (context.mounted) {
                  context.go('/login');
                }
              }
            },
            // Usamos un MouseRegion o el mismo child del PopupMenu
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24, width: 2),
                ),
                child: RandomAvatar(
                  avatarSeed,
                  width: 40,
                  height: 40,
                ),
              ),
            ),
            itemBuilder: (BuildContext context) => [
              _buildPopupItem('profile', Icons.account_circle_outlined, 'Mi Perfil'),
              _buildPopupItem('settings', Icons.settings_outlined, 'Ajustes'),
              const PopupMenuDivider(),
              _buildPopupItem('logout', Icons.logout, 'Cerrar sesión', isDestructive: true),
            ],
          ),
        ],
      ),
    );
  }

  // Método auxiliar para no repetir código en los ítems del menú
  PopupMenuItem<String> _buildPopupItem(String value, IconData icon, String text, {bool isDestructive = false}) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: isDestructive ? Colors.redAccent : Colors.black54, size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(color: isDestructive ? Colors.redAccent : Colors.black87),
          ),
        ],
      ),
    );
  }
}
