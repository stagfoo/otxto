import 'dart:io';
import 'package:file_picker/file_picker.dart';
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
  print(name);
  var document = await TomlDocument.load(name);
  var documents = TomlDocument.parse(document.toString()).toMap();
  return documents;
}

saveToml(String name, GlobalState state) async {
  Map<String, dynamic> tomlTemplate = {
    'settings': [
      <String, dynamic>{'columns': state.columns},
      <String, dynamic>{
        'defaultFields': ['createdAt', 'completedAt']
      },
      //TODO get from settings state
      <String, dynamic>{'completeColumn': true},
      <String, dynamic>{'allColumn': true},
      <String, dynamic>{'keyboard_shortcut_complete': 'x'},
      <String, dynamic>{'keyboard_shortcut_move_right': 'k'},
      <String, dynamic>{'keyboard_shortcut_move_left': 'j'},
    ]
  };
  var tomlDB = TomlDocument.fromMap(tomlTemplate).toString();
  var file = File(localDBFile);
  file.writeAsString(tomlDB);
}

Future<List<dynamic>> getFilesFromFolder(String root) async {
  try {
    var list = [];
    List<FileSystemEntity> contents = Directory(root).listSync();
    for (var fileOrDir in contents) {
      print(fileOrDir);
      if (fileOrDir is File) {
        list.add(fileOrDir);
      }
    }
    return list;
  } catch (err) {
    print("Get Files from folder failed or canceled");
    rethrow;
  }
}

Future<String?> pickDir() async {
  String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

  if (selectedDirectory == null) {
    return '';
  }
  return selectedDirectory;
}
