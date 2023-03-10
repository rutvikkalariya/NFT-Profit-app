import 'package:flutter/material.dart';

Color getColorFromHex(String hexColor) {
  hexColor = hexColor.toUpperCase().replaceAll('#', '');
  if (hexColor.length == 6) {
    hexColor = 'FF$hexColor';
  }
  return Color(int.parse(hexColor, radix: 16));
}

Color getPrimaryColor() {
  return getColorFromHex("#343434");
}

Color getDarkBackground() {
  return getColorFromHex("#21242D");
}

Color getSecondryColor() {
  return getColorFromHex("#0B52E1");
}

Color getTotalPortfolioTextColor() {
  return getColorFromHex("#494D58");
}

Color getTotalPortfolioText2Color() {
  return getColorFromHex("#F5C249");
}

Color getTopcoinRateColor() {
  return getColorFromHex("#A7AEBF");
}

Color getTopcoinContainerColor() {
  return getColorFromHex("#282B35");
}

Color getAddCoinContainerColor() {
  return getColorFromHex("#F5C249");
}

Color getPortfolioNameColor() {
  return getColorFromHex("#787A8D");
}
