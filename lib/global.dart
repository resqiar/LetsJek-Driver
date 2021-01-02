import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:letsjek_driver/models/DriverInformations.dart';

String gmapsKey = "AIzaSyCM4XZY3uKnCmrIL3hatqO1drjqp-RhC6g";
String locationIQKeys = "pk.423bcf21478b32ab5c909b792ec84718";

var currentUser = FirebaseAuth.instance.currentUser;

// STREAM DRIVER POSITIONS
StreamSubscription<Position> currentPosStream;

// STREAM DRIVER POSITIONS WHEN PICK UP RIDER
StreamSubscription<Position> driverUpdatedCoordsStream;

AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer();

// GET CURRENT DRIVER POSITION
Position driverCurrentPosition;

// TRIP DB REF
DatabaseReference tripRef;

// CURRENT DRIVER INFO
DriverInformations currentDriverInfo;
