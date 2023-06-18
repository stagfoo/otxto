import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:toml/toml.dart';

import 'store.dart';

Future<File> pickFile() async {
  try {
    var root = await FilePicker.platform.pickFiles();
    var firstFile = root!.files[0].path ?? '';
    return File(firstFile);
  } catch (err) {
    rethrow;
  }
}

loadToml(String name) async {
  //load toml
  var document = await TomlDocument.load(name);
  var documents = TomlDocument.parse(document.toString()).toMap();
  return documents;
}

saveToml(String name, GlobalState state) async {
  Map<String, dynamic> tomlTemplate = {
    'settings': [
      <String, dynamic>{
        'columns': state.columns.map(
          (e) {
            return e.id;
          },
        )
      },
      <String, dynamic>{
        'defaultFields': ['createdAt', 'completedAt']
      },
      //TODO get from settings state
      <String, dynamic>{'completeColumn': true},
      <String, dynamic>{'allColumn': true}
    ]
  };
  var tomlDB = TomlDocument.fromMap(tomlTemplate).toString();
  var file = File(localDBFile);
  file.writeAsString(tomlDB);
}
