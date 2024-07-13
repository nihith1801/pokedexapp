import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../PokeAPI/pokemon_types.dart';
import '../utils/string_utils.dart';

class PokemonTypeIcons extends StatelessWidget {
  final List<String> types;

  const PokemonTypeIcons({Key? key, required this.types}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: types.map((type) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: PokemonTypes.getTypeColor(type).withOpacity(0.6),
                  blurRadius: 6,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: SvgPicture.asset(
              'assets/icons/Pokemon_Type_Icon_${capitalizeFirstLetter(type)}.svg',
              height: 25,
              width: 25,
              colorFilter: ColorFilter.mode(
                PokemonTypes.getTypeColor(type),
                BlendMode.srcIn,
              ),
              placeholderBuilder: (BuildContext context) => Container(
                height: 25,
                width: 25,
                color: PokemonTypes.getTypeColor(type),
                child: Center(
                  child: Text(
                    type[0],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
