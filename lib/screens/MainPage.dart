import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  static const id = 'mainpage';

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MainPage'),
      ),
      body: Center(
        child: FlatButton(
          onPressed: () {
            DatabaseReference databaseReference =
                FirebaseDatabase.instance.reference().child('testing');
            databaseReference.set('test connectivity');
          },
          child: Text('CHECK CONNECTIVITY'),
        ),
      ),
    );
  }
}
