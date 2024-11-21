class ChatMessage {
  final String text;
  final bool isUser;
  Map<String, String> spriteUrls;

  ChatMessage({
    required this.text,
    required this.isUser,
    Map<String, String>? spriteUrls,
  }) : spriteUrls = spriteUrls ?? {};
}
