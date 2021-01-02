import 'package:firebase_database/firebase_database.dart';

class DriverInformations {
  String driverId;
  String driverFullname;
  String driverEmail;
  String driverPhone;
  String vehicleName;
  String vehicleColor;
  String vehicleNumber;

  DriverInformations({
    this.driverId,
    this.driverFullname,
    this.driverEmail,
    this.driverPhone,
    this.vehicleName,
    this.vehicleColor,
    this.vehicleNumber,
  });

  DriverInformations.enterDataSnapshot(DataSnapshot dataSnapshot) {
    driverId = dataSnapshot.key;
    driverFullname = dataSnapshot.value['fullname'];
    driverEmail = dataSnapshot.value['email'];
    driverPhone = dataSnapshot.value['phone'];
    vehicleName = dataSnapshot.value['vehicle']['vehicleName'];
    vehicleColor = dataSnapshot.value['vehicle']['vehicleColor'];
    vehicleNumber = dataSnapshot.value['vehicle']['vehicleNumbers'];
  }
}
