import 'dart:io';
import 'package:path/path.dart';

import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:letsjek_driver/widgets/ProgressDialogue.dart';
import 'package:letsjek_driver/widgets/SubmitFlatButton.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class VehicleInfoPage extends StatefulWidget {
  static const id = 'vehicleinfopage';

  @override
  _VehicleInfoPageState createState() => _VehicleInfoPageState();
}

class _VehicleInfoPageState extends State<VehicleInfoPage> {
  File _image;
  final picker = ImagePicker();

  // ! FIREBASE STORAGE
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  void showSnackbar(String messages) {
    final snackbar = SnackBar(
      content: Text(
        messages,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18, fontFamily: 'Bolt-Semibold'),
      ),
    );

    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  final vehicleName = TextEditingController();

  final vehicleColor = TextEditingController();

  final vehicleNumber = TextEditingController();

  Future<String> uploadFile() async {
    var userCredential = FirebaseAuth.instance.currentUser;
    String downloadURL = '';

    firebase_storage.Reference imageRef = firebase_storage
        .FirebaseStorage.instance
        .ref('driverProfile/${userCredential.uid}/image');

    try {
      firebase_storage.TaskSnapshot snapshot = await imageRef.putFile(_image);
      downloadURL = await snapshot.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      // e.g, e.code == 'canceled'
      if (e.code == 'cancelled') {
        showSnackbar('Something wrong uploading your image, please try again!');
      }
    }

    return downloadURL;
  }

  void uploadVehicleInfo(context) async {
    // show loading circular bar
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialogue("Please wait..."),
    );

    try {
      var userCredential = FirebaseAuth.instance.currentUser;

      // ADD IMAGE UPLOADED URL
      String downloadURL = await uploadFile();

      // adding additional data to user's database
      final DatabaseReference dbRef = FirebaseDatabase.instance
          .reference()
          .child('drivers/${userCredential.uid}/vehicle');

      // adding additional data to user's database
      final DatabaseReference imgRef = FirebaseDatabase.instance
          .reference()
          .child('drivers/${userCredential.uid}/profile_url');

      // prepare to save all the data
      Map userDataMap = {
        'vehicleName': vehicleName.text,
        'vehicleColor': vehicleColor.text,
        'vehicleNumber': vehicleNumber.text
      };

      // push data to db
      dbRef.set(userDataMap);
      imgRef.set(downloadURL);
      // if everything is okay then push user to MainPage
      Navigator.pushNamedAndRemoveUntil(context, 'mainpage', (route) => false);
    } on FirebaseException catch (e) {
      // if there is an error - hide loading screen - show error snackbar
      Navigator.pop(context);
      showSnackbar(e.toString());
    } catch (e) {
      Navigator.pop(context);
      showSnackbar(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Theme.of(context).primaryColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 80,
            ),
            (_image != null)
                ? CircleAvatar(
                    backgroundImage: AssetImage(_image.path),
                    radius: 80,
                  )
                : CircleAvatar(
                    backgroundImage:
                        AssetImage('resources/images/user_icon.png'),
                    radius: 80,
                  ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Please complete registration',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontFamily: 'Bolt-Semibold',
              ),
            ),
            Text(
              'Provide informations so rider can know which is you',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontFamily: 'Bolt-Semibold',
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  TextField(
                    controller: vehicleName,
                    keyboardType: TextInputType.text,
                    style: TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                        labelText: 'Vehicle Model/Brand',
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                        hintText: 'e.g: Toyota Altis, Honda Brio, etc'),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: vehicleColor,
                    keyboardType: TextInputType.text,
                    style: TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                        labelText: 'Vehicle Color',
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                        hintText: 'e.g: Red, Blue, Purple, etc'),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: vehicleNumber,
                    keyboardType: TextInputType.text,
                    style: TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                        labelText: 'Vehicle Plate Number',
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                        hintText: 'e.g: W 1153 XX, S 55XX XX, etc'),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  SubmitFlatButton("SUBMIT", Theme.of(context).accentColor,
                      () async {
                    // check network validation
                    final connectivityResult =
                        await Connectivity().checkConnectivity();
                    if (connectivityResult != ConnectivityResult.mobile &&
                        connectivityResult != ConnectivityResult.wifi) {
                      showSnackbar(
                          'Check your internet connection and try again');
                      return;
                    }

                    // check everything is fil
                    if (vehicleName.text.isEmpty ||
                        vehicleColor.text.isEmpty ||
                        vehicleNumber.text.isEmpty) {
                      showSnackbar("Please fill all the forms");
                      return;
                    }

                    if (_image == null) {
                      showSnackbar("Please provide clear photo of yourself");
                      return;
                    }

                    uploadVehicleInfo(context);
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Pick Image',
        backgroundColor: Colors.green,
        child: Icon(Icons.add_a_photo_rounded),
      ),
    );
  }
}
