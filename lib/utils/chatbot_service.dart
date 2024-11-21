import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/chat_message.dart';
import 'poke_api.dart';

class ChatbotService {
  late final GenerativeModel _model;
  late final ChatSession _chat;

  ChatbotService() {
    _initModel();
  }

  void _initModel() {
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: 'AIzaSyBsvyh6-PXyQ_DIQXKp3sBd8p07ZVM28xs',
    );
    _chat = _model.startChat(history: [
      Content('user', [
        TextPart(
            "You are a Pokedex AI assistant. Provide accurate and detailed information about Pokemon when asked. For each Pokemon query, include its Pokedex number, type(s), abilities, and a brief description. If the query isn't about a specific Pokemon, respond appropriately to general Pokemon-related questions or casual conversation. Always stay in character as a Rotom Pokedex AI. Give respones like for eg. Giratina, the renegade pokemon, a ghost and dragon type...then continue with the summary. Use this as a reference."),
      ]),
    ]);
  }

  Future<ChatMessage> sendMessage(String message) async {
    try {
      final content = Content('user', [TextPart(message)]);
      final response = await _chat.sendMessage(content);
      final responseText = response.text;
      if (responseText != null && responseText.isNotEmpty) {
        final botMessage = ChatMessage(
          text: responseText,
          isUser: false,
        );

        if (responseText.contains('Pokédex number')) {
          final pokemonName =
              responseText.split('\n')[0].split(':')[1].trim().toLowerCase();
          final spriteUrls = await PokemonApi.fetchPokemonSprites(pokemonName);
          botMessage.spriteUrls = spriteUrls;
        }

        return botMessage;
      } else {
        throw Exception('Empty response from chatbot');
      }
    } catch (e) {
      print('Error in sendMessage: $e');
      rethrow;
    }
  }
}
