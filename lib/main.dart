import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

//Local
import 'ui.dart';
import 'store.dart';

void main() async {
  runApp(ChangeNotifierProvider(
    child: GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/open',
      enableLog: true,
      theme: ThemeData.from(
          colorScheme: const ColorScheme.dark(secondary: Colors.green)),
      getPages: [
        GetPage(
            name: '/open',
            page: () =>
                Consumer<GlobalState>(builder: (context, state, widget) {
                  // NOTE: disabled until later
                  // return ListPage(state: state);
                  return OpenPage(state: state);
                }),
            transition: Transition.noTransition),
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
