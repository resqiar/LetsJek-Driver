import 'package:flutter/material.dart';
import 'package:letsjek_driver/widgets/CustomOutlinedButton.dart';

class ConfirmBottomSheet extends StatelessWidget {
  final String title;
  final String subTitle;
  final Color color;
  final Function onPressed;

  ConfirmBottomSheet({this.title, this.color, this.subTitle, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.2,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white10,
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black26,
        //     blurRadius: 18,
        //     spreadRadius: 0.8,
        //     offset: Offset(0.7, 0.7),
        //   ),
        // ],
      ),
      child: Column(
        children: [
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(fontSize: 24, fontFamily: 'Bolt-Semibold'),
          ),
          SizedBox(height: 8),
          Text(
            subTitle,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Container(
                  child: CustomOutlinedButton(
                    color: Colors.white10,
                    textColor: Colors.grey,
                    title: 'CANCEL',
                    onpress: () {
                      Navigator.pop(context);
                    },
                    fontIsBold: false,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  child: CustomOutlinedButton(
                    color: color,
                    textColor: Colors.white,
                    title: title,
                    onpress: onPressed,
                    fontIsBold: true,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
