import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: MyMapPage(),
    );
  }
}

class MyMapPage extends StatelessWidget {
  MyMapPage({super.key});

  final MyMapPageController controller = Get.put(MyMapPageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Journey Directions')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Fixed destination text
            const Text(
              'Destination: Saharanpur, UP',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: () async {

                // await Geolocator.openLocationSettings();

                // Fetch current location before getting directions
                await controller.getCurrentLocation();

                // Start location is always current location
                String start = controller.currentLocation.value;

                // Fixed destination (Saharanpur, UP)
                String end = 'Saharanpur, UP';

                // Ensure that the current location is fetched
                if (start.isNotEmpty) {
                  controller.openGoogleMaps(start, end);
                } else {
                  Get.snackbar(
                    'Error',
                    'Could not determine current location!',
                    backgroundColor: Colors.red, // Error background color
                    colorText: Colors.white, // Text color
                  );
                }
              },
              child: const Text('Get Directions'),
            ),
          ],
        ),
      ),
    );
  }
}

class MyMapPageController extends GetxController {

  // RxString for current location
  RxString currentLocation = ''.obs;

  // To fetch current location
  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    // serviceEnabled = await Geolocator.isLocationServiceEnabled();
    // if (!serviceEnabled) {
    //   // Prompt user to enable location services
    //   Get.dialog(
    //     AlertDialog(
    //       title: const Text("Location Services Disabled"),
    //       content: const Text("Please enable location services to proceed."),
    //       actions: [
    //         TextButton(
    //           onPressed: () {
    //             Get.back();
    //           },
    //           child: const Text("Cancel"),
    //         ),
    //         TextButton(
    //           onPressed: () async {
    //             // Open location settings to turn on GPS
    //             Get.back();
    //             await Geolocator.openLocationSettings();
    //           },
    //           child: const Text("Enable GPS"),
    //         ),
    //       ],
    //     ),
    //   );
    //   return;
    // }

    // Check if permission is granted
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar(
          'Error',
          'Location permissions are denied',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
    }

    try {
      // Fetch the current location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      currentLocation.value = '${position.latitude},${position.longitude}';
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to get location: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Open Google Maps with directions
  void openGoogleMaps(String start, String end) async {
    String googleMapUrl =
        'https://www.google.com/maps/dir/?api=1&origin=$start&destination=$end&travelmode=driving';

    if (await canLaunch(googleMapUrl)) {
      await launch(googleMapUrl);
    } else {
      Get.snackbar(
        'Error',
        'Could not open Google Maps!',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onInit() {
    super.onInit();
  }
}











// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       home: MyMapPage(),
//     );
//   }
// }
//
// class MyMapPage extends StatelessWidget {
//   MyMapPage({super.key});
//
//   final MyMapPageController controller = Get.put(MyMapPageController());
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Journey Directions')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // Fixed destination text
//             const Text(
//               'Destination: Saharanpur, UP',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 // Start location is always current location
//                 String start = controller.currentLocation.value;
//
//                 // Fixed destination
//                 String end = 'Saharanpur, UP';
//
//                 if (start.isNotEmpty) {
//                   controller.openGoogleMaps(start, end);
//                 } else {
//                   Get.snackbar('Error', 'Could not determine current location!');
//                 }
//               },
//               child: const Text('Get Directions'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class MyMapPageController extends GetxController {
//
//   // RxString for current location
//   RxString currentLocation = ''.obs;
//
//   // To fetch current location
//   Future<void> getCurrentLocation() async {
//     bool serviceEnabled;
//     LocationPermission permission;
//
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       Get.snackbar('Error', 'Location services are disabled');
//       return;
//     }
//
//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         Get.snackbar('Error', 'Location permissions are denied');
//         return;
//       }
//     }
//
//     Position position = await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );
//     currentLocation.value = '${position.latitude},${position.longitude}';
//   }
//
//   // Open Google Maps with directions
//   void openGoogleMaps(String start, String end) async {
//     String googleMapUrl =
//         'https://www.google.com/maps/dir/?api=1&origin=$start&destination=$end&travelmode=driving';
//
//     if (await canLaunch(googleMapUrl)) {
//       await launch(googleMapUrl);
//     } else {
//       Get.snackbar('Error', 'Could not open Google Maps!');
//     }
//   }
//
//   @override
//   void onInit() {
//     super.onInit();
//     getCurrentLocation();
//   }
// }









//------------------------------------------------------------------------------
//
// auto pick your current location (and after pick will be appear there) ... enter your destination location name
//
// -----------------------------------------------------------------------------
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       home: MyMapPage(),
//     );
//   }
// }
//
// class MyMapPage extends StatelessWidget {
//   MyMapPage({super.key});
//
//   final MyMapPageController controller = Get.put(MyMapPageController());
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Journey Directions')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // Fixed destination text
//             const Text(
//               'Destination: Saharanpur, UP',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 String start = controller.startController.text.isEmpty &&
//                     controller.currentLocation.value.isNotEmpty
//                     ? controller.currentLocation.value
//                     : controller.startController.text;
//
//                 // Fixed destination
//                 String end = 'Saharanpur, UP';
//
//                 if (end.isNotEmpty) {
//                   controller.openGoogleMaps(start, end);
//                 } else {
//                   Get.snackbar('Error', 'Please enter a destination!');
//                 }
//               },
//               child: const Text('Get Directions'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class MyMapPageController extends GetxController {
//
//   // RxString for current location
//   RxString currentLocation = ''.obs;
//   TextEditingController startController = TextEditingController();
//
//   // To fetch current location
//   Future<void> getCurrentLocation() async {
//     bool serviceEnabled;
//     LocationPermission permission;
//
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       Get.snackbar('Error', 'Location services are disabled');
//       return;
//     }
//
//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         Get.snackbar('Error', 'Location permissions are denied');
//         return;
//       }
//     }
//
//     Position position = await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );
//     currentLocation.value = '${position.latitude},${position.longitude}';
//   }
//
//   // Open Google Maps with directions
//   void openGoogleMaps(String start, String end) async {
//     String googleMapUrl =
//         'https://www.google.com/maps/dir/?api=1&origin=$start&destination=$end&travelmode=driving';
//
//     if (await canLaunch(googleMapUrl)) {
//       await launch(googleMapUrl);
//     } else {
//       Get.snackbar('Error', 'Could not open Google Maps!');
//     }
//   }
//
//   @override
//   void onInit() {
//     super.onInit();
//     getCurrentLocation();
//   }
// }




// class MyMapPage extends StatelessWidget {
//   MyMapPage({super.key});
//
//   final MyMapPageController controller = Get.put(MyMapPageController());
//
//   @override
//   Widget build(BuildContext context) {
//
//     // Call the getCurrentLocation once when the widget is built
//     // getCurrentLocation();
//
//     return Scaffold(
//       appBar: AppBar(title: const Text('Journey Directions')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // Obx(() {
//             //   return Text('Current Location: ${controller.currentLocation.value}');
//             // }),
//             TextField(
//               controller: controller.startController,
//               decoration: const InputDecoration(
//                   hintText: 'current location'),
//             ),
//             TextField(
//               controller: controller.endController,
//               decoration: const InputDecoration(hintText: 'destination'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 String start = controller.startController.text.isEmpty &&
//                     controller.currentLocation.value.isNotEmpty
//                     ? controller.currentLocation.value
//                     : controller.startController.text;
//                 String end = controller.endController.text;
//
//                 if (end.isNotEmpty) {
//                   controller.openGoogleMaps(start, end);
//                 } else {
//                   Get.snackbar('Error', 'Please enter a destination!');
//                 }
//               },
//               child: const Text('Get Directions'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class MyMapPageController extends GetxController{
//
//   // RxString for current location
//   RxString currentLocation = ''.obs;
//   TextEditingController startController = TextEditingController();
//   TextEditingController endController = TextEditingController();
//
//   // To fetch current location
//   Future<void> getCurrentLocation() async {
//     bool serviceEnabled;
//     LocationPermission permission;
//
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       Get.snackbar('Error', 'Location services are disabled');
//       return;
//     }
//
//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         Get.snackbar('Error', 'Location permissions are denied');
//         return;
//       }
//     }
//
//     Position position = await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );
//     currentLocation.value = '${position.latitude},${position.longitude}';
//   }
//
//   // Open Google Maps with directions
//   void openGoogleMaps(String start, String end) async {
//     String googleMapUrl =
//         'https://www.google.com/maps/dir/?api=1&origin=$start&destination=$end&travelmode=driving';
//
//     if (await canLaunch(googleMapUrl)) {
//       await launch(googleMapUrl);
//     } else {
//       Get.snackbar('Error', 'Could not open Google Maps!');
//     }
//   }
//
//   @override
//   void onInit(){
//     super.onInit();
//     getCurrentLocation();
//   }
// }










// class MyMapPage extends StatelessWidget {
//   MyMapPage({super.key});
//
//   // RxString for current location
//   RxString currentLocation = ''.obs;
//   TextEditingController startController = TextEditingController();
//   TextEditingController endController = TextEditingController();
//
//   // To fetch current location
//   Future<void> getCurrentLocation() async {
//     bool serviceEnabled;
//     LocationPermission permission;
//
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       Get.snackbar('Error', 'Location services are disabled');
//       return;
//     }
//
//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         Get.snackbar('Error', 'Location permissions are denied');
//         return;
//       }
//     }
//
//     Position position = await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );
//     currentLocation.value = '${position.latitude},${position.longitude}';
//   }
//
//   // Open Google Maps with directions
//   void openGoogleMaps(String start, String end) async {
//     String googleMapUrl =
//         'https://www.google.com/maps/dir/?api=1&origin=$start&destination=$end&travelmode=driving';
//
//     if (await canLaunch(googleMapUrl)) {
//       await launch(googleMapUrl);
//     } else {
//       Get.snackbar('Error', 'Could not open Google Maps!');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // Call the getCurrentLocation once when the widget is built
//     getCurrentLocation();
//
//     return Scaffold(
//       appBar: AppBar(title: const Text('Journey Directions')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Obx(() {
//               return Text('Current Location: ${currentLocation.value}');
//             }),
//             TextField(
//               controller: startController,
//               decoration: const InputDecoration(
//                   hintText: 'current location'),
//             ),
//             TextField(
//               controller: endController,
//               decoration: const InputDecoration(hintText: 'destination'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 String start = startController.text.isEmpty &&
//                     currentLocation.value.isNotEmpty
//                     ? currentLocation.value
//                     : startController.text;
//                 String end = endController.text;
//
//                 if (end.isNotEmpty) {
//                   openGoogleMaps(start, end);
//                 } else {
//                   Get.snackbar('Error', 'Please enter a destination!');
//                 }
//               },
//               child: const Text('Get Directions'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }