import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/string_utils.dart';
import '../PokeAPI/pokemon_api.dart';
import 'enlarged_image_dialog.dart';
import 'pokemon_type_icons.dart';
import 'pokemon_detail_screen.dart';

class PokemonCard extends StatelessWidget {
  final Map<String, dynamic> pokemonResult;
  final AnimationController controller;

  const PokemonCard({
    Key? key,
    required this.pokemonResult,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pokemonId = PokemonAPI.extractPokemonId(pokemonResult['url']);
    final imageUrl =
        "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$pokemonId.png";

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Colors.grey[800],
      child: InkWell(
        onTap: () => _navigateToPokemonDetail(context),
        child: Stack(
          children: [
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RotationTransition(
                    turns: controller,
                    child: const Opacity(
                      opacity: 0.2,
                      child: Icon(
                        Icons.catching_pokemon,
                        size: 100,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '#${pokemonId.padLeft(3, '0')}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      onTap: () => _showEnlargedImage(context, imageUrl),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 50,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    capitalizeFirstLetter(pokemonResult['name']),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Expanded(
                    flex: 1,
                    child: FutureBuilder<List<String>>(
                      future:
                          PokemonAPI.fetchPokemonTypes(pokemonResult['url']),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return const Text('Error loading types',
                              overflow: TextOverflow.ellipsis);
                        } else if (snapshot.hasData) {
                          return PokemonTypeIcons(types: snapshot.data!);
                        } else {
                          return const SizedBox();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEnlargedImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EnlargedImageDialog(imageUrl: imageUrl);
      },
    );
  }

  void _navigateToPokemonDetail(BuildContext context) async {
    final pokemonDetails =
        await PokemonAPI.fetchPokemonDetails(pokemonResult['url']);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PokemonDetailScreen(pokemon: pokemonDetails),
      ),
    );
  }
}
