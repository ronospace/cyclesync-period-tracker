import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class SymptomAIService {
  static final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  static const String _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

  Future<String> analyzeSymptoms(String userInput) async {
    try {
      final response = await http.post(
        Uri.parse('$_endpoint?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text":
                      "The user is describing menstrual symptoms. Respond with helpful, medically-informed advice in a calm and supportive tone.\n\nSymptoms: $userInput",
                },
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'].trim();
      } else {
        return 'Error: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      return 'Failed to analyze symptoms: $e';
    }
  }
}
