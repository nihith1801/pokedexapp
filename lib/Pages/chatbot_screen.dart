import 'package:flutter/material.dart';
import 'package:particles_fly/particles_fly.dart';
import 'package:pokedexapp/Pages/home.dart';
import '../components/chat_message_list.dart';
import '../components/message_input.dart';
import '../utils/chatbot_service.dart';
import '../models/chat_message.dart';

class ChatbotScreen extends StatefulWidget {
  final String userId;

  const ChatbotScreen({super.key, required this.userId});

  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  late final ChatbotService _chatbotService;
  bool _isDarkMode = true;

  @override
  void initState() {
    super.initState();
    _chatbotService = ChatbotService();
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty) return;

    final message = ChatMessage(
      text: _controller.text,
      isUser: true,
    );

    setState(() {
      _messages.insert(0, message);
      _controller.clear();
    });

    try {
      final botMessage = await _chatbotService.sendMessage(message.text);
      setState(() {
        _messages.insert(0, botMessage);
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        _messages.insert(
          0,
          ChatMessage(
            text: 'Sorry, an error occurred while processing your request: $e',
            isUser: false,
          ),
        );
      });
    }
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final baseColor = _isDarkMode ? Colors.grey[900]! : Colors.grey[200]!;
    final textColor = _isDarkMode ? Colors.white : Colors.black87;

    return Theme(
      data: ThemeData(
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        primaryColor: baseColor,
        scaffoldBackgroundColor: baseColor,
      ),
      child: Scaffold(
        appBar: NeumorphicAppBar(
          title:
              Text('Pokedex AI Assistant', style: TextStyle(color: textColor)),
          backgroundColor: baseColor,
          actions: [
            NeumorphicButton(
              onPressed: _toggleTheme,
              color: baseColor,
              child: Icon(
                _isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: textColor,
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            _buildParticleBackground(size),
            _buildTranslucentOverlay(),
            _buildChatInterface(baseColor),
          ],
        ),
      ),
    );
  }

  Widget _buildParticleBackground(Size size) {
    return Positioned.fill(
      child: ParticlesFly(
        height: size.height,
        width: size.width,
        connectDots: true,
        numberOfParticles: 100,
        onTapAnimation: true,
        speedOfParticles: 2,
      ),
    );
  }

  Widget _buildTranslucentOverlay() {
    return Positioned.fill(
      child: Container(
        color: (_isDarkMode ? Colors.black : Colors.white).withOpacity(0.8),
      ),
    );
  }

  Widget _buildChatInterface(Color baseColor) {
    return Column(
      children: [
        Expanded(
          child: NeumorphicContainer(
            color: baseColor,
            child: ChatMessageList(messages: _messages),
          ),
        ),
        NeumorphicContainer(
          color: baseColor,
          child: MessageInput(
            controller: _controller,
            onSend: _sendMessage,
          ),
        ),
      ],
    );
  }
}

class NeumorphicAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final Color backgroundColor;
  final List<Widget>? actions;

  const NeumorphicAppBar({
    super.key,
    required this.title,
    required this.backgroundColor,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return NeumorphicContainer(
      color: backgroundColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(child: title),
              if (actions != null) ...actions!,
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class NeumorphicContainer extends StatelessWidget {
  final Widget child;
  final Color color;
  final double borderRadius;

  const NeumorphicContainer({
    super.key,
    required this.child,
    required this.color,
    this.borderRadius = 15,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: color.brighten(),
            offset: const Offset(-5, -5),
            blurRadius: 10,
          ),
          BoxShadow(
            color: color.darken(),
            offset: const Offset(5, 5),
            blurRadius: 10,
          ),
        ],
      ),
      child: child,
    );
  }
}

class NeumorphicButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color color;

  const NeumorphicButton({
    super.key,
    required this.onPressed,
    required this.child,
    required this.color,
  });

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
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(8),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: widget.color.brighten(),
                    offset: const Offset(-2, -2),
                    blurRadius: 5,
                  ),
                  BoxShadow(
                    color: widget.color.darken(),
                    offset: const Offset(2, 2),
                    blurRadius: 5,
                  ),
                ],
        ),
        child: widget.child,
      ),
    );
  }
}
