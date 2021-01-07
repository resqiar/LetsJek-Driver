import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:letsjek_driver/global.dart';
import 'package:letsjek_driver/helpers/MapToolkitHelper.dart';
import 'package:letsjek_driver/helpers/MethodHelper.dart';
import 'package:letsjek_driver/models/TripDetails.dart';
import 'package:letsjek_driver/widgets/CollectPaymentDialog.dart';
import 'package:letsjek_driver/widgets/CustomOutlinedButton.dart';
import 'package:letsjek_driver/widgets/ListDivider.dart';
import 'package:letsjek_driver/widgets/ProgressDialogue.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mp;

class TripPage extends StatefulWidget {
  final TripDetails tripDetails;

  TripPage({this.tripDetails});

  @override
  _TripPageState createState() => _TripPageState();
}

class _TripPageState extends State<TripPage> {
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

  // SET UP MARKERS
  // ? Routes Coordinate Polylines
  List<LatLng> polylineCoords = [];
  Set<Polyline> _polylines = Set<Polyline>();
  Set<Marker> _marker = Set<Marker>();
  Set<Circle> _circle = Set<Circle>();
  PolylinePoints polylinePoints = PolylinePoints();

  String estimatedTime = '';
  String estimatedKM = '0';
  String estimatedM = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    acceptTrip();
  }

  var geolocator = Geolocator();

  // ! THIS VARIABLE WILL BE ALWAYS UPDATED
  Position driverPos;
  String tripStatus = 'accepted';
  bool requestIsOnGoing = false;

  BitmapDescriptor driverIcon;
  void createDriverMarker() {
    if (driverIcon == null) {
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(
        context,
        size: Size(2, 2),
      );

      // ICON IMAGE
      BitmapDescriptor.fromAssetImage(
              imageConfiguration, 'resources/images/car_android.png')
          .then((icon) {
        driverIcon = icon;
      });
    }
  }

  // ! THIS VARIABLE WILL UPDATED ONCE THE DRIVER EITHER PICKED OR FINISHED THE TRIP
  String defaultButtonTitle = 'TELL RIDER THAT IAM ARRIVED';
  Color defaultButtonColor = Colors.green;

  @override
  Widget build(BuildContext context) {
    createDriverMarker();

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.36,
              left: 8,
              right: 8,
              top: MediaQuery.of(context).size.height * 0.04,
            ),
            initialCameraPosition: _defaultLocation,
            mapType: MapType.normal,
            buildingsEnabled: true,
            compassEnabled: true,
            trafficEnabled: true,
            myLocationEnabled: true,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            myLocationButtonEnabled: true,
            markers: _marker,
            circles: _circle,
            polylines: _polylines,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              googleMapController = controller;

              // get driver current location
              // getDriverCurrentPos();
              var driverCurrentLatLng = LatLng(driverCurrentPosition.latitude,
                  driverCurrentPosition.longitude);
              var pickupRiderLatLng = widget.tripDetails.pickupCoord;

              getRoutes(driverCurrentLatLng, pickupRiderLatLng);

              // STREAM CURRENT POSITIONS
              getLocationsUpdate();
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(8),
              height: MediaQuery.of(context).size.height * 0.35,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 18.0,
                    spreadRadius: 0.8,
                    offset: Offset(0.8, 0.8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.tripDetails.riderName,
                          style: TextStyle(
                              fontSize: 22, fontFamily: 'Bolt-Semibold'),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Row(
                            children: [
                              FlatButton(
                                onPressed: () {},
                                minWidth: 20,
                                child: Icon(Icons.message_rounded),
                              ),
                              FlatButton(
                                onPressed: () {},
                                minWidth: 20,
                                child: Icon(Icons.phone_enabled),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          (double.parse(estimatedKM) < 1)
                              ? '${estimatedM}M / $estimatedTime mins estimated'
                              : '${estimatedKM}KM / $estimatedTime mins estimated',
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontFamily: 'Bolt-Semibold'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pickup Address',
                          style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Bolt-Semibold',
                              color: Colors.grey),
                        ),
                        SizedBox(
                          height: 2,
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
                                child: Text(widget.tripDetails.pickupAddress),
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
                          style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Bolt-Semibold',
                              color: Colors.grey),
                        ),
                        SizedBox(
                          height: 2,
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
                                child: Text(widget.tripDetails.destAddress),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  ListDivider(),
                  SizedBox(
                    height: 8,
                  ),
                  CustomOutlinedButton(
                    color: defaultButtonColor,
                    fontIsBold: true,
                    textColor: Colors.white,
                    width: 350,
                    onpress: () {
                      tripButtonController();
                    },
                    title: defaultButtonTitle,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void acceptTrip() {
    String tripID = widget.tripDetails.requestID;

    tripRef =
        FirebaseDatabase.instance.reference().child('ride_request/$tripID');

    // set driver info
    Map driverCoords = {
      'latitude': driverCurrentPosition.latitude,
      'longitude': driverCurrentPosition.longitude,
    };

    Map driverInfoMap = {
      'driver_name': currentDriverInfo.driverFullname,
      'driver_phone': currentDriverInfo.driverPhone,
      'driver_id': currentDriverInfo.driverId,
      'vehicle_name': currentDriverInfo.vehicleName,
      'vehicle_color': currentDriverInfo.vehicleColor,
      'vehicle_number': currentDriverInfo.vehicleNumber,
      'driver_coords': driverCoords,
    };

    tripRef.child('driver_info').set(driverInfoMap);
    // set trip to accepted by driver
    tripRef.child('status').set('accepted');
    print(driverCoords);
    tripRef.child('driver_id').set(currentDriverInfo.driverId);
  }

  void tripButtonController() async {
    // CHECK IF STATUS IS ACCEPTED
    if (tripStatus == 'accepted') {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) =>
            ProgressDialogue('Notifying Rider, Please wait...'),
      );

      // SET TRIP REF TO PICKED
      tripRef.child('status').set('picked');

      setState(() {
        defaultButtonTitle = 'START TRIP';
        defaultButtonColor = Colors.blue;
        tripStatus = 'picked';
      });

      Navigator.pop(context);
    } else if (tripStatus == 'picked') {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) =>
            ProgressDialogue('Starting Trip, Please wait...'),
      );

      if (driverPos == null) {
        await getRoutes(
            widget.tripDetails.pickupCoord, widget.tripDetails.destCoord);
      } else {
        await getRoutes(LatLng(driverPos.latitude, driverPos.longitude),
            widget.tripDetails.destCoord);
      }

      // SET TRIP REF TO PICKED
      tripRef.child('status').set('transporting');

      setState(() {
        defaultButtonTitle = 'END TRIP';
        defaultButtonColor = Colors.red;
        tripStatus = 'transporting';
      });

      Navigator.pop(context);
    } else if (tripStatus == 'transporting') {
      //! HERE IT SHOULD END THE TRIP

      // Disable Location Stream
      driverUpdatedCoordsStream.cancel();

      // Show Dialog to Finish the Trip
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) =>
            CollectPaymentDialog(tripDetails: widget.tripDetails),
      );
    }
  }

  Future getRoutes(LatLng driverCurrentPos, LatLng riderCurrentPos) async {
    // SHOW LOADING SCREEN FIRST
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProgressDialogue("Please wait..."),
    );

    // CALL THE HELPER METHOD TO GET ROUTES/DETAILS
    var getRoutes =
        await MethodHelper.findRoutes(driverCurrentPos, riderCurrentPos);

    setState(() {
      estimatedTime = getRoutes.destDuration;
      estimatedKM = getRoutes.destDistanceKM;
      estimatedM = getRoutes.destDistanceM;
    });

    // !: RENDER ROUTES :!
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> result =
        polylinePoints.decodePolyline(getRoutes.encodedPoints);

    // clear available RESULT first
    polylineCoords.clear();

    if (result.isNotEmpty) {
      // LOOP RESULT + ADD to LIST
      result.forEach((PointLatLng points) {
        polylineCoords.add(LatLng(points.latitude, points.longitude));
      });
    }

    // PROPERTY of POLYLINE
    // clear available polyline first
    _polylines.clear();

    setState(() {
      Polyline polyline = Polyline(
        polylineId: PolylineId('routes'),
        color: Colors.purple,
        points: polylineCoords,
        jointType: JointType.round,
        width: 6,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      // add to Set
      _polylines.add(polyline);
    });

    // DISMISS LOADING
    Navigator.pop(context);

    // ANIMATE MAPS CAMERA
    LatLngBounds bounds;

    if (driverCurrentPos.latitude > riderCurrentPos.latitude &&
        driverCurrentPos.longitude > riderCurrentPos.longitude) {
      bounds =
          LatLngBounds(southwest: riderCurrentPos, northeast: driverCurrentPos);
    } else if (driverCurrentPos.latitude > riderCurrentPos.latitude) {
      bounds = LatLngBounds(
        southwest: LatLng(riderCurrentPos.latitude, driverCurrentPos.longitude),
        northeast: LatLng(driverCurrentPos.latitude, riderCurrentPos.longitude),
      );
    } else if (driverCurrentPos.longitude > riderCurrentPos.longitude) {
      bounds = LatLngBounds(
        southwest: LatLng(driverCurrentPos.latitude, riderCurrentPos.longitude),
        northeast: LatLng(riderCurrentPos.latitude, driverCurrentPos.longitude),
      );
    } else {
      bounds =
          LatLngBounds(southwest: driverCurrentPos, northeast: riderCurrentPos);
    }

    // UPDATE CAMERA
    googleMapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));

    Marker riderMarker = Marker(
      markerId: MarkerId('riderPosition'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      position: riderCurrentPos,
    );

    // ADD a CIRCLE
    Circle driverCircle = Circle(
      circleId: CircleId('driver'),
      center: driverCurrentPos,
      strokeWidth: 3,
      radius: 12,
      strokeColor: Colors.green,
      fillColor: Colors.greenAccent,
    );

    Circle riderCircle = Circle(
      circleId: CircleId('rider'),
      center: riderCurrentPos,
      strokeWidth: 3,
      radius: 8,
      strokeColor: Colors.red,
      fillColor: Colors.redAccent,
    );

    setState(() {
      // _marker.add(pickupMarker);
      _marker.add(riderMarker);
      _circle.add(driverCircle);
      _circle.add(riderCircle);
    });
  }

  void getLocationsUpdate() {
    mp.LatLng pos = mp.LatLng(0, 0);

    driverUpdatedCoordsStream = Geolocator.getPositionStream(
            desiredAccuracy: LocationAccuracy.bestForNavigation)
        .listen((Position position) {
      driverPos = position;
      driverCurrentPosition = position;

      // COMPUTED ROTATIONS
      var rotations = MapToolkitHelper.calcRotations(
          pos,
          mp.LatLng(
            position.latitude,
            position.longitude,
          ));

      // SET MARKER
      LatLng coords = LatLng(position.latitude, position.longitude);

      Marker driverMarker = Marker(
        markerId: MarkerId('driverIcon'),
        icon: driverIcon,
        position: coords,
        rotation: rotations,
      );

      // UPDATE EVERYTHING ACCORDINGLY
      setState(() {
        // ANIMATE CAMERA
        CameraPosition cameraPosition =
            CameraPosition(target: coords, zoom: 18);

        googleMapController
            .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

        // CLEAR DRIVERICON BEFORE ADD NEW
        _marker.removeWhere((marker) => marker.markerId.value == 'driverIcon');

        _marker.add(driverMarker);
      });

      // UPDATE DUMMY LATLNG
      pos = mp.LatLng(position.latitude, position.longitude);

      // UPDATE INFORMATIONS CONTAINS
      getUpdatedTripInfo();

      // PUSH TO DATABASE CURRENT DRIVER POS
      Map driverCoords = {
        'latitude': driverPos.latitude,
        'longitude': driverPos.longitude,
      };

      tripRef.child('driver_info/driver_coords').set(driverCoords);
    });
  }

  void getUpdatedTripInfo() async {
    if (!requestIsOnGoing) {
      // NULL SAFETY
      if (driverPos == null) {
        return;
      }
      // SET NOW IS REQUESTING
      requestIsOnGoing = true;

      // this will be the coords that always updated
      // ! current pos
      var currentLatLng = LatLng(driverPos.latitude, driverPos.longitude);
      // ! dest pos
      LatLng destLatLng;

      // WHEN TRIP STATUS IS ACCEPTED
      // ITS MEANT THE DRIVER IS PICKUP RIDER
      // IF NOT ACCEPTED MAYBE 'transporting'
      // ITS MEANT THE DRIVER IS TRANSPORTING RIDER TO THEIR DEST POINT
      if (tripStatus == 'accepted') {
        destLatLng = widget.tripDetails.pickupCoord;
      } else {
        destLatLng = widget.tripDetails.destCoord;
      }

      // PROCESS THE COORDINATES TO ACHIEVE THE INFOs
      var updatedInformations =
          await MethodHelper.findRoutes(currentLatLng, destLatLng);

      if (updatedInformations != null) {
        setState(() {
          estimatedTime = updatedInformations.destDuration;
          estimatedKM = updatedInformations.destDistanceKM;
          estimatedM = updatedInformations.destDistanceM;
        });
      }

      // SET NOW IS NOT REQUESTING
      requestIsOnGoing = false;
    }
  }
}
