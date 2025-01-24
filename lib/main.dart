import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MapScreen(),
    );
  }
}

class MapController extends GetxController {
  var googleMapController = Rx<GoogleMapController?>(null);
  var polylinePoints = <LatLng>[];
  var distance = '0 km';
  var time = '0 mins';

  Future<void> getRoute(LatLng start, LatLng end) async {
    var url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&key=YOUR_GOOGLE_MAPS_API_KEY');

    var response = await http.get(url);
    var data = json.decode(response.body);

    if (data['status'] == 'OK') {
      var points = data['routes'][0]['overview_polyline']['points'];
      polylinePoints = decodePolyline(points);

      distance = data['routes'][0]['legs'][0]['distance']['text'];
      time = data['routes'][0]['legs'][0]['duration']['text'];

      update();
    }
  }

  List<LatLng> decodePolyline(String encoded) {
    var poly = <LatLng>[];
    var index = 0;
    var len = encoded.length;
    var lat = 0;
    var lng = 0;

    while (index < len) {
      var b;
      var shift = 0;
      var result = 0;
      do {
        b = encoded.codeUnitAt(index) - 63;
        index++;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      var dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index) - 63;
        index++;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      var dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      poly.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return poly;
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final startLatController = TextEditingController();
  final startLngController = TextEditingController();
  final endLatController = TextEditingController();
  final endLngController = TextEditingController();
  final MapController mapController = Get.put(MapController());

  @override
  void initState() {
    super.initState();
    _checkPermissions(); // Check permissions when the screen loads
  }

  // Method to check and request permissions at runtime
  Future<void> _checkPermissions() async {
    PermissionStatus status = await Permission.location.request();
    if (status.isGranted) {
      _getCurrentLocation();  // Proceed to get current location if permission is granted
    } else {
      print('Location permission denied');
    }
  }

  // Method to get current location
  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // Fill the start lat/lng controllers with current location
    setState(() {
      startLatController.text = '${position.latitude}';
      startLngController.text = '${position.longitude}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google Maps Route')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Start Latitude and Longitude
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: startLatController,
                    decoration: const InputDecoration(
                      labelText: 'Start Latitude',
                      hintText: 'Enter Start Latitude',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: startLngController,
                    decoration: const InputDecoration(
                      labelText: 'Start Longitude',
                      hintText: 'Enter Start Longitude',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // End Latitude and Longitude
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: endLatController,
                    decoration: const InputDecoration(
                      labelText: 'End Latitude',
                      hintText: 'Enter End Latitude',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: endLngController,
                    decoration: const InputDecoration(
                      labelText: 'End Longitude',
                      hintText: 'Enter End Longitude',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                var startLat = double.parse(startLatController.text);
                var startLng = double.parse(startLngController.text);
                var endLat = double.parse(endLatController.text);
                var endLng = double.parse(endLngController.text);

                var start = LatLng(startLat, startLng);
                var end = LatLng(endLat, endLng);

                var url = Uri.parse('https://www.google.com/maps/dir/?api=1&origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&travelmode=driving');

                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                } else {
                  throw 'Could not launch $url';
                }
              },
              child: const Text('Start Navigation'),
            ),
          ],
        ),
      ),
    );
  }
}










// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:get/get.dart';
// import 'package:permission_handler/permission_handler.dart';
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
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: MapScreen(),
//     );
//   }
// }
//
// class MapController extends GetxController {
//   var googleMapController = Rx<GoogleMapController?>(null);
//   var polylinePoints = <LatLng>[];
//   var distance = '0 km';
//   var time = '0 mins';
//
//   Future<void> getRoute(LatLng start, LatLng end) async {
//     var url = Uri.parse(
//         'https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&key=YOUR_GOOGLE_MAPS_API_KEY');
//
//     var response = await http.get(url);
//     var data = json.decode(response.body);
//
//     if (data['status'] == 'OK') {
//       var points = data['routes'][0]['overview_polyline']['points'];
//       polylinePoints = decodePolyline(points);
//
//       distance = data['routes'][0]['legs'][0]['distance']['text'];
//       time = data['routes'][0]['legs'][0]['duration']['text'];
//
//       update();
//     }
//   }
//
//   List<LatLng> decodePolyline(String encoded) {
//     var poly = <LatLng>[];
//     var index = 0;
//     var len = encoded.length;
//     var lat = 0;
//     var lng = 0;
//
//     while (index < len) {
//       var b;
//       var shift = 0;
//       var result = 0;
//       do {
//         b = encoded.codeUnitAt(index) - 63;
//         index++;
//         result |= (b & 0x1f) << shift;
//         shift += 5;
//       } while (b >= 0x20);
//       var dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
//       lat += dlat;
//
//       shift = 0;
//       result = 0;
//       do {
//         b = encoded.codeUnitAt(index) - 63;
//         index++;
//         result |= (b & 0x1f) << shift;
//         shift += 5;
//       } while (b >= 0x20);
//       var dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
//       lng += dlng;
//
//       poly.add(LatLng(lat / 1E5, lng / 1E5));
//     }
//     return poly;
//   }
// }
//
// class MapScreen extends StatefulWidget {
//   const MapScreen({super.key});
//
//   @override
//   _MapScreenState createState() => _MapScreenState();
// }
//
// class _MapScreenState extends State<MapScreen> {
//   final startController = TextEditingController();
//   final endController = TextEditingController();
//   final MapController mapController = Get.put(MapController());
//
//   @override
//   void initState() {
//     super.initState();
//     _checkPermissions(); // Check permissions when the screen loads
//   }
//
//   // Method to check and request permissions at runtime
//   Future<void> _checkPermissions() async {
//     PermissionStatus status = await Permission.location.request();
//     if (status.isGranted) {
//       _getCurrentLocation();  // Proceed to get current location if permission is granted
//     } else {
//       print('Location permission denied');
//     }
//   }
//
//   // Method to get current location
//   Future<void> _getCurrentLocation() async {
//     Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//
//     // coordinate of start point (my current coordinate)
//     setState(() {
//       startController.text = '${position.latitude},${position.longitude}';
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Google Maps Route')),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: TextField(
//               controller: startController,
//               decoration: const InputDecoration(hintText: "Enter Start Lat,Lng"),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: TextField(
//               controller: endController,
//               decoration: const InputDecoration(hintText: "Enter End Lat,Lng"),
//             ),
//           ),
//           // ElevatedButton(
//           //   onPressed: () {
//           //     var startLatLng = startController.text.split(',');
//           //     var endLatLng = endController.text.split(',');
//           //     var start = LatLng(double.parse(startLatLng[0]), double.parse(startLatLng[1]));
//           //     var end = LatLng(double.parse(endLatLng[0]), double.parse(endLatLng[1]));
//           //
//           //     mapController.getRoute(start, end);
//           //   },
//           //   child: Text('Show Route'),
//           // ),
//           const SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: () async {
//               var startLatLng = startController.text.split(',');
//               var endLatLng = endController.text.split(',');
//               var start = LatLng(double.parse(startLatLng[0]), double.parse(startLatLng[1]));
//               var end = LatLng(double.parse(endLatLng[0]), double.parse(endLatLng[1]));
//
//               var url = Uri.parse('https://www.google.com/maps/dir/?api=1&origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&travelmode=driving');
//
//               if (await canLaunchUrl(url)) {
//                 await launchUrl(url);
//               } else {
//                 throw 'Could not launch $url';
//               }
//             },
//             child: const Text('Start Navigation'),
//           ),
//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }
// }












// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:get/get.dart';
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
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: MapScreen(),
//     );
//   }
// }
//
// class MapController extends GetxController {
//   var googleMapController = Rx<GoogleMapController?>(null);
//   var polylinePoints = <LatLng>[];
//   var distance = '0 km';
//   var time = '0 mins';
//
//   Future<void> getRoute(LatLng start, LatLng end) async {
//     var url = Uri.parse(
//         'https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&key=YOUR_GOOGLE_MAPS_API_KEY');
//
//     var response = await http.get(url);
//     var data = json.decode(response.body);
//
//     if (data['status'] == 'OK') {
//       // Getting polyline points (route path)
//       var points = data['routes'][0]['overview_polyline']['points'];
//       polylinePoints = decodePolyline(points);
//
//       // Calculating Distance and Duration
//       distance = data['routes'][0]['legs'][0]['distance']['text'];
//       time = data['routes'][0]['legs'][0]['duration']['text'];
//
//       update();
//     }
//   }
//
//   List<LatLng> decodePolyline(String encoded) {
//     var poly = <LatLng>[];
//     var index = 0;
//     var len = encoded.length;
//     var lat = 0;
//     var lng = 0;
//
//     while (index < len) {
//       var b;
//       var shift = 0;
//       var result = 0;
//       do {
//         b = encoded.codeUnitAt(index) - 63;
//         index++;
//         result |= (b & 0x1f) << shift;
//         shift += 5;
//       } while (b >= 0x20);
//       var dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
//       lat += dlat;
//
//       shift = 0;
//       result = 0;
//       do {
//         b = encoded.codeUnitAt(index) - 63;
//         index++;
//         result |= (b & 0x1f) << shift;
//         shift += 5;
//       } while (b >= 0x20);
//       var dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
//       lng += dlng;
//
//       poly.add(LatLng(lat / 1E5, lng / 1E5));
//     }
//     return poly;
//   }
// }
//
// class MapScreen extends StatelessWidget {
//   final startController = TextEditingController();
//   final endController = TextEditingController();
//   final MapController mapController = Get.put(MapController());
//
//   MapScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Google Maps Route')),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: TextField(
//               controller: startController,
//               decoration: InputDecoration(hintText: "Enter Start Lat,Lng"),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: TextField(
//               controller: endController,
//               decoration: InputDecoration(hintText: "Enter End Lat,Lng"),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               var startLatLng = startController.text.split(',');
//               var endLatLng = endController.text.split(',');
//               var start = LatLng(double.parse(startLatLng[0]), double.parse(startLatLng[1]));
//               var end = LatLng(double.parse(endLatLng[0]), double.parse(endLatLng[1]));
//
//               mapController.getRoute(start, end);
//             },
//             child: Text('Show Route'),
//           ),
//           SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: () async {
//               var startLatLng = startController.text.split(',');
//               var endLatLng = endController.text.split(',');
//               var start = LatLng(double.parse(startLatLng[0]), double.parse(startLatLng[1]));
//               var end = LatLng(double.parse(endLatLng[0]), double.parse(endLatLng[1]));
//
//               var url = Uri.parse('https://www.google.com/maps/dir/?api=1&origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&travelmode=driving');
//
//               // Launch URL to Google Maps
//               if (await canLaunchUrl(url)) {
//                 await launchUrl(url);
//               } else {
//                 throw 'Could not launch $url';
//               }
//             },
//             child: Text('Start Navigation'),
//           ),
//           SizedBox(height: 20),
//           // Use Obx only for the specific part that updates (distance, time, etc.)
//           // Obx(() => mapController.polylinePoints.isNotEmpty
//           //     ? Column(
//           //   children: [
//           //     Text('Distance: ${mapController.distance}'),
//           //     Text('Time: ${mapController.time}')
//           //   ],
//           // )
//           //     : Container()),
//           // Expanded(
//           //   child: GoogleMap(
//           //     onMapCreated: (controller) {
//           //       mapController.googleMapController.value = controller;
//           //     },
//           //     initialCameraPosition: CameraPosition(
//           //       target: LatLng(0, 0),
//           //       zoom: 2,
//           //     ),
//           //     polylines: {
//           //       Polyline(
//           //         polylineId: PolylineId('route'),
//           //         points: mapController.polylinePoints,
//           //         color: Colors.blue,
//           //         width: 5,
//           //       ),
//           //     },
//           //   ),
//           // ),
//         ],
//       ),
//     );
//   }
// }
