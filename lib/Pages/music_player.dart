import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

double progress = 0.0; // Ensure this is initialized properly

class MusicPlayer extends StatefulWidget {
  const MusicPlayer({Key? key}) : super(key: key);

  @override
  MusicPlayerState createState() => MusicPlayerState();
}

class MusicPlayerState extends State<MusicPlayer>
    with SingleTickerProviderStateMixin {
  bool isPlaying = false;
  late AnimationController _rotationController;
  double progress = 0.0;

  String? currentSongTitle = 'Loading...';
  String? currentArtistName = '';
  String? currentAlbumImageUrl;
  String? currentTrackUri;

  final String clientId = 'YOUR_CLIENT_ID';
  final String redirectUrl = 'YOUR_REDIRECT_URI';

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    await _connectToSpotifyRemote();
    await _loadLastPlayedTrack();
  }

  Future<void> _connectToSpotifyRemote() async {
    try {
      bool result = await SpotifySdk.connectToSpotifyRemote(
        clientId: clientId,
        redirectUrl: redirectUrl,
      );
      if (result) {
        print('Connected to Spotify');
      } else {
        print('Failed to connect to Spotify');
      }
    } on PlatformException catch (e) {
      print("Error connecting to Spotify: ${e.code} ${e.message}");
    } on MissingPluginException {
      print("Spotify SDK not implemented on this platform");
    }
  }

  Future<void> _loadLastPlayedTrack() async {
    final prefs = await SharedPreferences.getInstance();
    String? lastTrackUri = prefs.getString('last_track_uri');

    if (lastTrackUri != null) {
      await _playTrack(lastTrackUri);
    } else {
      await _playRandomPokemonTrack();
    }
  }

  Future<void> _playTrack(String trackUri) async {
    try {
      await SpotifySdk.play(spotifyUri: trackUri);
      setState(() {
        currentTrackUri = trackUri;
        isPlaying = true;
        _rotationController.repeat();
      });
      await _updateCurrentTrackInfo();
    } on PlatformException catch (e) {
      print("Error playing track: ${e.code} ${e.message}");
    } on MissingPluginException {
      print("Spotify SDK not implemented on this platform");
    }
  }

  Future<void> _playRandomPokemonTrack() async {
    List<String> pokemonTrackUris = [
      'spotify:track:3ZFTkvIE7kyPt6Nu3PEa7V',
      'spotify:track:6Qyc6fS4DsZjB2mRW9DsQs',
      'spotify:track:0I6XXV8vP6ISvdyPFRuJYA',
    ];

    String randomTrackUri =
        pokemonTrackUris[math.Random().nextInt(pokemonTrackUris.length)];

    await _playTrack(randomTrackUri);
  }

  Future<void> _updateCurrentTrackInfo() async {
    try {
      var playerState = await SpotifySdk.getPlayerState();
      if (playerState != null && playerState.track != null) {
        setState(() {
          currentSongTitle = playerState.track!.name;
          currentArtistName = playerState.track!.artist.name;
          currentAlbumImageUrl = playerState.track!.imageUri.raw;
          currentTrackUri = playerState.track!.uri;
          isPlaying = !playerState.isPaused;

          progress = playerState.playbackPosition / playerState.track!.duration;
          if (progress > 1.0) progress = 1.0;

          if (isPlaying) {
            _rotationController.repeat();
          } else {
            _rotationController.stop();
          }
        });
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('last_track_uri', currentTrackUri!);
      }
    } on PlatformException catch (e) {
      print("Error fetching current track: ${e.code} ${e.message}");
    } on MissingPluginException {
      print("Spotify SDK not implemented on this platform");
    }
  }

  void _togglePlayPause() async {
    try {
      if (isPlaying) {
        await SpotifySdk.pause();
        _rotationController.stop();
      } else {
        await SpotifySdk.resume();
        _rotationController.repeat();
      }
      setState(() {
        isPlaying = !isPlaying;
      });
    } on PlatformException catch (e) {
      print("Error toggling play/pause: ${e.code} ${e.message}");
    } on MissingPluginException {
      print("Spotify SDK not implemented on this platform");
    }
  }

  void _nextTrack() async {
    try {
      await SpotifySdk.skipNext();
      await _updateCurrentTrackInfo();
    } on PlatformException catch (e) {
      print("Error skipping to next track: ${e.code} ${e.message}");
    } on MissingPluginException {
      print("Spotify SDK not implemented on this platform");
    }
  }

  void _previousTrack() async {
    try {
      await SpotifySdk.skipPrevious();
      await _updateCurrentTrackInfo();
    } on PlatformException catch (e) {
      print("Error skipping to previous track: ${e.code} ${e.message}");
    } on MissingPluginException {
      print("Spotify SDK not implemented on this platform");
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  String _getImageUrlFromSpotifyUri(String imageUri) {
    if (imageUri.startsWith('spotify:image:')) {
      return "https://i.scdn.co/image/${imageUri.split(':').last}";
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[850] : Colors.grey[200],
      appBar: AppBar(
        title: Text('Music Player',
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
        backgroundColor: isDarkMode ? Colors.grey[850] : Colors.grey[200],
        iconTheme:
            IconThemeData(color: isDarkMode ? Colors.white : Colors.black),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 300,
                      height: 300,
                      child: CustomPaint(
                        painter: ProgressArcPainter(progress), // Fixed
                      ),
                    ),
                    NeumorphicContainer(
                      width: 250,
                      height: 250,
                      borderRadius: 125,
                      isDarkMode: isDarkMode,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(125),
                        child: AnimatedBuilder(
                          animation: _rotationController,
                          builder: (_, child) {
                            return Transform.rotate(
                              angle: isPlaying
                                  ? _rotationController.value * 2 * math.pi
                                  : 0,
                              child: child,
                            );
                          },
                          child: currentAlbumImageUrl != null
                              ? Image.network(
                                  _getImageUrlFromSpotifyUri(
                                      currentAlbumImageUrl!),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.music_note,
                                        size: 100);
                                  },
                                )
                              : const Icon(Icons.music_note, size: 100),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Text(
                    currentSongTitle ?? 'Loading...',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    currentArtistName ?? '',
                    style: TextStyle(
                      fontSize: 18,
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NeumorphicButton(
                  onPressed: _previousTrack,
                  isDarkMode: isDarkMode,
                  child: const Icon(Icons.skip_previous),
                ),
                const SizedBox(width: 20),
                NeumorphicButton(
                  onPressed: _togglePlayPause,
                  isDarkMode: isDarkMode,
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                  ),
                ),
                const SizedBox(width: 20),
                NeumorphicButton(
                  onPressed: _nextTrack,
                  isDarkMode: isDarkMode,
                  child: const Icon(Icons.skip_next),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class NeumorphicButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final bool isDarkMode;

  const NeumorphicButton({
    Key? key,
    required this.onPressed,
    required this.child,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = isDarkMode ? Colors.grey[850]! : Colors.grey[200]!;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isDarkMode ? Colors.black87 : Colors.grey[300]!,
              offset: const Offset(4, 4),
              blurRadius: 15,
              spreadRadius: 1,
            ),
            BoxShadow(
              color: isDarkMode ? Colors.grey[800]! : Colors.white,
              offset: const Offset(-4, -4),
              blurRadius: 15,
              spreadRadius: 1,
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class NeumorphicContainer extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final double borderRadius;
  final bool isDarkMode;

  const NeumorphicContainer({
    Key? key,
    required this.child,
    required this.width,
    required this.height,
    this.borderRadius = 0,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = isDarkMode ? Colors.grey[850]! : Colors.grey[200]!;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black87 : Colors.grey[300]!,
            offset: const Offset(4, 4),
            blurRadius: 15,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: isDarkMode ? Colors.grey[800]! : Colors.white,
            offset: const Offset(-4, -4),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: child,
    );
  }
}

class ProgressArcPainter extends CustomPainter {
  final double progress;

  ProgressArcPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2,
    );
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
