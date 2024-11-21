import 'package:http/http.dart' as http;
import 'dart:convert';

class PokemonApi {
  static Future<Map<String, String>> fetchPokemonSprites(
      String pokemonName) async {
    try {
      final response = await http
          .get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$pokemonName'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'front_default': data['sprites']['front_default'],
          'front_shiny': data['sprites']['front_shiny'],
          'animated': data['sprites']['versions']['generation-v']['black-white']
              ['animated']['front_default'],
        };
      } else {
        print(
            'Failed to fetch Pokemon sprites. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching Pokemon sprites: $e');
    }
    return {};
  }
}
