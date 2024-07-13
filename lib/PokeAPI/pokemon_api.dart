import 'dart:convert';
import 'package:http/http.dart' as http;

class PokemonAPI {
  static Future<List<String>> fetchPokemonTypes(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final types = (data['types'] as List)
          .map((type) => type['type']['name'] as String)
          .toList();
      return types;
    } else {
      throw Exception('Failed to load Pokemon types');
    }
  }

  static String extractPokemonId(String url) {
    final regex = RegExp(r'/(\d+)/$');
    final match = regex.firstMatch(url);
    return match?.group(1) ?? '';
  }

  static Future<Map<String, dynamic>> fetchPokemonDetails(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load Pokemon details');
    }
  }
}
