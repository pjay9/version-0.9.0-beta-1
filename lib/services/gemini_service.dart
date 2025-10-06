// lib/services/gemini_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class GeminiService {
  final String _apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-05-20:generateContent?key=${ApiConfig.geminiApiKey}';

  /// Generates a detailed, instructional response from the LLM.
  Future<String> getRepairGuide(String partName, String userQuestion) async {
    final systemPrompt =
        "You are a professional, expert mechanic. Your response must be direct, clear, and focused on practical steps. You MUST refer to the recognized part by name and highlight it in **bold** to draw attention to the location of the fix.";

    final userPrompt =
        "The user is looking at the '$partName'. The user is asking: '$userQuestion'. Provide a detailed, step-by-step guide on how to address their question related to the component shown.";

    final payload = {
      "contents": [
        {
          "parts": [
            {"text": userPrompt}
          ]
        }
      ],
      "systemInstruction": {"parts": [{"text": systemPrompt}]}
    };

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        return "Error: Could not reach AI service. Status code: ${response.statusCode}";
      }
    } catch (e) {
      return "An error occurred during network communication: $e";
    }
  }
}