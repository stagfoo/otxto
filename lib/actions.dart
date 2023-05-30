import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:toml/toml.dart';

import 'store.dart';

Future<void> handleButtonClick(GlobalState state) async {
  state.addMeatToBucket('🍖');
  saveToml(localDBFile, state);
}


Future<void> navigateToPage(GlobalState state, String page, int navbarIndex, BuildContext context) async {
  switch (page) {
    case 'other':
      Get.toNamed('/other-page');
      // Download shark json
      state.setBucket(['🦈', '🦈', '🦈', '🦈']);
      break;
    default:
      Get.toNamed('/');
      state.setBucket([]);
  }
  state.saveNavbarIndex(navbarIndex);
}


saveToml(String name, GlobalState state) async {
  Map<String, dynamic> tomlTemplate = {'bucket': state.bucket};
  var tomlDB = TomlDocument.fromMap(tomlTemplate).toString();
  var file = File(localDBFile);
  file.writeAsString(tomlDB);
}

loadToml(String name) async {
  //load toml
  var document = await TomlDocument.load(name);
  var documents = TomlDocument.parse(document.toString()).toMap();
  return documents;
}
