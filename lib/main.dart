import 'dart:io';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:letsjek_driver/screens/auth/LoginPage.dart';
import 'package:letsjek_driver/screens/auth/RegisterPage.dart';
import 'package:letsjek_driver/screens/MainPage.dart';
import 'package:letsjek_driver/screens/auth/VehicleInfoPage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: Platform.isIOS || Platform.isMacOS
        ? FirebaseOptions(
            appId: '1:297855924061:ios:c6de2b69b03a5be8',
            apiKey: 'AIzaSyD_shO5mfO9lhy2TVWhfo1VUmARKlG4suk',
            projectId: 'flutter-firebase-plugins',
            messagingSenderId: '297855924061',
            databaseURL: 'https://flutterfire-cd2f7.firebaseio.com',
          )
        : FirebaseOptions(
            appId: '1:936324800238:android:cfd0afbf68aaa4eb235dff',
            apiKey: 'AIzaSyDrdEGjxPMc2AK7ZNZZei9m9GLUK3bYEtU',
            messagingSenderId: '936324800238',
            projectId: 'letsjek',
            databaseURL: 'https://letsjek.firebaseio.com',
          ),
  );

  final savedThemeMode = await AdaptiveTheme.getThemeMode();

  runApp(MyApp(savedThemeMode: savedThemeMode));
}

class MyApp extends StatelessWidget {
  final AdaptiveThemeMode savedThemeMode;

  MyApp({this.savedThemeMode});

  final isLogin = FirebaseAuth.instance.currentUser;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StyledToast(
      locale: const Locale('id', 'ID'),
      borderRadius: BorderRadius.circular(20.0),
      toastPositions: StyledToastPosition.bottom,
      toastAnimation: StyledToastAnimation.slideFromBottomFade,
      duration: Duration(seconds: 4),
      textStyle: TextStyle(
          fontSize: 16.0, fontFamily: 'Bolt-Semibold', color: Colors.white),
      animDuration: Duration(seconds: 1),
      dismissOtherOnShow: true,
      movingOnWindowChange: true,
      curve: Curves.fastOutSlowIn,
      textPadding: EdgeInsets.symmetric(horizontal: 17.0, vertical: 10.0),
      reverseCurve: Curves.fastLinearToSlowEaseIn,
      child: AdaptiveTheme(
        light: ThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.white,
          textSelectionColor: Colors.grey,
          accentColor: Colors.black,
          fontFamily: 'Bolt-Regular',
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        dark: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.yellow,
          accentColor: Colors.deepPurple,
          textSelectionColor: Colors.white70,
          fontFamily: 'Bolt-Regular',
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initial: savedThemeMode ?? AdaptiveThemeMode.system,
        builder: (theme, darkTheme) => MaterialApp(
          theme: theme,
          darkTheme: darkTheme,
          initialRoute: (isLogin == null) ? LoginPage.id : MainPage.id,
          routes: {
            MainPage.id: (context) => MainPage(),
            LoginPage.id: (context) => LoginPage(),
            RegisterPage.id: (context) => RegisterPage(),
            VehicleInfoPage.id: (context) => VehicleInfoPage(),
          },
        ),
      ),
    );
  }
}
