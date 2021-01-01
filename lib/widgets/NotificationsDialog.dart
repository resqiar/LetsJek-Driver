import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:letsjek_driver/global.dart';
import 'package:letsjek_driver/models/TripDetails.dart';
import 'package:letsjek_driver/screens/trip/TripPage.dart';
import 'package:letsjek_driver/widgets/CustomOutlinedButton.dart';
import 'package:letsjek_driver/widgets/ListDivider.dart';

class NotificationsDialog extends StatelessWidget {
  final TripDetails tripDetails;

  NotificationsDialog({this.tripDetails});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'resources/images/taxi.png',
            height: 100,
            width: 150,
          ),
          Text(
            'New Trip Request Available',
            style: TextStyle(fontSize: 16, fontFamily: 'Bolt-Semibold'),
          ),
          SizedBox(
            height: 24,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rider Fullname',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Row(
                  children: [
                    Image.asset(
                      'resources/images/user_icon.png',
                      height: 15,
                      width: 15,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Expanded(
                        child: Container(
                      child: Text(tripDetails.riderName),
                    )),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 8,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pickup Address',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Row(
                  children: [
                    Image.asset(
                      'resources/images/pickicon.png',
                      height: 15,
                      width: 15,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Container(
                        child: Text(tripDetails.pickupAddress),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 8,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Destination Address',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Row(
                  children: [
                    Image.asset(
                      'resources/images/desticon.png',
                      height: 15,
                      width: 15,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Container(
                        child: Text(tripDetails.destAddress),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 38,
          ),
          ListDivider(),
          SizedBox(
            height: 4,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: CustomOutlinedButton(
                    color: Colors.white,
                    fontIsBold: false,
                    textColor: Colors.grey,
                    title: 'DECLINE',
                    onpress: () {
                      // STOP THE SOUNDS
                      assetsAudioPlayer.stop();

                      Navigator.pop(context);
                    },
                  ),
                ),
                Expanded(
                  child: CustomOutlinedButton(
                    color: Colors.blue,
                    fontIsBold: true,
                    textColor: Colors.white,
                    title: 'ACCEPT',
                    onpress: () {
                      // STOP THE SOUNDS
                      assetsAudioPlayer.stop();

                      // CHECK REQUEST
                      checkRequestAvailability(context);

                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 4,
          ),
        ],
      ),
    );
  }

  // METHOD TO CHECK THE AVAILABILITY OF THE REQUEST
  // IN CASE THE REQUEST IS CANCELLED, TIMED OUT, OR NOT FOUND
  void checkRequestAvailability(context) {
    DatabaseReference databaseReference = FirebaseDatabase.instance
        .reference()
        .child('drivers/${currentUser.uid}/trip');

    // CHECK THE VALUE
    databaseReference.once().then((DataSnapshot dataSnapshot) {
      String tripStatus = '';

      if (dataSnapshot != null) {
        tripStatus = dataSnapshot.value.toString();
      }

      // CHECK THE CONDITIONS
      if (tripStatus == tripDetails.requestID) {
        // set to accepted
        databaseReference.set('accepted');

        // send driver to Trip Page
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => TripPage(
                      tripDetails: tripDetails,
                    )));
      } else if (tripStatus == 'cancelled') {
        // show toast that the trip has been cancelled by user
        showToast('Trip request has been cancelled by user');
      } else if (tripStatus == 'timeout') {
        // show toast that the trip has been timed out
        showToast('Trip request has been timed out');
      } else {
        // show toast that the trip has a problem [NOT FOUND]
        showToast('Trip request not found');
      }
    });
  }
}
