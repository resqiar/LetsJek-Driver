import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:letsjek_driver/screens/auth/LoginPage.dart';
import 'package:letsjek_driver/screens/auth/RegisterPage.dart';
import 'package:letsjek_driver/screens/MainPage.dart';

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
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final isLogin = FirebaseAuth.instance.currentUser;

    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.green,
        fontFamily: 'Bolt-Regular',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: (isLogin != null) ? MainPage.id : LoginPage.id,
      routes: {
        MainPage.id: (context) => MainPage(),
        LoginPage.id: (context) => LoginPage(),
        RegisterPage.id: (context) => RegisterPage(),
      },
    );
  }
}