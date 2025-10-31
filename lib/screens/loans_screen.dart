// lib/screens/loans_screen.dart

import 'package:flutter/material.dart';

class LoansScreen extends StatelessWidget {
  final String containerId;
  
  // El constructor requiere el containerId que viene de la ruta de GoRouter
  const LoansScreen({super.key, required this.containerId}); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Préstamos y Asignaciones'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.compare_arrows, size: 80, color: Colors.blueAccent),
              const SizedBox(height: 20),
              Text(
                'Esta pantalla mostrará todos los préstamos y activos asignados.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              Text(
                'Contenedor ID: $containerId',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 30),
              // Aquí iría el ListView o DataGrid de préstamos
              // Ejemplo de botón para crear un nuevo préstamo/asignación
              ElevatedButton.icon(
                icon: const Icon(Icons.add_task),
                label: const Text('Registrar Nuevo Préstamo'),
                onPressed: () {
                  // context.go('/container/$containerId/loans/new');
                  print('Navegar al formulario de creación de préstamo');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}