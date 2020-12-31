import 'package:flutter/material.dart';
import 'package:letsjek_driver/models/TripDetails.dart';
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
                    onpress: () {},
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
}
