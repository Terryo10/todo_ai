import 'dart:convert';
import 'package:http/http.dart' as http;

class TodoProvider {

  Future<List<String>> getTasksFromGemini(String userGoal) async {
  final apiKey = 'YOUR_GEMINI_API_KEY'; // tichazoisa ENV yedu
  final apiUrl = 'YOUR_GEMINI_API_ENDPOINT';

  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    },
    body: jsonEncode({'prompt': 'Given the goal of "$userGoal", suggest a list of actionable tasks.'}),
  );

  if (response.statusCode == 200) {
    final jsonData = jsonDecode(response.body);
    final tasks = (jsonData['tasks'] as List).cast<String>();
    return tasks;
  } else {
    throw Exception('Failed to get tasks from Gemini API: ${response.statusCode}');
  }
}
}