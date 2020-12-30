import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:letsjek_driver/global.dart';
import 'package:letsjek_driver/models/TripDetails.dart';

class PushNotificationsHelper {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  // Init FCM
  Future initializeFCM() async {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        fetchRequestID(getRequestID(message));
      },
      onLaunch: (Map<String, dynamic> message) async {
        fetchRequestID(getRequestID(message));
      },
      onResume: (Map<String, dynamic> message) async {
        fetchRequestID(getRequestID(message));
      },
    );
  }

  // GET TOKEN
  Future getToken() async {
    String token = await _firebaseMessaging.getToken();

    print('token: $token');

    DatabaseReference databaseReference = FirebaseDatabase.instance
        .reference()
        .child('drivers/${currentUser.uid}/token');

    // save token to DATABASE
    databaseReference.set(token);

    // SUBSCRIBE TO TOPIC
    _firebaseMessaging.subscribeToTopic('alldrivers'); // TO ALL DRIVERS
    _firebaseMessaging.subscribeToTopic('allusers'); // TO ALL USERS
  }

  String getRequestID(Map<String, dynamic> messages) {
    String requestID = '';

    // retrieve rideRequest_ID
    if (Platform.isAndroid) {
      requestID = messages['data']['request_id'];
      print("requestID: $requestID");
    } else {
      print("$messages");
    }

    return requestID;
  }

  void fetchRequestID(String requestID) {
    // SEARCH FROM DB
    DatabaseReference databaseReference =
        FirebaseDatabase.instance.reference().child('ride_request/$requestID');

    // RETRIEVE THE VALUE
    databaseReference.once().then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        // PICKUP COORD
        String pickupAddress = snapshot.value['pickup_address'];
        String pickupLat = snapshot.value['pickup_coord']['latitude'];
        String pickupLng = snapshot.value['pickup_coord']['longitude'];

        // DEST COORD
        String destAddress = snapshot.value['dest_address'];
        String destLat = snapshot.value['dest_coord']['latitude'];
        String destLng = snapshot.value['dest_coord']['longitude'];

        // PAYMENT
        String payment = snapshot.value['payment'];

        // RIDER
        String riderName = snapshot.value['rider_name'];
        String riderPhone = snapshot.value['rider_phone'];

        //! INSERT TO DATA MODEL
        TripDetails tripDetailsModel = TripDetails();
        tripDetailsModel.destAddress = destAddress;
        tripDetailsModel.pickupAddress = pickupAddress;
        tripDetailsModel.pickupCoord =
            LatLng(double.parse(pickupLat), double.parse(pickupLng));
        tripDetailsModel.destCoord =
            LatLng(double.parse(destLat), double.parse(destLng));
        tripDetailsModel.payment = payment;
        tripDetailsModel.riderName = riderName;
        tripDetailsModel.riderPhone = riderPhone;
      }
    });
  }
}
