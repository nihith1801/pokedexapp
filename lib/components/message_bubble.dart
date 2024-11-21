import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/chat_message.dart';
import 'sprite_image.dart';

class MessageBubble extends StatefulWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  _MessageBubbleState createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with SingleTickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  late AnimationController _controller;
  late Animation<double> _animation;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
    _playPopSound();
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  Future<void> _playPopSound() async {
    await _audioPlayer.play(AssetSource('pop_sound.mp3'));
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: Row(
          mainAxisAlignment: widget.message.isUser
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!widget.message.isUser) _buildAvatar(),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: widget.message.isUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: widget.message.isUser
                          ? Colors.blue[400]
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.message.text,
                          style: TextStyle(
                            color: widget.message.isUser
                                ? Colors.white
                                : Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                        if (widget.message.spriteUrls.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _buildSpriteImages(),
                        ],
                      ],
                    ),
                  ),
                  if (!widget.message.isUser)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: _buildTextToSpeechButton(),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (widget.message.isUser) _buildAvatar(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 16,
      backgroundColor:
          widget.message.isUser ? Colors.blue[400] : Colors.grey[300],
      child: widget.message.isUser
          ? const Icon(Icons.person, size: 18, color: Colors.white)
          : Image.asset('assets/pokedex_avatar.png', width: 20, height: 20),
    );
  }

  Widget _buildSpriteImages() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.message.spriteUrls['front_default'] != null)
          SpriteImage(
              url: widget.message.spriteUrls['front_default']!,
              label: 'Default'),
        if (widget.message.spriteUrls['front_shiny'] != null)
          SpriteImage(
              url: widget.message.spriteUrls['front_shiny']!, label: 'Shiny'),
        if (widget.message.spriteUrls['animated'] != null)
          SpriteImage(
              url: widget.message.spriteUrls['animated']!, label: 'Animated'),
      ],
    );
  }

  Widget _buildTextToSpeechButton() {
    return GestureDetector(
      onTap: () => _speak(widget.message.text),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.volume_up, size: 16, color: Colors.black54),
      ),
    );
  }
}
