import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class EmotionDetectionService {
  final String apiKey;

  EmotionDetectionService() : apiKey = dotenv.env['DEEPAI_API_KEY'] ?? '' {
    print('Loaded API KEY: $apiKey');
  }

  Future<String> detectEmotion(File imageFile) async {
    print('DetectEmotion called!');

    final url = Uri.parse('https://api.deepai.org/api/emotion-recognition');
    final request =
        http.MultipartRequest('POST', url)
          ..headers['api-key'] = apiKey
          ..files.add(
            await http.MultipartFile.fromPath('image', imageFile.path),
          );
    final response = await request.send();
    print('DeepAI HTTP status: ${response.statusCode}');
    if (response.statusCode != 200) {
      final body = await response.stream.bytesToString();
      print('DeepAI ERROR BODY: $body');
      return "unknown";
    }
    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final data = jsonDecode(responseBody);
      print('DEBUGGGG : DeepAI raw response: $data');
      if (data["output"] != null && data["output"].isNotEmpty) {
        final face = data["output"][0];
        final emotions = face["emotions"] as Map<String, dynamic>;
        final sorted =
            emotions.entries.toList()..sort(
              (a, b) => (b.value as double).compareTo(a.value as double),
            );
        return sorted.first.key; // e.g. "happy"
      }
      return "unknown";
    } else {
      return "unknown";
    }
  }
}
