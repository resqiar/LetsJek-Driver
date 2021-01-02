import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:letsjek_driver/global.dart';
import 'package:letsjek_driver/helpers/HttpRequestHelper.dart';
import 'package:letsjek_driver/models/Routes.dart';

class MethodHelper {
  static Future<Routes> findRoutes(LatLng pickupPoint, LatLng destPoint) async {
    // Get Response
    var URL =
        "https://us1.locationiq.com/v1/directions/driving/${pickupPoint.longitude},${pickupPoint.latitude};${destPoint.longitude},${destPoint.latitude}?key=$locationIQKeys&overview=full";

    var response = await HttpRequestHelper.getRequest(URL);

    // if response failed
    if (response == 'failed') return null;

    // assign value to Model
    Routes routesModels = Routes();

    routesModels.destDistanceM =
        response["routes"][0]["distance"].toStringAsFixed(0);
    routesModels.destDistanceKM =
        (response["routes"][0]["distance"] / 1000).round().toStringAsFixed(0);
    routesModels.destDuration =
        (response["routes"][0]["duration"] / 60).round().toStringAsFixed(0);
    routesModels.encodedPoints = response["routes"][0]["geometry"];

    return routesModels;
  }

  static calculateFares(Routes routes) {
    // BASE FARES -> RP.3000
    // DISTANCE FARES -> RP.2000
    // TIME FARES -> RP.1000
    double baseFares = 5000;
    double distFares = (double.parse(routes.destDistanceKM) * 5000);
    double timeFares = (double.parse(routes.destDuration) * 500);

    int totalCalc = (baseFares + distFares + timeFares).toInt();
    String totalFares =
        NumberFormat.currency(locale: 'id', symbol: 'IDR ', decimalDigits: 0)
            .format(totalCalc);

    return totalFares;
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
