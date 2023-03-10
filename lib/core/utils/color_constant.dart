import 'dart:ui';
import 'package:flutter/material.dart';

class ColorConstant {
  static Color gray700 = fromHex('#68686c');

  static Color gray400 = fromHex('#c4c4c4');

  static Color blueGray100 = fromHex('#cecece');

  static Color blueGray400 = fromHex('#83848a');

  static Color blue800 = fromHex('#2262a7');

  static Color blueGray10001 = fromHex('#d9d9d9');

  static Color gray900 = fromHex('#121212');

  static Color gray90001 = fromHex('#061533');

  static Color indigoA200 = fromHex('#5480e7');

  static Color gray300 = fromHex('#d9dae5');

  static Color blue80001 = fromHex('#0b52e1');

  static Color gray50 = fromHex('#f8f8f8');

  static Color gray30001 = fromHex('#d8d9e3');

  static Color deepPurpleA70065 = fromHex('#5113D5');

  static Color indigoA700 = fromHex('#3637e1');

  static Color gray9004c = fromHex('#4c192430');

  static Color blueGray900 = fromHex('#343434');

  static Color whiteA700 = fromHex('#ffffff');

  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
