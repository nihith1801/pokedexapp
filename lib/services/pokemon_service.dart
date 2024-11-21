import 'package:http/http.dart' as http;
import 'dart:convert';

class PokemonService {
  final String baseUrl = 'https://pokeapi.co/api/v2';

  Future<Map<String, dynamic>> getPokemonData(String pokemonName) async {
    final response = await http
        .get(Uri.parse('$baseUrl/pokemon/${pokemonName.toLowerCase()}'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load pokemon data');
    }
  }
}
