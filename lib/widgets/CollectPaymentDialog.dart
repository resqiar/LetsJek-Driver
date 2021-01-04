import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:letsjek_driver/global.dart';
import 'package:letsjek_driver/helpers/MethodHelper.dart';
import 'package:letsjek_driver/models/TripDetails.dart';
import 'package:letsjek_driver/widgets/CustomOutlinedButton.dart';
import 'package:letsjek_driver/widgets/ListDivider.dart';
import 'package:letsjek_driver/widgets/ProgressDialogue.dart';

class CollectPaymentDialog extends StatelessWidget {
  final TripDetails tripDetails;

  CollectPaymentDialog({this.tripDetails});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.white,
      child: Container(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 8,
            ),
            Text(
              'COLLECT CASH PAYMENT',
              style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Bolt-Semibold',
                  color: Colors.grey),
            ),
            SizedBox(
              height: 8,
            ),
            ListDivider(),
            SizedBox(
              height: 16,
            ),
            Image.asset(
              'resources/images/taxi.png',
              height: 100,
              width: 150,
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              tripDetails.fares,
              style: TextStyle(
                fontSize: 26,
                fontFamily: 'Bolt-Semibold',
              ),
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              'This is the total amount of fares that rider should pay',
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 18,
            ),
            CustomOutlinedButton(
              color: Colors.blue,
              fontIsBold: true,
              textColor: Colors.white,
              title: 'COLLECT CASH',
              onpress: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) =>
                      ProgressDialogue('Please Wait...'),
                );

                // SET TRIP TO FINISHED/ARRIVED
                tripRef.child('status').set('arrived');

                // SET RIDER TO AVAILABLE AGAIN
                DatabaseReference databaseReference = FirebaseDatabase.instance
                    .reference()
                    .child('drivers/${currentUser.uid}/trip');
                databaseReference.set('waiting');

                // ENABLE LOC STREAM AGAIN
                MethodHelper.enableLocStream();

                // SAVE TRIP TO DRIVER's HISTORY
                DatabaseReference historyRef = FirebaseDatabase.instance
                    .reference()
                    .child(
                        'drivers/${currentUser.uid}/history/${tripDetails.requestID}');

                Map tripID = {'trip_id': tripDetails.requestID};
                historyRef.set(tripID);

                Navigator.pop(context);

                // SET BACK DRIVER TO HOMETAB
                Navigator.pushNamedAndRemoveUntil(
                    context, 'mainpage', (route) => false);
              },
              width: 250,
            ),
            SizedBox(
              height: 18,
            ),
          ],
        ),
      ),
    );
  }
}
