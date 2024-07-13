import 'package:flutter/material.dart';

class PokemonTypes {
  static Color getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'normal':
        return Colors.grey[400]!;
      case 'fire':
        return Colors.red[400]!;
      case 'water':
        return Colors.blue[400]!;
      case 'electric':
        return Colors.yellow[600]!;
      case 'grass':
        return Colors.green[400]!;
      case 'ice':
        return Colors.cyan[400]!;
      case 'fighting':
        return Colors.orange[800]!;
      case 'poison':
        return Colors.purple[400]!;
      case 'ground':
        return Colors.brown[400]!;
      case 'flying':
        return Colors.indigo[200]!;
      case 'psychic':
        return Colors.pink[400]!;
      case 'bug':
        return Colors.lightGreen[500]!;
      case 'rock':
        return Colors.grey[600]!;
      case 'ghost':
        return Colors.indigo[400]!;
      case 'dragon':
        return Colors.indigo[600]!;
      case 'dark':
        return Colors.grey[800]!;
      case 'steel':
        return Colors.blueGrey[400]!;
      case 'fairy':
        return Colors.pinkAccent[100]!;
      default:
        return Colors.grey[400]!;
    }
  }
}
