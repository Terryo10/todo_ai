import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiApiException implements Exception {
  final int? statusCode;
  final String message;

  GeminiApiException(this.message, [this.statusCode]);

  @override
  String toString() => statusCode != null
      ? 'GeminiApiException: $message (Status: $statusCode)'
      : 'GeminiApiException: $message';
}

class TodoProvider {
  final String apiKey;
  final String baseUrl;

  TodoProvider({
    this.apiKey = 'AIzaSyAD7QLvtQaz6Y9WQvZJuXW8QA2UB-wZRHQ',
    this.baseUrl =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent',
  });

  Future<List<String>> getTasksFromGemini({required String prompt}) async {
    try {
      final response = await _makeApiRequest(prompt);
      return _parseTasksFromResponse(response);
    } catch (e) {
      if (e is GeminiApiException) {
        rethrow;
      }
      throw GeminiApiException('Failed to process tasks: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> _makeApiRequest(String prompt) async {
    final url = Uri.parse('$baseUrl?key=$apiKey');
    final payload = {
      "contents": [
        {
          "parts": [
            {
              "text":
                  'Given the goal of "$prompt", suggest a list of actionable tasks.'
            }
          ]
        }
      ]
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode != 200) {
        throw GeminiApiException(
          'API request failed: ${response.body}',
          response.statusCode,
        );
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } on http.ClientException catch (e) {
      throw GeminiApiException('Network error: ${e.toString()}');
    } on FormatException catch (e) {
      throw GeminiApiException('Invalid response format: ${e.toString()}');
    }
  }

  List<String> _parseTasksFromResponse(Map<String, dynamic> responseData) {
    final candidates = responseData['candidates'] as List?;

    if (candidates == null || candidates.isEmpty) {
      throw GeminiApiException('No candidates found in response');
    }

    try {
      final output = candidates[0]['content']['parts'][0]['text'] as String;
      final tasks = _extractTasksFromText(output);

      if (tasks.isEmpty) {
        throw GeminiApiException('No tasks found in response');
      }
      return tasks;
    } catch (e) {
      throw GeminiApiException('Failed to parse response: ${e.toString()}');
    }
  }

  List<String> _extractTasksFromText(String text) {
    final lines = text.split('\n');

    return lines
        .where((line) => RegExp(r'^\d+\.').hasMatch(line.trim()))
        .map((line) => line.replaceAll(RegExp(r'^\d+\.\s*'), '').trim())
        .where((task) => task.isNotEmpty)
        .toList();
  }

  Future<String> getTodoTopicFromGemini({required String prompt}) async {
    final url = Uri.parse('$baseUrl?key=$apiKey');
    final payload = {
      "contents": [
        {
          "parts": [
            {
              "text":
                  'Given the goal of "$prompt", write a small topic for the todo.'
            }
          ]
        }
      ]
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode != 200) {
        throw GeminiApiException(
          'API request failed: ${response.body}',
          response.statusCode,
        );
      }
      final responseData = jsonDecode(response.body);

      final candidates = responseData['candidates'] as List?;

      if (candidates == null || candidates.isEmpty) {
        throw GeminiApiException('No candidates found in response');
      }

      final output = candidates[0]['content']['parts'][0]['text'] as String;
      return output;
    } catch (e) {
      if (e is GeminiApiException) {
        rethrow;
      }
      throw GeminiApiException('Failed to process tasks: ${e.toString()}');
    }
  }
}
