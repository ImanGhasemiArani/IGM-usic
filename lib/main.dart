import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ig_music/splash_screen.dart';

import 'controllers/file_manager.dart';
import 'main_page.dart';

void main() => runApp(const MainMaterial());

class MainMaterial extends StatelessWidget {
  const MainMaterial({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      var time = DateTime.now();
      print("Start App => time: ${time.minute}: ${time.second}: ${time.millisecond}");
    }
    return Builder(builder: (context) {
      return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "IGMusic",
          theme: ThemeData(
            bottomSheetTheme: const BottomSheetThemeData(
              backgroundColor: Colors.transparent,
            ),
            primarySwatch: Colors.grey,
          ),
          home: AnimatedSplashScreen.withScreenFunction(
            centered: true,
            curve: Curves.decelerate,
            splashIconSize: 250,
            disableNavigation: true,
            splashTransition: SplashTransition.fadeTransition,
            backgroundColor: Colors.black,
            splash: const SplashScreenPage(),
            screenFunction: () async {
              await permissionsRequest();
              return MainPage();
            },
          ));
    });
  }
}
