import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class PokemonDisplayComponent extends StatefulWidget {
  final Map<String, dynamic> pokemonData;

  const PokemonDisplayComponent({super.key, required this.pokemonData});

  @override
  _PokemonDisplayComponentState createState() =>
      _PokemonDisplayComponentState();
}

class _PokemonDisplayComponentState extends State<PokemonDisplayComponent> {
  late Future<String> _summaryFuture;
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _summaryFuture = _generateSummary();
  }

  Future<String> _generateSummary() async {
    final model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: 'AIzaSyBsvyh6-PXyQ_DIQXKp3sBd8p07ZVM28xs',
    );
    final content = [
      Content.text(
          'Generate a brief summary of the Pokémon ${widget.pokemonData['name']}.')
    ];
    final response = await model.generateContent(content);
    return response.text ?? 'Unable to generate summary.';
  }

  void _speakSummary(String summary) async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(summary);
  }

  @override
  Widget build(BuildContext context) {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPokemonImage(),
            const SizedBox(height: 20),
            _buildPokemonName(),
            const SizedBox(height: 10),
            _buildPokemonInfo(),
            const SizedBox(height: 20),
            _buildBaseStats(),
            const SizedBox(height: 20),
            _buildSummarySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPokemonImage() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: BoxShape.circle,
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
      child: Hero(
        tag: 'pokemon-${widget.pokemonData['id']}',
        child: CachedNetworkImage(
          imageUrl: widget.pokemonData['sprites']['front_default'],
          height: 250,
          width: 250,
          placeholder: (context, url) => const CircularProgressIndicator(),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      ),
    );
  }

  Widget _buildPokemonName() {
    return Text(
      widget.pokemonData['name'].toUpperCase(),
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.grey[800],
      ),
    );
  }

  Widget _buildPokemonInfo() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _buildInfoItem(Icons.category, 'Type: ${_getTypes()}'),
        _buildInfoItem(
            Icons.height, 'Height: ${widget.pokemonData['height'] / 10} m'),
        _buildInfoItem(Icons.monitor_weight,
            'Weight: ${widget.pokemonData['weight'] / 10} kg'),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[400]!,
            offset: const Offset(2, 2),
            blurRadius: 5,
            spreadRadius: 1,
          ),
          const BoxShadow(
            color: Colors.white,
            offset: Offset(-2, -2),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.grey[800], size: 16),
          const SizedBox(width: 5),
          Text(text, style: TextStyle(color: Colors.grey[800])),
        ],
      ),
    );
  }

  Widget _buildBaseStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Base Stats:',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 200,
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
          child: RadarChart(
            RadarChartData(
              radarShape: RadarShape.polygon,
              ticksTextStyle: const TextStyle(color: Colors.transparent),
              radarBorderData: BorderSide(color: Colors.grey[800]!, width: 2),
              gridBorderData: BorderSide(color: Colors.grey[600]!, width: 1),
              tickCount: 6,
              titleTextStyle: TextStyle(color: Colors.grey[800]!, fontSize: 12),
              getTitle: (index, angle) {
                final stat = (widget.pokemonData['stats'] as List)[index];
                return RadarChartTitle(text: stat['stat']['name']);
              },
              dataSets: [
                RadarDataSet(
                  fillColor: Colors.blue.withOpacity(0.4),
                  borderColor: Colors.blue,
                  entryRadius: 3,
                  dataEntries: (widget.pokemonData['stats'] as List)
                      .map((stat) =>
                          RadarEntry(value: stat['base_stat'].toDouble()))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummarySection() {
    return FutureBuilder<String>(
      future: _summaryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.red));
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pokémon Summary:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                snapshot.data!,
                style: TextStyle(color: Colors.grey[800]),
              ),
              const SizedBox(height: 10),
              _buildNeumorphicButton(
                onPressed: () => _speakSummary(snapshot.data!),
                icon: Icons.volume_up,
                label: 'Read Summary',
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildNeumorphicButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(30),
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.grey[800]),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(color: Colors.grey[800], fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  String _getTypes() {
    return (widget.pokemonData['types'] as List)
        .map((t) => t['type']['name'])
        .join(', ');
  }
}
