import 'dart:io';
import 'package:toml/toml.dart';

// NOTE:
// Platform.isAndroid lets you check its android so you can show dialogs
// related to permissions

import 'store.dart';

Future<Map<String, dynamic>> loadToml(String path) async {
  var document = await TomlDocument.load(path);
  return document.toMap();
}

Future<void> saveToml(String path, GlobalState state) async {
  if (path.isEmpty) {
    return;
  }
  Map<String, dynamic> tomlTemplate = {
    'settings': <String, dynamic>{
      'columns': state.columns.map((e) => e.id).toList(),
      'defaultFields': ['createdAt', 'completedAt'],
      'completeColumn': true,
      'allColumn': true,
    }
  };
  var tomlDB = TomlDocument.fromMap(tomlTemplate).toString();
  await File(path).writeAsString(tomlDB);
}
