import 'package:flutter/material.dart';

var localDBFile = 'database.toml';


class GlobalState extends ChangeNotifier {
  int currentNavbarIndex = 0;
  List<String> bucket = [];

  void addMeatToBucket(String emojiText) {
    bucket.add(emojiText);
    notifyListeners();
  }
  void setBucket(List<String> value) {
    bucket = value;
    notifyListeners();
  }

  void saveNavbarIndex(int value) {
    currentNavbarIndex = value;
    notifyListeners();
  }
}
