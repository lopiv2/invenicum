import 'package:flutter/material.dart';
import 'package:invenicum/data/services/toast_service.dart';
import 'package:stac/stac.dart';
import 'package:provider/provider.dart';
import 'package:invenicum/providers/auth_provider.dart';

// Modelo de acción (Asegúrate de que esté importado o definido)
class InvenicumAction {
  final String method;
  final Map<String, dynamic> params;

  InvenicumAction({required this.method, required this.params});

  factory InvenicumAction.fromJson(Map<String, dynamic> json) =>
      InvenicumAction(
        method: json['method'] ?? '',
        params: json['params'] ?? {},
      );
}

class InvenicumSdkParser extends StacActionParser<InvenicumAction> {
  // 1. Recibimos el nombre del usuario desde la inicialización
  final String? userName;

  InvenicumSdkParser({this.userName});

  @override
  String get actionType => 'invenicum_sdk';

  @override
  InvenicumAction getModel(Map<String, dynamic> json) {
    debugPrint(
      "Ejecutando getModel para: $json",
    ); // Si esto no sale en consola, el parser no está registrado
    return InvenicumAction.fromJson(json);
  }

  @override
  void onCall(BuildContext context, InvenicumAction model) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      switch (model.method) {
        case 'getUserName':
          // Ahora userName es accesible aquí
          ToastService.info("Usuario actual: ${userName ?? 'Invitado'}");
          break;

        case 'showAlert':
          ToastService.success(model.params['message'] ?? 'Acción ejecutada');
          break;

        case 'navigate':
          final path = model.params['path'];
          if (path != null) {
            debugPrint("Navegando a: $path");
            // Ejemplo: context.go(path); // Si usas GoRouter
          }
          break;

        case 'logout':
          // Podemos acceder a los providers mediante el context que nos da Stac
          context.read<AuthProvider>().logout();
          ToastService.info("Sesión cerrada");
          break;

        default:
          debugPrint("Método SDK no reconocido: ${model.method}");
      }
    });
  }
}
