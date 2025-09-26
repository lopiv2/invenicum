import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/widgets/sidebar_layout.dart';
import '../services/api_service.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _Header(),
          Expanded(
            child: Row(
              children: [
                SidebarLayout(),
                Expanded(
                  child: Container(color: Colors.grey[100], child: child),
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
  // ... (Sin cambios)
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: double.infinity,
      color: Theme.of(context).primaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Text(
            'Invenicum',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              // NOTA: Si ApiService() se crea aquí, debe ser singleton o inyectado.
              // Asumiendo que funciona por ahora, pero idealmente se inyectaría.
              await ApiService().logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
    );
  }
}

  

