import 'package:google_maps_flutter/google_maps_flutter.dart';

class TripDetails {
  String destAddress;
  String pickupAddress;
  LatLng destCoord;
  LatLng pickupCoord;
  String requestID;
  String payment;
  String riderName;
  String riderPhone;

  TripDetails({
    this.destAddress,
    this.pickupAddress,
    this.destCoord,
    this.pickupCoord,
    this.requestID,
    this.payment,
    this.riderName,
    this.riderPhone,
  });
}
