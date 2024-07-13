import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import '../components/top_bar.dart';
import 'pokemon_grid_view.dart';
import 'chatbot_screen.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? _randomPokemon;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchRandomPokemon();
  }

  Future<void> _fetchRandomPokemon() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final random = Random();
      final pokemonId = random.nextInt(898) + 1;

      final response = await http
          .get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$pokemonId'));
      if (response.statusCode == 200) {
        setState(() {
          _randomPokemon = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load Pokémon');
      }
    } catch (e) {
      print("Error fetching Pokémon: $e");
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load Pokémon. Please try again.')),
      );
    }
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      print("Error signing out: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign out. Please try again.')),
      );
    }
  }

  void _navigateToGridView(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PokemonGridView()),
    );
  }

  void _navigateToChatbot(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChatbotScreen(userId: user.uid)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in to access the chatbot.')),
      );
    }
  }

  Widget _buildPokemonImage() {
    String? animatedSprite = _randomPokemon!['sprites']['versions']
        ['generation-v']['black-white']['animated']['front_default'];
    String fallbackImage = _randomPokemon!['sprites']['other']
        ['official-artwork']['front_default'];

    if (animatedSprite != null) {
      return Image.network(
        animatedSprite,
        height: 300,
        width: 300,
        fit: BoxFit.contain,
        frameBuilder: (BuildContext context, Widget child, int? frame,
            bool wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) {
            return child;
          }
          return AnimatedOpacity(
            child: child,
            opacity: frame == null ? 0 : 1,
            duration: const Duration(seconds: 1),
            curve: Curves.easeOut,
          );
        },
      );
    } else {
      return Image.network(
        fallbackImage,
        height: 300,
        width: 300,
        fit: BoxFit.contain,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(
        title: 'Home',
        onSignOut: () => _signOut(context),
        actions: [
          IconButton(
            icon: Icon(Icons.grid_view),
            onPressed: () => _navigateToGridView(context),
          ),
          IconButton(
            icon: Icon(Icons.chat_bubble),
            onPressed: () => _navigateToChatbot(context),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _randomPokemon == null
              ? Center(child: Text('No Pokémon data available'))
              : SingleChildScrollView(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        _buildPokemonImage(),
                        const SizedBox(height: 20),
                        Text(
                          '#${_randomPokemon!['id'].toString().padLeft(3, '0')}',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _randomPokemon!['name'].toUpperCase(),
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text('Height: ${_randomPokemon!['height'] / 10} m'),
                        Text('Weight: ${_randomPokemon!['weight'] / 10} kg'),
                        const SizedBox(height: 10),
                        Text(
                          'Types:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Wrap(
                          spacing: 8,
                          children: (_randomPokemon!['types'] as List)
                              .map((type) => Chip(
                                    label: Text(type['type']['name']),
                                    backgroundColor: Colors.blue,
                                    labelStyle: TextStyle(color: Colors.white),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _fetchRandomPokemon,
                          child: const Text('Get Another Random Pokémon'),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => _signOut(context),
                          child: const Text('Sign Out'),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
