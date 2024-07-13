import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChatbotScreen extends StatefulWidget {
  final String userId;

  ChatbotScreen({required this.userId});

  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  List<ChatMessage> _messages = [];
  final FlutterTts flutterTts = FlutterTts();
  final GenerativeModel _model = GenerativeModel(
    model: 'gemini-pro',
    apiKey: 'API_KEY',
  );
  late ChatSession _chat;

  @override
  void initState() {
    super.initState();
    print('API Key: ${_model.apiKey}'); // Debug print for API key
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final String? messagesJson = prefs.getString('chat_${widget.userId}');
    if (messagesJson != null) {
      final List<dynamic> decodedMessages = json.decode(messagesJson);
      setState(() {
        _messages =
            decodedMessages.map((m) => ChatMessage.fromJson(m)).toList();
      });
    }
    _initChat();
  }

  void _initChat() {
    List<Content> history = [
      Content.text(
          "You are a Pokedex AI assistant. You have extensive knowledge about all Pokemon, their types, abilities, and characteristics. When asked about a specific Pokemon, provide detailed information including its Pokedex number, type, abilities, and a brief description. If requested, you can also provide a summary of the Pokemon and its sprite image URL. Always be helpful and enthusiastic about sharing Pokemon knowledge!")
    ];

    // Add previous messages to the chat history
    for (var message in _messages) {
      if (message.isUser) {
        history.add(Content.text(message.text));
      } else {
        history.add(Content.model(message.text));
      }
    }

    _chat = _model.startChat(history: history);
  }

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final String messagesJson =
        json.encode(_messages.map((m) => m.toJson()).toList());
    await prefs.setString('chat_${widget.userId}', messagesJson);
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty) return;

    ChatMessage message = ChatMessage(
      text: _controller.text,
      isUser: true,
    );

    setState(() {
      _messages.insert(0, message);
      _controller.clear();
    });

    try {
      final response = await _chat.sendMessage(Content.text(message.text));
      if (response.text != null && response.text!.isNotEmpty) {
        final botMessage = ChatMessage(
          text: response.text!,
          isUser: false,
        );

        setState(() {
          _messages.insert(0, botMessage);
        });

        // Check if the response contains Pokemon information and fetch the sprite
        if (response.text!.contains('Pokédex number')) {
          final pokemonName =
              response.text!.split('\n')[0].split(':')[1].trim().toLowerCase();
          final spriteUrl = await _fetchPokemonSprite(pokemonName);
          if (spriteUrl != null) {
            setState(() {
              _messages.insert(
                  0,
                  ChatMessage(
                    text: '',
                    isUser: false,
                    imageUrl: spriteUrl,
                  ));
            });
          }
        }
      } else {
        throw Exception('Empty response from chatbot');
      }

      _saveMessages(); // Save messages after each interaction
    } catch (e, stackTrace) {
      print('Error: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _messages.insert(
            0,
            ChatMessage(
              text:
                  'Sorry, an error occurred while processing your request: $e',
              isUser: false,
            ));
      });
    }
  }

  Future<String?> _fetchPokemonSprite(String pokemonName) async {
    try {
      final response = await http
          .get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$pokemonName'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['sprites']['other']['official-artwork']['front_default'];
      }
    } catch (e) {
      print('Error fetching Pokemon sprite: $e');
    }
    return null;
  }

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pokedex AI Assistant'),
        backgroundColor: Colors.red,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Ask about a Pokemon...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              backgroundImage: AssetImage('assets/pokedex_avatar.png'),
            ),
            SizedBox(width: 8.0),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: message.isUser ? Colors.blue[100] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: message.imageUrl != null
                      ? Image.network(message.imageUrl!, height: 200)
                      : Text(message.text),
                ),
                if (!message.isUser && message.text.isNotEmpty)
                  IconButton(
                    icon: Icon(Icons.volume_up),
                    onPressed: () => _speak(message.text),
                  ),
              ],
            ),
          ),
          if (message.isUser) ...[
            SizedBox(width: 8.0),
            CircleAvatar(
              child: Icon(Icons.person),
            ),
          ],
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final String? imageUrl;

  ChatMessage({required this.text, required this.isUser, this.imageUrl});

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'],
      isUser: json['isUser'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'imageUrl': imageUrl,
    };
  }
}
