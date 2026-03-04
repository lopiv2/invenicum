import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:invenicum/data/models/veni_response.dart';
import 'api_service.dart';

class ChatService extends ChangeNotifier {
  // 1. Agregamos ChangeNotifier
  final ApiService _apiService;

  // 2. Lista privada de mensajes que persistirá en memoria
  List<Map<String, dynamic>> _messages = [];

  // Getter para que el Widget pueda leer los mensajes
  List<Map<String, dynamic>> get messages => _messages;

  Dio get _dio => _apiService.dio;

  ChatService(this._apiService);

  // Llama a esto después del login o en el initState del MainLayout
  Future<void> loadRemoteHistory() async {
    try {
      final response = await _dio.get('/ai/chat/history');
      if (response.statusCode == 200) {
        _messages = List<Map<String, dynamic>>.from(response.data);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error cargando historial remoto: $e");
    }
  }

  /// Agrega un mensaje a la lista y notifica a la UI
  void addMessage(String text, bool isUser) {
    _messages.add({'text': text, 'isUser': isUser});
    notifyListeners();
  }

  /// Limpia el historial (Llamar esto al cerrar sesión)
  void clearHistory() {
    _messages.clear();
    notifyListeners();
  }

  Future<VeniResponse?> sendMessageToVeni({
    required String message,
    Map<String, dynamic>? contextData,
  }) async {
    // 1. Añadimos localmente para feedback instantáneo
    _messages.add({'text': message, 'isUser': true});
    notifyListeners();

    try {
      final response = await _apiService.dio.post(
        '/ai/chat/veni',
        data: {'message': message, 'context': contextData},
      );

      if (response.statusCode == 200) {
        final veniRes = VeniResponse.fromJson(response.data);

        // La lista se actualizará porque el backend guardó ambos mensajes
        // y nosotros los añadimos aquí para la UI
        _messages.add({'text': veniRes.answer, 'isUser': false});
        notifyListeners();
        return veniRes;
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
    return null;
  }
}
