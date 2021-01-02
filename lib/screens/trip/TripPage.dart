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
  double estimatedKM = 0;
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
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(Icons.phone_enabled),
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
                          (estimatedKM < 1)
                              ? '${estimatedM}M / $estimatedTime mins estimated'
                              : '${estimatedKM.toStringAsFixed(0)}KM / $estimatedTime mins estimated',
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
                    color: Colors.green,
                    fontIsBold: true,
                    textColor: Colors.white,
                    width: 350,
                    onpress: () {},
                    title: 'TELL RIDER IM ARRIVED',
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

    // set trip to accepted by driver
    tripRef.child('status').set('accepted');
    tripRef.child('driver_id').set(currentDriverInfo.driverId);
    // set driver info
    Map driverCoords = {
      'latitude': driverCurrentPosition.latitude,
      'longitude': driverCurrentPosition.longitude,
    };

    Map driverInfoMap = {
      'driver_name': currentDriverInfo.driverFullname,
      'driver_phone': currentDriverInfo.driverPhone,
      'driver_iD': currentDriverInfo.driverId,
      'vehicle_name': currentDriverInfo.vehicleName,
      'vehicle_color': currentDriverInfo.vehicleColor,
      'vehicle_number': currentDriverInfo.vehicleNumber,
      'driver_coords': driverCoords,
    };

    tripRef.child('driver_info').set(driverInfoMap);
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
      estimatedKM = double.parse(getRoutes.destDistanceKM);
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
        width: 4,
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
    });
  }
}
