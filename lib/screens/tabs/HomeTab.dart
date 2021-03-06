import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:letsjek_driver/global.dart';
import 'package:letsjek_driver/helpers/PushNotificationsHelper.dart';
import 'package:letsjek_driver/models/DriverInformations.dart';
import 'package:letsjek_driver/widgets/ConfirmBottomSheet.dart';
import 'package:letsjek_driver/widgets/SubmitFlatButton.dart';
import 'package:wakelock/wakelock.dart';

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with WidgetsBindingObserver {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // SNACKBAR
  void showSnackbar(String messages) {
    final snackbar = SnackBar(
      content: Text(
        messages,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18, fontFamily: 'Bolt-Semibold'),
      ),
    );

    _scaffoldKey.currentState.showSnackBar(snackbar);
  }

  // GOOGLE MAPS DEFAULT LOC
  static final CameraPosition _defaultLocation = CameraPosition(
    target: LatLng(-6.200000, 106.816666),
    zoom: 8,
  );
  // GOOGLE MAP COMPLETER
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController googleMapController;

  //! ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ !

  void getDriverCurrentPos() async {
    bool serviceEnabled;
    LocationPermission locPermit;

    // check if service enabled or not
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Get user to turn on his GPS services
      locPermit = await Geolocator.requestPermission();
    }

    // check if apps denied service permanently
    locPermit = await Geolocator.checkPermission();
    if (locPermit == LocationPermission.deniedForever) {
      return showSnackbar('Location services are disabled permanently');
    }

    try {
      // get current users location
      Position pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);
      driverCurrentPosition = pos;

      LatLng coords = LatLng(pos.latitude, pos.longitude);
      CameraPosition mapsCamera = CameraPosition(target: coords, zoom: 18);
      googleMapController
          .animateCamera(CameraUpdate.newCameraPosition(mapsCamera));

      // GEOCODE
      // String address = await HttpRequestMethod.findAddressByCoord(pos, context);
    } catch (e) {
      showSnackbar(e.toString());
    }
  }

  //! ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ !
  String jobdutyTitle = 'GO ONDUTY';
  String jobdutySubtitle = 'You are currently offduty';
  Color jobDutyColor = Colors.purple;

  bool isOnduty = false;
  //! ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ !

  // ? SCROLLABLE TOP BAR
  bool isScrollDown = false;
  void scrollUpTopBar() {
    setState(() {
      isScrollDown = false;
    });
  }

  void scrollDownTopBar() {
    setState(() {
      isScrollDown = true;
    });
  }

  //! ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ !

  // GET DRIVER INFO
  Future getCurrentDriversInfo() async {
    currentUser = FirebaseAuth.instance.currentUser;

    // RETRIEVE ALL DRIVER INFORMATIONS
    DatabaseReference driverDBRef = FirebaseDatabase.instance
        .reference()
        .child('drivers/${currentUser.uid}');

    await driverDBRef.once().then((DataSnapshot dataSnapshot) {
      if (dataSnapshot != null) {
        // POPULATE MODEL
        currentDriverInfo = DriverInformations.enterDataSnapshot(dataSnapshot);
      }
    });

    // FCM HELPER
    PushNotificationsHelper pushNotificationsHelper = PushNotificationsHelper();

    // INIT FCM
    pushNotificationsHelper.initializeFCM(context);
    // GET TOKEN
    pushNotificationsHelper.getToken();

    setState(() {
      isInitializing = false;
    });
  }

  String _darkStyle;

  void changeMapMode(context) {
    // DEVICE THEME
    if (Theme.of(context).brightness == Brightness.dark) {
      setMapStyle(_darkStyle);
    }
  }

  Future getMapSettings() async {
    _darkStyle =
        await rootBundle.loadString('resources/settings/map/darkMap.json');
  }

  void setMapStyle(String mapStyle) {
    googleMapController.setMapStyle(mapStyle);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //
    Wakelock.enable();
    WidgetsBinding.instance.addObserver(this);
    getMapSettings();
    getCurrentDriversInfo();
    checkIsOnDutyOrNot();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          padding: EdgeInsets.only(
            bottom: 8,
            left: 8,
            right: 8,
            top: (isScrollDown)
                ? MediaQuery.of(context).size.height * 0.18
                : MediaQuery.of(context).size.height * 0.05,
          ),
          initialCameraPosition: _defaultLocation,
          mapType: MapType.normal,
          compassEnabled: true,
          trafficEnabled: true,
          myLocationEnabled: true,
          zoomControlsEnabled: true,
          zoomGesturesEnabled: true,
          buildingsEnabled: true,
          myLocationButtonEnabled: true,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
            googleMapController = controller;

            changeMapMode(context);
            // get driver current location
            getDriverCurrentPos();
          },
        ),
        (isScrollDown)
            ? Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.15,
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 18.0,
                        spreadRadius: 0.8,
                        offset: Offset(0.8, 0.8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 36,
                        ),
                        Text(
                          jobdutySubtitle,
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(
                          height: 2,
                        ),
                        SubmitFlatButton(jobdutyTitle, jobDutyColor, () {
                          showBottomSheet(
                            context: context,
                            builder: (BuildContext context) =>
                                ConfirmBottomSheet(
                              title: (!isOnduty) ? 'GO ONDUTY' : 'GO OFFDUTY',
                              subTitle: (!isOnduty)
                                  ? 'You are about to available receiving ride request'
                                  : 'You are about to unavailable receiving ride request',
                              color:
                                  (!isOnduty) ? Colors.deepPurple : Colors.red,
                              onPressed: () {
                                if (!isOnduty) {
                                  goOnduty();
                                  getUpdatedLoc();
                                  Navigator.pop(context);

                                  // CHANGE VALUE
                                  setState(() {
                                    isOnduty = true;
                                    jobdutyTitle = 'GO OFFDUTY';
                                    jobdutySubtitle =
                                        'You are currently onduty';
                                    jobDutyColor = Colors.red;
                                  });
                                } else {
                                  goOffduty();
                                  Navigator.pop(context);

                                  // CHANGE VALUE
                                  setState(() {
                                    isOnduty = false;
                                    jobdutyTitle = 'GO ONDUTY';
                                    jobdutySubtitle =
                                        'You are currently offduty';
                                    jobDutyColor = Colors.purple;
                                  });
                                }
                              },
                            ),
                          );
                        }),
                        SizedBox(
                          height: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : Positioned(
                child: Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.09,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 28,
                        ),
                        GestureDetector(
                          onTap: () {
                            scrollDownTopBar();
                          },
                          child: Container(
                            height: 25,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.white,
                              size: 30.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        (isScrollDown)
            ? Positioned(
                top: MediaQuery.of(context).size.height * 0.115,
                left: 0,
                right: 0,
                child: Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.09,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 28,
                        ),
                        GestureDetector(
                          onTap: () {
                            scrollUpTopBar();
                          },
                          child: Container(
                            height: 25,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.keyboard_arrow_up_rounded,
                              color: Colors.white,
                              size: 30.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : Positioned(
                child: Container(),
              ),
      ],
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      if (Theme.of(context).brightness == Brightness.dark) {
        googleMapController.setMapStyle(_darkStyle);
      } else {
        googleMapController.setMapStyle("[]");
      }
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    googleMapController.dispose();
    Wakelock.disable();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void checkIsOnDutyOrNot() async {
    // TRIP for current driver
    DatabaseReference tripReqDBRef = FirebaseDatabase.instance
        .reference()
        .child('drivers/${currentUser.uid}/trip');

    tripReqDBRef.once().then((DataSnapshot dataSnapshot) {
      if (dataSnapshot.value == 'waiting') {
        setState(() {
          isOnduty = true;
          jobdutyTitle = 'GO OFFDUTY';
          jobdutySubtitle = 'You are currently onduty';
          jobDutyColor = Colors.red;
        });

        getUpdatedLoc();
      }
    });
  }

  void goOnduty() {
    Geofire.initialize('available_drivers');

    // SET LOCATION
    Geofire.setLocation(currentUser.uid, driverCurrentPosition.latitude,
        driverCurrentPosition.longitude);

    // TRIP for current driver
    DatabaseReference tripReqDBRef = FirebaseDatabase.instance
        .reference()
        .child('drivers/${currentUser.uid}/trip');

    // SET TO WAITING
    tripReqDBRef.set('waiting');

    tripReqDBRef.onValue.listen((event) {});
  }

  void goOffduty() {
    // REMOVE DRIVER FROM DB (AVAILABLE_DRIVERS)
    Geofire.removeLocation(currentUser.uid);

    // SET USER TO OFFDUTY
    DatabaseReference tripReqDBRef = FirebaseDatabase.instance
        .reference()
        .child('drivers/${currentUser.uid}/trip');

    tripReqDBRef.onDisconnect();
    tripReqDBRef.remove();
    tripReqDBRef = null;
  }

  void getUpdatedLoc() {
    currentPosStream = Geolocator.getPositionStream(
            desiredAccuracy: LocationAccuracy.bestForNavigation,
            distanceFilter: 4)
        .listen((Position position) {
      // UPDATE AUTOMATICALLY
      driverCurrentPosition = position;

      if (isOnduty) {
        Geofire.setLocation(
          currentUser.uid,
          position.latitude,
          position.longitude,
        );
      }

      // ANIMATE GOOGLE CAMERA
      CameraPosition mapsCamera = CameraPosition(
          target: LatLng(position.latitude, position.longitude), zoom: 18);
      googleMapController
          .animateCamera(CameraUpdate.newCameraPosition(mapsCamera));
    });
  }
}
