import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'dart:typed_data';
import '../components/image_picker_component.dart';
import '../components/pokemon_display_component.dart';
import '../services/pokemon_service.dart';

class PokemonRecognitionScreen extends StatefulWidget {
  const PokemonRecognitionScreen({super.key});

  @override
  _PokemonRecognitionScreenState createState() =>
      _PokemonRecognitionScreenState();
}

class _PokemonRecognitionScreenState extends State<PokemonRecognitionScreen> {
  final PokemonService _pokemonService = PokemonService();
  final Gemini _gemini = Gemini.instance;
  String? _recognizedPokemon;
  Map<String, dynamic>? _pokemonData;
  bool _isLoading = false;

  Future<void> _onImagePicked(List<int> imageBytes) async {
    setState(() {
      _isLoading = true;
      _recognizedPokemon = null;
      _pokemonData = null;
    });

    try {
      print('Sending request to Gemini API...');
      final response = await _gemini.textAndImage(
        text:
            'Identify the Pokemon in this image. Only respond with the Pokemon\'s name.',
        images: [Uint8List.fromList(imageBytes)],
      );

      print(
          'Received response from Gemini API: ${response?.content?.parts?.last.text}');
      if (response != null && response.content != null) {
        final pokemonName = response.content?.parts?.last.text?.trim();
        if (pokemonName != null && pokemonName.isNotEmpty) {
          setState(() {
            _recognizedPokemon = pokemonName;
          });
          await _fetchPokemonData(pokemonName);
        }
      } else {
        print('Unexpected response format: ${response?.content}');
        _showErrorSnackBar(message: 'Unexpected response from the server');
      }
    } catch (e) {
      print('Error recognizing Pokemon: $e');
      _showErrorSnackBar(message: e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchPokemonData(String pokemonName) async {
    try {
      final data = await _pokemonService.getPokemonData(pokemonName);
      setState(() {
        _pokemonData = data;
      });
    } catch (e) {
      print('Error fetching Pokemon data: $e');
      _showErrorSnackBar(
          message: 'Failed to fetch Pokémon data. Please try again.');
    }
  }

  void _showErrorSnackBar(
      {String message = 'Failed to recognize Pokémon. Please try again.'}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokémon Recognition'),
        backgroundColor: Colors.black45,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[300],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildNeumorphicContainer(
                child: ImagePickerComponent(onImagePicked: _onImagePicked),
              ),
              const SizedBox(height: 20),
              if (_isLoading) const CircularProgressIndicator(),
              if (_pokemonData != null)
                PokemonDisplayComponent(pokemonData: _pokemonData!),
              if (_recognizedPokemon != null)
                _buildNeumorphicContainer(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Recognized Pokémon: $_recognizedPokemon',
                      style: TextStyle(fontSize: 18, color: Colors.grey[800]),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNeumorphicContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[400]!,
            offset: const Offset(4, 4),
            blurRadius: 15,
            spreadRadius: 1,
          ),
          const BoxShadow(
            color: Colors.white,
            offset: Offset(-4, -4),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }
}
