// home.dart

import 'dart:async';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import '../PokeAPI/pokemon_types.dart';
import '../services/audio_player_service.dart';
import '../utils/string_utils.dart';
import 'music_player.dart';
import 'pokemon_grid_view.dart';
import 'chatbot_screen.dart';
import 'pokemon_recognition_screen.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../components/circular_audio_visualizer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? _randomPokemon;
  bool _isLoading = false;
  bool _isDarkMode = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  int _selectedIndex = 0;
  AudioPlayerService? _audioPlayerService;
  bool _isAudioServiceReady = false;
  Uint8List? _currentPokemonCry;
  late Archive _pokemonCriesArchive;

  // Audio samples for the visualizer
  List<double> _audioSamples = List.filled(64, 0.0);

  // Stream subscription for audio samples
  StreamSubscription<List<double>>? _audioSamplesSubscription;

  @override
  void initState() {
    super.initState();
    _loadPokemonCriesArchive();
    _initAudioService();
    _fetchRandomPokemon();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  Future<void> _initAudioService() async {
    try {
      _audioPlayerService = AudioPlayerService();
      bool initialized = await _audioPlayerService!.init();
      setState(() {
        _isAudioServiceReady = initialized;
      });
      if (initialized) {
        _audioSamplesSubscription =
            _audioPlayerService!.audioSamplesStream.listen((samples) {
          setState(() {
            _audioSamples = samples;
          });
        });
        print("Audio service initialized successfully");
      } else {
        print("Audio service initialization failed");
      }
    } catch (e, stackTrace) {
      print("Error initializing audio service: $e");
      print("Stack trace: $stackTrace");
      setState(() {
        _isAudioServiceReady = false;
      });
    }
  }

  Future<void> _loadPokemonCriesArchive() async {
    try {
      final bytes = await rootBundle.load('assets/pokemon_cries.tar.gz');
      final gzipBytes = GZipDecoder().decodeBytes(bytes.buffer.asUint8List());
      _pokemonCriesArchive = TarDecoder().decodeBytes(gzipBytes);
      print("Pokémon cries archive loaded successfully");
    } catch (e) {
      print("Error loading Pokémon cries archive: $e");
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _audioPlayerService?.dispose();
    _audioSamplesSubscription?.cancel(); // Cancel the subscription
    super.dispose();
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
      _animationController.forward(from: 0);
    });
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
        final pokemonData = json.decode(response.body);
        setState(() {
          _randomPokemon = pokemonData;
          _currentPokemonCry = _getPokemonCryFromArchive(pokemonId);
          _isLoading = false;
        });
        print(
            "Pokémon cry ${_currentPokemonCry != null ? 'found' : 'not found'} for ID: $pokemonId");
      } else {
        throw Exception('Failed to load Pokémon');
      }
    } catch (e) {
      print("Error fetching Pokémon: $e");
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to load Pokémon. Please try again.')),
      );
    }
  }

  Uint8List? _getPokemonCryFromArchive(int pokemonId) {
    final fileName = '${pokemonId.toString().padLeft(3, '0')}.ogg';
    final archiveFile =
        _pokemonCriesArchive.findFile('pokemon/cries/$fileName');
    return archiveFile?.content as Uint8List?;
  }

  Future<void> _playPokemonCry() async {
    if (!_isAudioServiceReady || _audioPlayerService == null) {
      print("Audio player is not ready. Attempting to initialize...");
      await _initAudioService();
      if (!_isAudioServiceReady || _audioPlayerService == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Audio player is not ready. Please try again later.')),
        );
        return;
      }
    }

    if (_currentPokemonCry != null) {
      try {
        print("Attempting to play Pokémon cry");
        await _audioPlayerService!.playAudioFromBytes(_currentPokemonCry!);
      } catch (e) {
        print("Error playing Pokémon cry: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to play Pokémon cry. Please try again.')),
        );
      }
    } else {
      print("No cry available for this Pokémon");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No Pokémon cry available for this Pokémon.')),
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
        const SnackBar(content: Text('Failed to sign out. Please try again.')),
      );
    }
  }

  void _navigateToGridView(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PokemonGridView()),
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
        const SnackBar(content: Text('Please log in to access the chatbot.')),
      );
    }
  }

  void _navigateToMusicPlayer(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MusicPlayer()),
    );
  }

  void _navigateToTFLite(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PokemonRecognitionScreen()),
    );
  }

  Widget _buildPokemonImage() {
    String? animatedSprite = _randomPokemon!['sprites']['versions']
        ['generation-v']['black-white']['animated']['front_default'];
    String fallbackImage = _randomPokemon!['sprites']['other']
        ['official-artwork']['front_default'];

    return Stack(
      alignment: Alignment.center,
      children: [
        // Visualizer (behind everything)
        CircularAudioVisualizer(
          size: 320,
          waveformData: _audioSamples,
          startColor: Colors.blue.withOpacity(0.5),
          endColor: Colors.purple.withOpacity(0.5),
        ),
        // Circular background
        Container(
          width: 320,
          height: 320,
          decoration: BoxDecoration(
            color: _isDarkMode
                ? Colors.grey[800]!.withOpacity(0.8)
                : Colors.grey[200]!.withOpacity(0.8),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (_isDarkMode ? Colors.black : Colors.grey[500]!)
                    .withOpacity(0.5),
                offset: const Offset(10, 10),
                blurRadius: 20,
              ),
              BoxShadow(
                color: (_isDarkMode ? Colors.grey[700] : Colors.white70)!
                    .withOpacity(0.5),
                offset: const Offset(-10, -10),
                blurRadius: 20,
              ),
            ],
          ),
        ),
        // Pokémon image
        Center(
          child: animatedSprite != null
              ? Image.network(
                  animatedSprite,
                  height: 280,
                  width: 280,
                  fit: BoxFit.contain,
                  frameBuilder: (BuildContext context, Widget child, int? frame,
                      bool wasSynchronouslyLoaded) {
                    if (wasSynchronouslyLoaded) {
                      return child;
                    }
                    return AnimatedOpacity(
                      opacity: frame == null ? 0 : 1,
                      duration: const Duration(seconds: 1),
                      curve: Curves.easeOut,
                      child: child,
                    );
                  },
                )
              : Image.network(
                  fallbackImage,
                  height: 280,
                  width: 280,
                  fit: BoxFit.contain,
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Color baseColor = _isDarkMode ? Colors.grey[800]! : Colors.grey[200]!;
    Color textColor = _isDarkMode ? Colors.white : Colors.black87;
    Color accentColor = _isDarkMode ? Colors.tealAccent : Colors.teal;

    return Scaffold(
      backgroundColor: baseColor,
      appBar: AppBar(
        backgroundColor: baseColor,
        elevation: 0,
        title: Text('Home', style: TextStyle(color: textColor)),
        leading: Icon(Icons.menu, color: textColor),
        actions: [
          IconButton(
            icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: textColor),
            onPressed: _toggleTheme,
          ),
          IconButton(
            icon: Icon(Icons.logout, color: textColor),
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: GestureDetector(
        onDoubleTap: _toggleTheme,
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: accentColor))
            : _randomPokemon == null
                ? Center(
                    child: Text('No Pokémon data available',
                        style: TextStyle(color: textColor)))
                : SingleChildScrollView(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          _buildPokemonImage(),
                          const SizedBox(height: 20),
                          NeumorphicText(
                            '#${_randomPokemon!['id'].toString().padLeft(3, '0')}',
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                            textColor: textColor,
                            baseColor: baseColor,
                          ),
                          const SizedBox(height: 10),
                          NeumorphicText(
                            _randomPokemon!['name'].toUpperCase(),
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                            textColor: textColor,
                            baseColor: baseColor,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Height: ${_randomPokemon!['height'] / 10} m',
                            style: TextStyle(color: textColor),
                          ),
                          Text(
                            'Weight: ${_randomPokemon!['weight'] / 10} kg',
                            style: TextStyle(color: textColor),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Types:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                (_randomPokemon!['types'] as List).map((type) {
                              final typeName = type['type']['name'] as String;
                              final typeColor =
                                  PokemonTypes.getTypeColor(typeName);
                              return NeumorphicContainer(
                                color: baseColor,
                                borderRadius: 30,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                        color: typeColor.withOpacity(0.3),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: typeColor.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: SvgPicture.asset(
                                            'assets/icons/$typeName.svg',
                                            height: 24,
                                            width: 24,
                                            color: typeColor,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          capitalizeFirstLetter(typeName),
                                          style: TextStyle(
                                            color: textColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),
                          NeumorphicButton(
                            onPressed: _playPokemonCry,
                            color: baseColor,
                            child: Text(
                              'Play Pokémon Cry',
                              style: TextStyle(color: textColor),
                            ),
                          ),
                          const SizedBox(height: 20),
                          NeumorphicButton(
                            onPressed: _fetchRandomPokemon,
                            color: baseColor,
                            child: Text(
                              'Get Another Random Pokémon',
                              style: TextStyle(color: textColor),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: baseColor,
        color: _isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
        buttonBackgroundColor:
            _isDarkMode ? Colors.grey[600]! : Colors.grey[400]!,
        height: 60,
        items: <Widget>[
          Icon(Icons.home, size: 30, color: textColor),
          Icon(Icons.grid_view, size: 30, color: textColor),
          Icon(Icons.chat_bubble, size: 30, color: textColor),
          Icon(Icons.music_note, size: 30, color: textColor),
          Icon(Icons.science, size: 30, color: textColor),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          switch (index) {
            case 0:
              // Home
              break;
            case 1:
              _navigateToGridView(context);
              break;
            case 2:
              _navigateToChatbot(context);
              break;
            case 3:
              _navigateToMusicPlayer(context);
              break;
            case 4:
              _navigateToTFLite(context);
              break;
          }
        },
      ),
    );
  }
}

// NeumorphicContainer Class
class NeumorphicContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double borderRadius;
  final Color color;

  const NeumorphicContainer({
    Key? key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius = 15,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: color.brighten().withOpacity(0.1),
            offset: const Offset(-6, -6),
            blurRadius: 16,
          ),
          BoxShadow(
            color: color.darken().withOpacity(0.1),
            offset: const Offset(6, 6),
            blurRadius: 16,
          ),
        ],
      ),
      child: child,
    );
  }
}

// NeumorphicButton Class
class NeumorphicButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color color;

  const NeumorphicButton({
    Key? key,
    required this.onPressed,
    required this.child,
    required this.color,
  }) : super(key: key);

  @override
  _NeumorphicButtonState createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
  bool _isPressed = false;

  void _onPointerDown(PointerDownEvent event) {
    setState(() {
      _isPressed = true;
    });
  }

  void _onPointerUp(PointerUpEvent event) {
    setState(() {
      _isPressed = false;
    });
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(30),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: widget.color.brighten().withOpacity(0.1),
                    offset: const Offset(-6, -6),
                    blurRadius: 16,
                  ),
                  BoxShadow(
                    color: widget.color.darken().withOpacity(0.1),
                    offset: const Offset(6, 6),
                    blurRadius: 16,
                  ),
                ],
        ),
        child: widget.child,
      ),
    );
  }
}

// NeumorphicText Class
class NeumorphicText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color textColor;
  final Color baseColor;

  const NeumorphicText(
    this.text, {
    Key? key,
    required this.style,
    required this.textColor,
    required this.baseColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Light shadow
        Positioned(
          top: 1,
          left: 1,
          child: Text(
            text,
            style: style.copyWith(
              color: baseColor.brighten(),
            ),
          ),
        ),
        // Dark shadow
        Positioned(
          bottom: 1,
          right: 1,
          child: Text(
            text,
            style: style.copyWith(
              color: baseColor.darken(),
            ),
          ),
        ),
        // Main text
        Text(
          text,
          style: style.copyWith(color: textColor),
        ),
      ],
    );
  }
}

// Color Extension
extension ColorExtension on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  Color brighten([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }
}
