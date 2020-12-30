import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:letsjek_driver/global.dart';

class PushNotificationsHelper {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  // Init FCM
  Future initializeFCM() async {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
  }

  // GET TOKEN
  Future getToken() async {
    String token = await _firebaseMessaging.getToken();

    DatabaseReference databaseReference = FirebaseDatabase.instance
        .reference()
        .child('drivers/${currentUser.uid}/token');

    // save token to DATABASE
    databaseReference.set(token);

    // SUBSCRIBE TO TOPIC
    _firebaseMessaging.subscribeToTopic('alldrivers'); // TO ALL DRIVERS
    _firebaseMessaging.subscribeToTopic('allusers'); // TO ALL USERS
  }
}
