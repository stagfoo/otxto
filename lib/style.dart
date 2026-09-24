import 'package:flutter/material.dart';

const _tagColors = [
  '#7E4FED',
  '#FFD60A',
  '#FF6EBD',
  '#04E1FF',
  '#15DA2A',
];
const _tagColorGroups = ['abcde', 'fghij', 'klmno', 'pqrs', 'tuvwxyz'];

extension HexColor on Color {
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

/// Picks a color for a tag based on the first letter after the `@`.
String getRandomColorClass(String word) {
  var letter = word.length > 1 ? word[1].toLowerCase() : '';
  var group = _tagColorGroups
      .indexWhere((g) => letter.isNotEmpty && g.contains(letter));
  return _tagColors[group == -1 ? 0 : group];
}

Color randomStringToHexColor(String string) {
  return HexColor.fromHex(getRandomColorClass(string));
}

Color contrastingTextColor(Color background) {
  return background.computeLuminance() > 0.5 ? Colors.black : Colors.white;
}
