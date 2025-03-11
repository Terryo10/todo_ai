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
  final int maxRetries;
  final Duration retryDelay;
  final double temperature;

  TodoProvider({
    this.apiKey = 'AIzaSyAD7QLvtQaz6Y9WQvZJuXW8QA2UB-wZRHQ',
    this.baseUrl =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent',
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 2),
    this.temperature = 0.7, // Adjust for more consistent outputs
  });

  Future<List<String>> getTasksFromGemini({required String prompt}) async {
    int attempts = 0;
    Exception? lastException;

    while (attempts < maxRetries) {
      try {
        final response = await _makeApiRequest(prompt);
        return _parseTasksFromResponse(response);
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());

        // Only retry on specific error conditions
        if (e is GeminiApiException &&
            (e.statusCode == 429 ||
                e.statusCode == 500 ||
                e.statusCode == 503)) {
          attempts++;
          await Future.delayed(retryDelay * attempts); // Exponential backoff
          continue;
        }

        // For other errors, just rethrow
        if (e is GeminiApiException) {
          rethrow;
        }
        throw GeminiApiException('Failed to process tasks: ${e.toString()}');
      }
    }

    // If we've exhausted retries
    throw GeminiApiException(
        'Failed after $maxRetries attempts: ${lastException.toString()}');
  }

  Future<Map<String, dynamic>> _makeApiRequest(String prompt) async {
    final url = Uri.parse('$baseUrl?key=$apiKey');

    // More specific prompt with explicit formatting instructions
    final enhancedPrompt = '''
Generate a numbered list of specific, actionable tasks for the following goal:
"$prompt"

Requirements:
1. Each task must start with a number followed by a period (e.g., "1.", "2.")
2. Each task must be clear and actionable
3. Provide between 5-10 specific tasks
4. Format each task on a new line
5. Focus on practical, concrete steps

Example format:
1. First specific task
2. Second specific task
''';

    final payload = {
      "contents": [
        {
          "parts": [
            {"text": enhancedPrompt}
          ]
        }
      ],
      "generationConfig": {
        "temperature": temperature,
        "topP": 0.95,
        "topK": 40,
        "maxOutputTokens": 1024,
      },
      "safetySettings": [
        {
          "category": "HARM_CATEGORY_HARASSMENT",
          "threshold": "BLOCK_MEDIUM_AND_ABOVE"
        },
        {
          "category": "HARM_CATEGORY_HATE_SPEECH",
          "threshold": "BLOCK_MEDIUM_AND_ABOVE"
        },
        {
          "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
          "threshold": "BLOCK_MEDIUM_AND_ABOVE"
        },
        {
          "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
          "threshold": "BLOCK_MEDIUM_AND_ABOVE"
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
    } on http.Response catch (e) {
      throw GeminiApiException('HTTP error: ${e.statusCode}: ${e.body}');
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
        // Try alternate extraction method if the first one fails
        final alternativeTasks = _extractTasksAlternative(output);
        if (alternativeTasks.isNotEmpty) {
          return alternativeTasks;
        }
        throw GeminiApiException('No tasks found in response');
      }
      return tasks;
    } catch (e) {
      throw GeminiApiException('Failed to parse response: ${e.toString()}');
    }
  }

  List<String> _extractTasksFromText(String text) {
    final lines = text.split('\n');

    // Primary pattern: Match numbered lists (e.g., "1. Task description")
    final numberedTaskPattern = RegExp(r'^\s*\d+\.\s*(.+)$');

    final tasks = <String>[];

    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) continue;

      final match = numberedTaskPattern.firstMatch(trimmedLine);
      if (match != null && match.group(1) != null) {
        final taskText = match.group(1)!.trim();
        if (taskText.isNotEmpty) {
          tasks.add(taskText);
        }
      }
    }

    return tasks;
  }

  // Alternative extraction method for different formatting
  List<String> _extractTasksAlternative(String text) {
    // Try to extract tasks from bullet points or other formats
    final bulletPatterns = [
      RegExp(r'^\s*[•\-\*]\s*(.+)$'), // Bullet points: •, -, *
      RegExp(r'^\s*Task\s+\d+:\s*(.+)$', caseSensitive: false), // "Task 1: ..."
      RegExp(r'^\s*Step\s+\d+:\s*(.+)$', caseSensitive: false), // "Step 1: ..."
    ];

    final lines = text.split('\n');
    final tasks = <String>[];

    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) continue;

      bool matched = false;
      for (final pattern in bulletPatterns) {
        final match = pattern.firstMatch(trimmedLine);
        if (match != null && match.group(1) != null) {
          final taskText = match.group(1)!.trim();
          if (taskText.isNotEmpty) {
            tasks.add(taskText);
            matched = true;
            break;
          }
        }
      }

      // If no structured format, and we have no tasks yet,
      // try to extract sentences that look like tasks
      if (!matched &&
          tasks.isEmpty &&
          trimmedLine.length > 10 &&
          trimmedLine.endsWith('.') &&
          !trimmedLine.contains(':') &&
          trimmedLine.contains(' ')) {
        tasks.add(trimmedLine);
      }
    }

    return tasks;
  }

  Future<String> getTodoTopicFromGemini({required String prompt}) async {
    int attempts = 0;
    Exception? lastException;

    while (attempts < maxRetries) {
      try {
        final url = Uri.parse('$baseUrl?key=$apiKey');
        final enhancedPrompt =
            'Create a brief, concise title (5 words or less) for a todo list about: "$prompt"';

        final payload = {
          "contents": [
            {
              "parts": [
                {"text": enhancedPrompt}
              ]
            }
          ],
          "generationConfig": {
            "temperature": 0.4, // Lower temperature for more predictable titles
            "maxOutputTokens": 30, // Short output for titles
          }
        };

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

        // Clean up the title response
        String title = output
            .trim()
            .replaceAll('"', '') // Remove quotes
            .replaceAll('Title:', '') // Remove "Title:" prefix if present
            .trim();

        // If empty or too long, generate a fallback
        if (title.isEmpty || title.length > 50) {
          title =
              "Todo: ${prompt.length > 20 ? '${prompt.substring(0, 20)}...' : prompt}";
        }

        return title;
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());

        if (e is GeminiApiException &&
            (e.statusCode == 429 ||
                e.statusCode == 500 ||
                e.statusCode == 503)) {
          attempts++;
          await Future.delayed(retryDelay * attempts);
          continue;
        }

        if (e is GeminiApiException) {
          rethrow;
        }
        throw GeminiApiException('Failed to get topic: ${e.toString()}');
      }
    }

    // Fallback title as last resort
    return "Todo List: ${prompt.length > 20 ? '${prompt.substring(0, 20)}...' : prompt}";
  }
}
