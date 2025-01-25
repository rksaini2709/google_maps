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

    // Call the getCurrentLocation once when the widget is built
    // getCurrentLocation();

    return Scaffold(
      appBar: AppBar(title: const Text('Journey Directions')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Obx(() {
            //   return Text('Current Location: ${controller.currentLocation.value}');
            // }),
            TextField(
              controller: controller.startController,
              decoration: const InputDecoration(
                  hintText: 'current location'),
            ),
            TextField(
              controller: controller.endController,
              decoration: const InputDecoration(hintText: 'destination'),
            ),
            ElevatedButton(
              onPressed: () {
                String start = controller.startController.text.isEmpty &&
                    controller.currentLocation.value.isNotEmpty
                    ? controller.currentLocation.value
                    : controller.startController.text;
                String end = controller.endController.text;

                if (end.isNotEmpty) {
                  controller.openGoogleMaps(start, end);
                } else {
                  Get.snackbar('Error', 'Please enter a destination!');
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

class MyMapPageController extends GetxController{

  // RxString for current location
  RxString currentLocation = ''.obs;
  TextEditingController startController = TextEditingController();
  TextEditingController endController = TextEditingController();

  // To fetch current location
  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar('Error', 'Location services are disabled');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar('Error', 'Location permissions are denied');
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    currentLocation.value = '${position.latitude},${position.longitude}';
  }

  // Open Google Maps with directions
  void openGoogleMaps(String start, String end) async {
    String googleMapUrl =
        'https://www.google.com/maps/dir/?api=1&origin=$start&destination=$end&travelmode=driving';

    if (await canLaunch(googleMapUrl)) {
      await launch(googleMapUrl);
    } else {
      Get.snackbar('Error', 'Could not open Google Maps!');
    }
  }

  @override
  void onInit(){
    super.onInit();
    getCurrentLocation();
  }
}










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