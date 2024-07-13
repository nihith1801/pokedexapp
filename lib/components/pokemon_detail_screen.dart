import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/string_utils.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class PokemonDetailScreen extends StatefulWidget {
  final Map<String, dynamic> pokemon;

  const PokemonDetailScreen({Key? key, required this.pokemon})
      : super(key: key);

  @override
  _PokemonDetailScreenState createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  final FlutterTts flutterTts = FlutterTts();
  bool isAnimated = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  void _initTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    String defaultSprite = widget.pokemon['sprites']['front_default'];
    String? animatedSprite = widget.pokemon['sprites']['versions']
        ['generation-v']['black-white']['animated']['front_default'];

    return Scaffold(
      appBar: AppBar(
        title: Text(capitalizeFirstLetter(widget.pokemon['name'])),
        backgroundColor: Colors.grey[850],
        actions: [
          IconButton(
            icon: const Icon(Icons.mic),
            onPressed: () {
              _speak(
                  "This is ${widget.pokemon['name']}. ${widget.pokemon['name']} is a Pokémon with ID number ${widget.pokemon['id']}.");
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey[900],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isAnimated = !isAnimated;
                    });
                    _showEnlargedImage(
                        context,
                        isAnimated && animatedSprite != null
                            ? animatedSprite
                            : defaultSprite);
                  },
                  child: CachedNetworkImage(
                    imageUrl: isAnimated && animatedSprite != null
                        ? animatedSprite
                        : defaultSprite,
                    height: 200,
                    width: 200,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 100,
                    ),
                  ),
                ),
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isAnimated = !isAnimated;
                    });
                  },
                  child: Text(isAnimated ? 'Show Static' : 'Show Animated'),
                ),
              ),
              const SizedBox(height: 20),
              _buildInfoRow('Pokédex ID', '#${widget.pokemon['id']}'),
              _buildInfoRow('Height', '${widget.pokemon['height'] / 10} m'),
              _buildInfoRow('Weight', '${widget.pokemon['weight'] / 10} kg'),
              _buildInfoRow(
                  'Base Experience', '${widget.pokemon['base_experience']}'),
              const SizedBox(height: 20),
              const Text(
                'Types:',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              Wrap(
                spacing: 8,
                children: (widget.pokemon['types'] as List)
                    .map((type) => Chip(
                          label:
                              Text(capitalizeFirstLetter(type['type']['name'])),
                          backgroundColor: Colors.grey[700],
                          labelStyle: const TextStyle(color: Colors.white),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 20),
              const Text(
                'Abilities:',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              Wrap(
                spacing: 8,
                children: (widget.pokemon['abilities'] as List)
                    .map((ability) => Chip(
                          label: Text(
                              '${capitalizeFirstLetter(ability['ability']['name'])}${ability['is_hidden'] ? ' (Hidden)' : ''}'),
                          backgroundColor: Colors.grey[700],
                          labelStyle: const TextStyle(color: Colors.white),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 20),
              const Text(
                'Base Stats:',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 300,
                child: _buildRadarChart(),
              ),
              ...(widget.pokemon['stats'] as List)
                  .map((stat) => _buildStatBar(stat)),
              const SizedBox(height: 20),
              const Text(
                'AI Summary:',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              FutureBuilder<String>(
                future: _getGeminiAISummary(widget.pokemon['name']),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.white));
                  } else if (snapshot.hasData) {
                    return Text(snapshot.data!,
                        style: const TextStyle(color: Colors.white));
                  } else {
                    return const Text('No summary available',
                        style: TextStyle(color: Colors.white));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadarChart() {
    return RadarChart(
      RadarChartData(
        radarShape: RadarShape.polygon,
        ticksTextStyle: const TextStyle(color: Colors.transparent),
        radarBorderData: BorderSide(color: Colors.white, width: 2),
        gridBorderData: BorderSide(color: Colors.white30, width: 1),
        tickCount: 6,
        // Adjusted to better fit Pokémon stats (0-255)
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        getTitle: (index, angle) {
          final stat = (widget.pokemon['stats'] as List)[index];
          return RadarChartTitle(
              text: capitalizeFirstLetter(stat['stat']['name']));
        },
        dataSets: [
          RadarDataSet(
            fillColor: Colors.blue.withOpacity(0.4),
            borderColor: Colors.blue,
            entryRadius: 3,
            dataEntries: (widget.pokemon['stats'] as List)
                .map((stat) => RadarEntry(value: stat['base_stat'].toDouble()))
                .toList(),
          ),
        ],
        titlePositionPercentageOffset: 0.2,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildStatBar(Map<String, dynamic> stat) {
    const maxStat = 255.0; // Max possible base stat
    final baseStat = stat['base_stat'] as int;
    final percentage = baseStat / maxStat;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${capitalizeFirstLetter(stat['stat']['name'])}: $baseStat',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[700],
            valueColor: AlwaysStoppedAnimation<Color>(
              _getColorForStat(baseStat),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForStat(int statValue) {
    if (statValue < 50) return Colors.red;
    if (statValue < 100) return Colors.orange;
    if (statValue < 150) return Colors.yellow;
    return Colors.green;
  }

  void _showEnlargedImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: InteractiveViewer(
            panEnabled: true,
            boundaryMargin: EdgeInsets.all(20),
            minScale: 0.5,
            maxScale: 4,
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.contain,
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 50,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<String> _getGeminiAISummary(String pokemonName) async {
    const apiKey = 'API_KEY';
    final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);

    final prompt =
        'Give me a brief summary of the Pokemon $pokemonName in about 3-4 sentences.';

    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);

    return response.text ?? 'Unable to generate summary.';
  }
}
