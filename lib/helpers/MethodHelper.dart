import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:letsjek_driver/global.dart';
import 'package:letsjek_driver/helpers/HttpRequestHelper.dart';
import 'package:letsjek_driver/models/Routes.dart';

class MethodHelper {
  static Future findRoutes(LatLng pickupPoint, LatLng destPoint) async {
    // Get Response
    var URL =
        "https://us1.locationiq.com/v1/directions/driving/${pickupPoint.longitude},${pickupPoint.latitude};${destPoint.longitude},${destPoint.latitude}?key=$locationIQKeys&overview=full";

    var response = await HttpRequestHelper.getRequest(URL);

    // if response failed
    if (response == 'Failed') {
      return;
    }
    if (response == null) {
      return;
    }

    // assign value to Model
    Routes routesModels = Routes();

    routesModels.destDistanceM =
        response["routes"][0]["distance"].round().toString();
    routesModels.destDistanceKM =
        (response["routes"][0]["distance"] / 1000).round().toString();
    routesModels.destDuration =
        (response["routes"][0]["duration"] / 60).round().toString();
    routesModels.encodedPoints = response["routes"][0]["geometry"];

    return routesModels;
  }

  static void disableLocStream() {
    currentPosStream.pause();
    Geofire.removeLocation(currentUser.uid);
  }

  static void enableLocStream() {
    currentPosStream.resume();
    Geofire.setLocation(currentUser.uid, driverCurrentPosition.latitude,
        driverCurrentPosition.longitude);
  }
}
