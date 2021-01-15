import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:letsjek_driver/widgets/ConfirmLogoutDialog.dart';
import 'package:letsjek_driver/widgets/ListDivider.dart';

import 'package:letsjek_driver/global.dart';
import 'package:transparent_image/transparent_image.dart';

class ProfileTab extends StatefulWidget {
  @override
  _ProfileTabState createState() => _ProfileTabState();
}

bool isOnDarkMode;

void getDeviceSettings(context) {
  if (Theme.of(context).brightness == Brightness.dark) {
    isOnDarkMode = true;
  } else {
    isOnDarkMode = false;
  }
}

class _ProfileTabState extends State<ProfileTab> {
  @override
  Widget build(BuildContext context) {
    getDeviceSettings(context);

    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          children: [
            Container(
              height: 150,
              padding: EdgeInsets.all(18),
              child: Row(
                children: [
                  (isInitializing || currentDriverInfo.driverProfileURL == null)
                      ? CircularProgressIndicator(
                          backgroundColor:
                              (Theme.of(context).brightness == Brightness.dark)
                                  ? Colors.amberAccent
                                  : Colors.deepOrange,
                        )
                      : Container(
                          child: FadeInImage.memoryNetwork(
                            placeholder: kTransparentImage,
                            image: currentDriverInfo.driverProfileURL,
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                  SizedBox(
                    width: 8,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        (isInitializing)
                            ? Text(
                                '',
                                style: TextStyle(
                                  fontFamily: 'Bolt-Semibold',
                                  fontSize: 16,
                                ),
                              )
                            : Text(
                                currentDriverInfo.driverFullname,
                                style: TextStyle(
                                  fontFamily: 'Bolt-Semibold',
                                  fontSize: 16,
                                ),
                              ),
                        SizedBox(
                          height: 2,
                        ),
                        Text(
                          'View profile',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ListDivider(),
            SizedBox(
              height: 12,
            ),
            CheckboxListTile(
              secondary: Icon(Icons.nights_stay_outlined),
              title: Text('Dark Mode'),
              value: (isOnDarkMode) ? true : false,
              onChanged: (bool value) {
                setState(() {
                  isOnDarkMode = value;
                  AdaptiveTheme.of(context).toggleThemeMode();
                });
              },
              subtitle: Text(
                'Reduces eye strain',
                style: TextStyle(fontSize: 12),
              ),
              activeColor: Colors.white,
              checkColor: Colors.black,
            ),
            ListTile(
              leading: Icon(Icons.support_agent_outlined),
              title: Text('Support'),
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Sign Out'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => ConfirmLogoutDialog(
                    onpress: () async {
                      await FirebaseAuth.instance.signOut();

                      // if everything is okay then push user to MainPage
                      Navigator.pushNamedAndRemoveUntil(
                          context, 'loginpage', (route) => false);
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
