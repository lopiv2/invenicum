import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:invenicum/data/models/veni_response.dart';
import 'api_service.dart';

class ChatService extends ChangeNotifier {
  // 1. Add ChangeNotifier
  final ApiService _apiService;

  // 2. Private list of messages that will persist in memory
  List<Map<String, dynamic>> _messages = [];

  // Getter so the Widget can read the messages
  List<Map<String, dynamic>> get messages => _messages;

  Dio get _dio => _apiService.dio;

  ChatService(this._apiService);

  // Call this after login or in the MainLayout initState
  Future<void> loadRemoteHistory() async {
    try {
      final response = await _dio.get('/ai/chat/history');
      if (response.statusCode == 200) {
        _messages = List<Map<String, dynamic>>.from(response.data);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error loading remote history: $e");
    }
  }

  /// Add a message to the list and notify the UI
  void addMessage(String text, bool isUser) {
    _messages.add({'text': text, 'isUser': isUser});
    notifyListeners();
  }

  /// Clear the history (call this on logout)
  void clearHistory() {
    _messages.clear();
    notifyListeners();
  }

  /// Purge remote chat history and clear local state.
  Future<void> purgeRemoteHistory() async {
    try {
      final response = await _dio.delete('/ai/chat/history');
      if (response.statusCode == 200 || response.statusCode == 204) {
        clearHistory();
        return;
      }
      throw Exception('Unexpected status: ${response.statusCode}');
    } on DioException catch (e) {
      final message =
          e.response?.data?['message']?.toString() ??
          e.response?.data?['error']?.toString() ??
          'Error purging chat history';
      throw Exception(message);
    }
  }

  Future<VeniResponse?> sendMessageToVeni({
    required String message,
    required String locale, // 👈 Nuevo parámetro obligatorio
    Map<String, dynamic>? contextData,
  }) async {
    // Only show the user message if it is not the internal greeting command.
    // SAY_HELLO_INITIAL is processed in the backend but never appears in the chat.
    final bool isInternalCommand = message == "SAY_HELLO_INITIAL";
    if (!isInternalCommand) {
      _messages.add({'text': message, 'isUser': true});
      notifyListeners();
    }

    try {
      // 2. Combine existing context with locale
      final Map<String, dynamic> finalContext = {
        ...?contextData,
        'locale': locale, // 👈 We send 'es', 'en', etc.
      };

      final response = await _apiService.dio.post(
        '/ai/chat/veni',
        data: {'message': message, 'context': finalContext},
      );

      if (response.statusCode == 200) {
        final veniRes = VeniResponse.fromJson(response.data);

        _messages.add({'text': veniRes.answer, 'isUser': false});
        notifyListeners();
        return veniRes;
      }
    } catch (e) {
      debugPrint("Error in ChatService: $e");
    }
    return null;
  }
}