import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../components/pokemon_card.dart';
import '../components/pokemon_detail_screen.dart';
import '../utils/string_utils.dart';

class PokemonGridView extends StatefulWidget {
  const PokemonGridView({Key? key}) : super(key: key);

  @override
  _PokemonGridViewState createState() => _PokemonGridViewState();
}

class _PokemonGridViewState extends State<PokemonGridView>
    with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> _pokemonList = [];
  final List<Map<String, dynamic>> _filteredPokemonList = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  final int _pageSize = 50;
  final TextEditingController _searchController = TextEditingController();
  late final AnimationController _controller;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    _scrollController = ScrollController()..addListener(_scrollListener);
    _fetchPokemonList();
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_isLoading && _hasMore) {
        _fetchPokemonList();
      }
    }
  }

  Future<void> _fetchPokemonList() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse(
          'https://pokeapi.co/api/v2/pokemon?offset=${_currentPage * _pageSize}&limit=$_pageSize'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<Map<String, dynamic>> newPokemon =
            List<Map<String, dynamic>>.from(data['results']);
        setState(() {
          _pokemonList.addAll(newPokemon);
          _filteredPokemonList.addAll(newPokemon);
          _currentPage++;
          _hasMore = data['next'] != null;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load pokemon');
      }
    } catch (e) {
      print('Error fetching Pokemon list: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterPokemon(String query) {
    setState(() {
      _filteredPokemonList.clear();
      _filteredPokemonList.addAll(_pokemonList.where((pokemon) =>
          pokemon['name'].toLowerCase().contains(query.toLowerCase())));
    });
  }

  void _showPokemonDetails(Map<String, dynamic> pokemonResult) async {
    final response = await http.get(Uri.parse(pokemonResult['url']));
    if (response.statusCode == 200) {
      final pokemonData = json.decode(response.body);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PokemonDetailScreen(pokemon: pokemonData),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load Pokemon details')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Pokédex'),
        backgroundColor: Colors.grey[850],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterPokemon,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search Pokemon',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _filteredPokemonList.length + (_hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < _filteredPokemonList.length) {
                  final pokemonResult = _filteredPokemonList[index];
                  return GestureDetector(
                    onTap: () => _showPokemonDetails(pokemonResult),
                    child: PokemonCard(
                      pokemonResult: pokemonResult,
                      controller: _controller,
                    ),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
