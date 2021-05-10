//Packages used in the Project
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_launch/flutter_launch.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:access_settings_menu/access_settings_menu.dart';

//Data Storage Variables
Position lastKnownPosition;
TextEditingController number = TextEditingController();
PhoneNumber phonenumber = PhoneNumber(isoCode: 'IN');
TextEditingController emergencynumber = TextEditingController();

void main() {
  runApp(MyHome());
}

//Base Class to set up the Scaffold and basic UI elements like AppBar,...
class MyHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(
            'wa.me Link Generator',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: Icon(
                  MaterialIcons.contact_phone,
                ),
                iconSize: 20,
                color: Colors.white,
                highlightColor: Colors.orange,
                splashColor: Colors.white,
                onPressed: () {
                  showModalBottomSheet(
                      context: context,
                      isScrollControlled: false,
                      isDismissible: true,
                      builder: (context) => EmergencyContact());
                },
              ),
            )
          ],
          backgroundColor: Colors.black,
        ),
        body: MyApp(),
      ),
    );
  }
}

//Main Functionality Class which sets up the body UI and Functionality
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  void openSettingsMenu() async {
    // ignore: unused_local_variable
    var resultSettingsOpening = false;
    try {
      resultSettingsOpening = await AccessSettingsMenu.openSettings(
          settingsType: "ACTION_LOCATION_SOURCE_SETTINGS");
    } catch (e) {
      print(e);
    }
  }

  //Function To Get The Current Position Of The User
  Future<Position> _determinePosition() async {
    bool serviceEnabled = false;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      openSettingsMenu();
      return await Geolocator.getCurrentPosition();
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, handle appropriately.
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }

      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  //Function to open Whatsapp to send a normal message
  void whatsAppOpen(String countryCode, String number) async {
    final String mobilenumber = number;
    bool whatsapp = await FlutterLaunch.hasApp(name: "whatsapp");
    if (whatsapp) {
      await FlutterLaunch.launchWathsApp(phone: mobilenumber, message: "");
    } else {
      print("Error Opening Whatsapp");
    }
  }

  //Function to open Whatsapp to send emergency contact message with current/last known location
  void emergencyContact(String number) async {
    final String mobilenumber = number;
    bool whatsapp = await FlutterLaunch.hasApp(name: "whatsapp");
    Position position = await _determinePosition();

    if (position.toString() != null &&
        lastKnownPosition.toString() != position.toString()) {
      lastKnownPosition = position;
    }
    if (whatsapp) {
      await FlutterLaunch.launchWathsApp(
          phone: mobilenumber,
          message:
              "Hey I need help this is my last known location ${lastKnownPosition.toString()}");
    } else {
      print("Error Opening Whatsapp");
    }
  }

  @override
  Widget build(BuildContext context) {
    //Variables to get the screen width and height
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    print(height);
    //UI Rendering
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              height: height * 0.10,
            ),
            SizedBox(
              height: height * 0.20,
              child: SvgPicture.asset(
                'asset/images/logo.svg',
                color: Colors.green,
                height: 300,
                width: 100,
              ),
            ),
            SizedBox(
              height: height * 0.1,
            ),
            SingleChildScrollView(
              child: InternationalPhoneNumberInput(
                onInputChanged: (PhoneNumber pn) {
                  print(pn.isoCode + " " + pn.phoneNumber);
                  phonenumber = pn;
                },
                selectorConfig: SelectorConfig(
                  selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                  backgroundColor: Colors.grey,
                ),
                selectorTextStyle: TextStyle(
                  color: Colors.white,
                ),
                keyboardType: TextInputType.number,
                ignoreBlank: false,
                initialValue: phonenumber,
                textStyle: TextStyle(
                  color: Colors.white,
                ),
                inputDecoration: InputDecoration(
                  prefixIcon: IconButton(
                    icon: Icon(
                      Icons.account_circle_rounded,
                    ),
                    color: Colors.green,
                    iconSize: 20,
                    onPressed: () {},
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: BorderSide(
                      color: Colors.green,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: BorderSide(
                      color: Colors.white,
                    ),
                  ),
                  labelStyle: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Proxima Nova',
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    letterSpacing: 2.0,
                  ),
                  labelText: 'Mobile Number',
                ),
                textFieldController: number,
                countrySelectorScrollControlled: true,
              ),
            ),
            SizedBox(
              height: height * 0.05,
            ),
            Center(
              // ignore: deprecated_member_use
              child: RaisedButton(
                padding: EdgeInsets.fromLTRB(
                    width * 0.27, height * 0.023, width * 0.27, height * 0.023),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                color: Colors.green,
                onPressed: () {
                  whatsAppOpen(phonenumber.dialCode.toString(),
                      phonenumber.phoneNumber.toString());
                },
                child: SafeArea(
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'asset/images/logo.svg',
                        color: Colors.white,
                        height: 20,
                        width: 20,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'OPEN WHATSAPP',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          letterSpacing: 2.0,
                          fontFamily: 'Proxima Nova',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Center(
              // ignore: deprecated_member_use
              child: RaisedButton(
                padding: EdgeInsets.fromLTRB(
                    width * 0.08, height * 0.005, width * 0.08, height * 0.005),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                color: Colors.red,
                onPressed: () {
                  emergencyContact(emergencynumber.text.toString());
                },
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: Icon(Icons.location_on),
                        color: Colors.white,
                        iconSize: 20,
                        onPressed: () {},
                      ),
                      Text(
                        'WHATSAPP EMERGENCY CONTACT',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          letterSpacing: 2.0,
                          fontFamily: 'Proxima Nova',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: height * 0.10,
                ),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'MADE WITH ',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SvgPicture.asset(
                        'asset/images/heart.svg',
                        color: Colors.red,
                        height: 20,
                        width: 20,
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

//Class for the BottomModalSheet
class EmergencyContact extends StatelessWidget {
  double width(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: Colors.black,
        child: SafeArea(
            child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 40,
              ),
              Text(
                'EMERGENCY CONTACT NUMBER WITH COUNTRY CODE',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                focusNode: null,
                autofocus: false,
                decoration: InputDecoration(
                  prefixIcon: IconButton(
                    icon: Icon(
                      Icons.account_circle_rounded,
                    ),
                    color: Colors.green,
                    iconSize: 20,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: BorderSide(
                      color: Colors.green,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: BorderSide(
                      color: Colors.white,
                    ),
                  ),
                  labelStyle: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Proxima Nova',
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    letterSpacing: 2.0,
                  ),
                  labelText: 'Mobile Number',
                ),
                style: TextStyle(color: Colors.white),
                keyboardType: TextInputType.text,
                obscureText: false,
                controller: emergencynumber,
              ),
              SizedBox(
                height: 20,
              ),
              Center(
                // ignore: deprecated_member_use
                child: RaisedButton(
                  padding: EdgeInsets.fromLTRB(
                      width(context) * 0.20, 20, width(context) * 0.20, 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  color: Colors.red,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'SAVE EMERGENCY CONTACT',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      letterSpacing: 2.0,
                      fontFamily: 'Proxima Nova',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 40,
              ),
            ],
          ),
        )),
      ),
    );
  }
}
