import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'dart:io';

//Local
import 'keyboard.dart';
import 'ui.dart';
import 'store.dart';

void main() async {
  runApp(ChangeNotifierProvider(
    child: GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      enableLog: true,
      themeMode: ThemeMode.dark,
      theme: ThemeData.dark(),
      getPages: [
        GetPage(
            name: '/',
            page: () =>
                Consumer<GlobalState>(builder: (context, state, widget) {
                  return HomePage(state: state);
                }),
            transition: Transition.noTransition),
        GetPage(
            name: '/list',
            page: () =>
                Consumer<GlobalState>(builder: (context, state, widget) {
                  // NOTE: disabled until later
                  // return ListPage(state: state);
                  return HomePage(state: state);
                }),
            transition: Transition.noTransition),
      ],
    ),
    create: (context) => GlobalState(),
  ));
}
