import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:path_provider/path_provider.dart';

class AudioPlayerService {
  AudioPlayer? _audioPlayer;
  final _audioSamplesController = StreamController<List<double>>.broadcast();
  bool _isInitialized = false;

  Stream<List<double>> get audioSamplesStream => _audioSamplesController.stream;

  bool get isInitialized => _isInitialized;

  Future<bool> init() async {
    if (_isInitialized) return true;

    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.speech());
      _audioPlayer = AudioPlayer();
      await _audioPlayer!.setVolume(1.0);
      _audioPlayer!.playbackEventStream.listen((event) {},
          onError: (Object e, StackTrace stackTrace) {
        print('A stream error occurred: $e');
      });
      _isInitialized = true;
      print("AudioPlayerService initialized successfully");
      return true;
    } catch (e, stackTrace) {
      print("Error initializing AudioPlayerService: $e");
      print("Stack trace: $stackTrace");
      _isInitialized = false;
      return false;
    }
  }

  Future<void> playAudioFromBytes(Uint8List audioBytes) async {
    if (!_isInitialized) {
      throw StateError('AudioPlayerService is not initialized');
    }

    try {
      print("Attempting to play audio from bytes");
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/temp_audio.ogg');
      await tempFile.writeAsBytes(audioBytes);
      await _audioPlayer?.setFilePath(tempFile.path);
      await _audioPlayer?.play();
      _startSamplingAudio();
    } catch (e, stackTrace) {
      print("Error playing audio: $e");
      print("Stack trace: $stackTrace");
      rethrow;
    }
  }

  void _startSamplingAudio() {
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_audioPlayer?.playing ?? false) {
        _audioSamplesController.add(_generateRandomSamples());
      } else {
        timer.cancel();
        _audioSamplesController.add(List.filled(64, 0.0));
      }
    });
  }

  List<double> _generateRandomSamples() {
    return List.generate(64, (_) => Random().nextDouble());
  }

  void dispose() {
    _audioPlayer?.dispose();
    _audioSamplesController.close();
  }
}
