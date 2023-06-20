import 'dart:ui';

class OtxtoColors {
  String black = '#000000';
  String white = '#ffffff';
  String gray = '#424242';
  String purple = '#7E4FED';
  String lime = '#C8FF04';
  String pink = '#FF6EBD';
  String blue = '#04E1FF';
  String green = '#15DA2A';
}

extension HexColor on Color {
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

getRandomColorClass(String word) {
  List<String> otxtoColorsAsHexList = [
    '#7E4FED',
    '#FFD60A',
    '#FF6EBD',
    '#04E1FF',
    '#15DA2A',
  ];
  const abcde = ['a', 'b', 'c', 'd', 'e'];
  const fghij = ['f', 'g', 'h', 'i', 'j'];
  const klmno = ['k', 'l', 'm', 'n', 'o'];
  const pqrs = ['p', 'g', 'r', 's'];
  const tvwxyz = ['u', 'v', 'w', 'y', 'x', 'z', 't'];
  if (abcde.contains(word[1])) {
    return otxtoColorsAsHexList[0];
  }
  if (fghij.contains(word[1])) {
    return otxtoColorsAsHexList[1];
  }
  if (klmno.contains(word[1])) {
    return otxtoColorsAsHexList[2];
  }
  if (pqrs.contains(word[1])) {
    return otxtoColorsAsHexList[3];
  }
  if (tvwxyz.contains(word[1])) {
    return otxtoColorsAsHexList[4];
  }
}



class DesignSystem {
  int gutter = 8;
  // Nice black
  // #330C2F
}

Color randomStringToHexColor(String string) {
  return HexColor.fromHex(getRandomColorClass(string));
}
