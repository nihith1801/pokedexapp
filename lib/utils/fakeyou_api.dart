// lib/utils/fakeyou_api.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

class FakeYouAPI {
  static const String baseUrl = 'https://api.fakeyou.com';

  static Future<String> generateTTS(String text, String voiceModelToken) async {
    // Step 1: Make TTS request
    final response = await http.post(
      Uri.parse('$baseUrl/tts/inference'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'uuid_idempotency_token':
            DateTime.now().millisecondsSinceEpoch.toString(),
        'tts_model_token': voiceModelToken,
        'inference_text': text,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to generate TTS');
    }

    final data = json.decode(response.body);
    final jobToken = data['inference_job_token'];

    // Step 2: Poll for job completion
    while (true) {
      final jobResponse =
          await http.get(Uri.parse('$baseUrl/tts/job/$jobToken'));
      if (jobResponse.statusCode != 200) {
        throw Exception('Failed to check job status');
      }

      final jobData = json.decode(jobResponse.body);
      final status = jobData['state']['status'];

      if (status == 'complete_success') {
        return 'https://storage.googleapis.com/vocodes-public${jobData['state']['maybe_public_bucket_wav_audio_path']}';
      } else if (status == 'complete_failure' || status == 'dead') {
        throw Exception('TTS generation failed');
      }

      await Future.delayed(const Duration(seconds: 2));
    }
  }
}
