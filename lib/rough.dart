//------------------------------------------------------------------------------
//
// auto pick your current location (and after pick will be appear there) ... enter your destination location name
//
// -----------------------------------------------------------------------------
//
// all complete address --------------------------------------------------------
//
//
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
//     return const GetMaterialApp(
//       home: MyMapPage(),
//     );
//   }
// }
//
// class MyMapPage extends StatefulWidget {
//   const MyMapPage({super.key});
//
//   @override
//   _MyMapPageState createState() => _MyMapPageState();
// }
//
// class _MyMapPageState extends State<MyMapPage> {
//   TextEditingController startController = TextEditingController();
//   TextEditingController endController = TextEditingController();
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
//   void initState() {
//     super.initState();
//     getCurrentLocation();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Journey Directions')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // Obx(() {
//             //   return Text('Current Location: ${currentLocation.value}');
//             // }),
//             TextField(
//               controller: startController,
//               decoration: const InputDecoration(
//                   hintText: 'Your Current Location'),
//             ),
//             TextField(
//               controller: endController,
//               decoration: const InputDecoration(hintText: 'Enter End Location'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 String start = startController.text.isEmpty &&
//                         currentLocation.value.isNotEmpty
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
//
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:location/location.dart' as loc;
// import 'package:geocoding/geocoding.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class LocationController extends GetxController {
//   RxString currentAddress = ''.obs;
//   RxDouble currentLat = 0.0.obs;
//   RxDouble currentLng = 0.0.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     _getCurrentLocation();
//   }
//
//   Future<void> _getCurrentLocation() async {
//     loc.Location location = loc.Location();
//     var currentLocation = await location.getLocation();
//     currentLat.value = currentLocation.latitude!;
//     currentLng.value = currentLocation.longitude!;
//
//     // Reverse geocoding to get the complete address from latitude and longitude
//     List<Placemark> placemarks = await placemarkFromCoordinates(currentLat.value, currentLng.value);
//     if (placemarks.isNotEmpty) {
//       Placemark place = placemarks.first;
//       // Construct the full address string
//       currentAddress.value = '${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}';
//     } else {
//       // Fallback to coordinates if address is not found
//       currentAddress.value = '${currentLat.value}, ${currentLng.value}';
//     }
//   }
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       title: 'Google Maps Directions',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: LocationPage(),
//     );
//   }
// }
//
// class LocationPage extends StatelessWidget {
//   final LocationController controller = Get.put(LocationController());
//   final TextEditingController destinationController = TextEditingController();
//
//   LocationPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Google Maps Directions"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // current location text field
//             Obx(() => TextField(
//               controller: TextEditingController(text: controller.currentAddress.value),
//               readOnly: true,
//               enabled: false,  // Prevent the field from being tapped or edited
//               decoration: const InputDecoration(labelText: 'Current Location'),
//             )),
//             const SizedBox(height: 16),
//
//             // your input destination Text field
//             TextField(
//               controller: destinationController,
//               decoration: const InputDecoration(labelText: 'Destination'),
//             ),
//             const SizedBox(height: 16),
//
//             ElevatedButton(
//               onPressed: () {
//                 // Open Google Maps with directions
//                 _openGoogleMaps();
//               },
//               child: const Text('Show Directions'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _openGoogleMaps() async {
//     if (controller.currentLat.value != 0.0 &&
//         controller.currentLng.value != 0.0 &&
//         destinationController.text.isNotEmpty) {
//       // Constructing the URL for Google Maps directions
//       String url =
//           'https://www.google.com/maps/dir/${controller.currentLat.value},${controller.currentLng.value}/${destinationController.text}';
//       // Open Google Maps using URL launcher
//       if (await canLaunch(url)) {
//         await launch(url);
//       } else {
//         throw 'Could not open the map.';
//       }
//     }
//   }
// }
//
// only city name---------------------------------------------------------------
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:location/location.dart' as loc; // Alias for location package
// import 'package:geocoding/geocoding.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class LocationController extends GetxController {
//   RxString currentAddress = ''.obs;
//   RxDouble currentLat = 0.0.obs;
//   RxDouble currentLng = 0.0.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     _getCurrentLocation();
//   }
//
//   Future<void> _getCurrentLocation() async {
//     loc.Location location = loc.Location(); // Use the aliased name
//     var currentLocation = await location.getLocation();
//     currentLat.value = currentLocation.latitude!;
//     currentLng.value = currentLocation.longitude!;
//
//     // Reverse geocoding to get the address from latitude and longitude
//     List<Placemark> placemarks = await placemarkFromCoordinates(currentLat.value, currentLng.value);
//     if (placemarks.isNotEmpty) {
//       currentAddress.value = '${placemarks.first.locality}, ${placemarks.first.country}';
//     } else {
//       // Fallback to coordinates if address is not found
//       currentAddress.value = '${currentLat.value}, ${currentLng.value}';
//     }
//   }
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       title: 'Google Maps Directions',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: LocationPage(),
//     );
//   }
// }
//
// class LocationPage extends StatelessWidget {
//   final LocationController controller = Get.put(LocationController());
//   final TextEditingController destinationController = TextEditingController();
//
//   LocationPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Google Maps Directions"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // current location text field
//             Obx(() => TextField(
//               controller: TextEditingController(text: controller.currentAddress.value),
//               readOnly: true,
//               enabled: false,  // Prevent the field from being tapped or edited
//               decoration: const InputDecoration(labelText: 'Current Location'),
//             )),
//             const SizedBox(height: 16),
//
//             // your input destination Text field
//             TextField(
//               controller: destinationController,
//               decoration: const InputDecoration(labelText: 'Destination'),
//             ),
//             const SizedBox(height: 16),
//
//             ElevatedButton(
//               onPressed: () {
//                 // Open Google Maps with directions
//                 _openGoogleMaps();
//               },
//               child: const Text('Show Directions'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _openGoogleMaps() async {
//     if (controller.currentLat.value != 0.0 &&
//         controller.currentLng.value != 0.0 &&
//         destinationController.text.isNotEmpty) {
//       // Constructing the URL for Google Maps directions
//       String url =
//           'https://www.google.com/maps/dir/${controller.currentLat.value},${controller.currentLng.value}/${destinationController.text}';
//       // Open Google Maps using URL launcher
//       if (await canLaunch(url)) {
//         await launch(url);
//       } else {
//         throw 'Could not open the map.';
//       }
//     }
//   }
// }









//------------------------------------------------------------------------------
//
// auto pick your current location (but anything wil not appear) ... enter your destination location name
//
// -----------------------------------------------------------------------------
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:location/location.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class LocationController extends GetxController {
//   RxString currentAddress = ''.obs;
//   RxDouble currentLat = 0.0.obs;
//   RxDouble currentLng = 0.0.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     _getCurrentLocation();
//   }
//
//   Future<void> _getCurrentLocation() async {
//     Location location = Location();
//     var currentLocation = await location.getLocation();
//     currentLat.value = currentLocation.latitude!;
//     currentLng.value = currentLocation.longitude!;
//     // You can use reverse geocoding here to get address
//   }
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       title: 'Google Maps Directions',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: LocationPage(),
//     );
//   }
// }
//
// class LocationPage extends StatelessWidget {
//
//   final LocationController controller = Get.put(LocationController());
//   final TextEditingController destinationController = TextEditingController();
//
//   LocationPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Google Maps Directions"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//
//             // current location text field
//             Obx(() => TextField(
//               controller: TextEditingController(text: controller.currentAddress.value),
//               readOnly: true,
//               enabled: false,  // Prevent the field from being tapped or edited
//               decoration: const InputDecoration(labelText: 'Current Location'),
//             )),
//             // Obx(() => TextField(
//             //   controller: TextEditingController(text: controller.currentAddress.value),
//             //   readOnly: true,
//             //   decoration: const InputDecoration(labelText: 'Current Location'),
//             // )),
//             const SizedBox(height: 16),
//
//             // your input destination Text field
//             TextField(
//               controller: destinationController,
//               decoration: const InputDecoration(labelText: 'Destination'),
//             ),
//             const SizedBox(height: 16),
//
//             ElevatedButton(
//               onPressed: () {
//                 // Open Google Maps with directions
//                 _openGoogleMaps();
//               },
//               child: const Text('Show Directions'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _openGoogleMaps() async {
//     if (controller.currentLat.value != 0.0 &&
//         controller.currentLng.value != 0.0 &&
//         destinationController.text.isNotEmpty) {
//       // Constructing the URL for Google Maps directions
//       String url =
//           'https://www.google.com/maps/dir/${controller.currentLat.value},${controller.currentLng.value}/${destinationController.text}';
//       // Open Google Maps using URL launcher
//       if (await canLaunch(url)) {
//         await launch(url);
//       } else {
//         throw 'Could not open the map.';
//       }
//     }
//   }
// }








// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:location/location.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class LocationController extends GetxController {
//   RxString currentAddress = ''.obs;
//   RxDouble currentLat = 0.0.obs;
//   RxDouble currentLng = 0.0.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     _getCurrentLocation();
//   }
//
//   Future<void> _getCurrentLocation() async {
//     Location location = Location();
//     var currentLocation = await location.getLocation();
//     currentLat.value = currentLocation.latitude!;
//     currentLng.value = currentLocation.longitude!;
//     // You can use reverse geocoding here to get address
//   }
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       title: 'Google Maps Directions',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: LocationPage(),
//     );
//   }
// }
//
// class LocationPage extends StatelessWidget {
//
//   final LocationController controller = Get.put(LocationController());
//   final TextEditingController destinationController = TextEditingController();
//
//   LocationPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Google Maps Directions"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//
//             // current location text field
//             Obx(() => TextField(
//               controller: TextEditingController(text: controller.currentAddress.value),
//               readOnly: true,
//               decoration: const InputDecoration(labelText: 'Current Location'),
//             )),
//             const SizedBox(height: 16),
//
//             // your input destination Text field
//             TextField(
//               controller: destinationController,
//               decoration: const InputDecoration(labelText: 'Destination'),
//             ),
//             const SizedBox(height: 16),
//
//             ElevatedButton(
//               onPressed: () {
//                 // Open Google Maps with directions
//                 _openGoogleMaps();
//               },
//               child: const Text('Show Directions'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _openGoogleMaps() async {
//     if (controller.currentLat.value != 0.0 &&
//         controller.currentLng.value != 0.0 &&
//         destinationController.text.isNotEmpty) {
//       // Constructing the URL for Google Maps directions
//       String url =
//           'https://www.google.com/maps/dir/${controller.currentLat.value},${controller.currentLng.value}/${destinationController.text}';
//       // Open Google Maps using URL launcher
//       if (await canLaunch(url)) {
//         await launch(url);
//       } else {
//         throw 'Could not open the map.';
//       }
//     }
//   }
// }








//------------------------------------------------------------------------------
//
// auto pick current location coordinates... & fill destination coordinates
//
//------------------------------------------------------------------------------
//
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
//   List<dynamic> _placePredictions = [];
//   final String _placesApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';  // Replace with your API Key
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
//       startController.text = 'Your Current Location'; // Change text to "Your Current Location"
//     });
//   }
//
//   // Method to fetch place predictions for end point
//   void _getPlacePredictions(String input) async {
//     if (input.isNotEmpty) {
//       var url = Uri.parse(
//           'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$_placesApiKey'
//       );
//
//       var response = await http.get(url);
//       var data = json.decode(response.body);
//
//       if (data['status'] == 'OK') {
//         setState(() {
//           _placePredictions = data['predictions'];
//         });
//       }
//     } else {
//       setState(() {
//         _placePredictions = [];
//       });
//     }
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
//               decoration: const InputDecoration(hintText: "Your Current Location"),
//               readOnly: true,
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: TextField(
//               controller: endController,
//               onChanged: _getPlacePredictions,
//               decoration: const InputDecoration(hintText: "Enter Place Name"),
//             ),
//           ),
//           // Display place predictions as a ListView
//           Expanded(
//             child: ListView.builder(
//               itemCount: _placePredictions.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   title: Text(_placePredictions[index]['description']),
//                   onTap: () {
//                     endController.text = _placePredictions[index]['description'];
//                     _placePredictions.clear();
//                     setState(() {});
//                   },
//                 );
//               },
//             ),
//           ),
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
//       home: const MapScreen(),
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
//   final startLatController = TextEditingController();
//   final startLngController = TextEditingController();
//   final endLatController = TextEditingController();
//   final endLngController = TextEditingController();
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
//     // Fill the start lat/lng controllers with current location
//     setState(() {
//       startLatController.text = '${position.latitude}';
//       startLngController.text = '${position.longitude}';
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Google Maps Route')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             // Start Latitude and Longitude
//             Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: startLatController,
//                     decoration: const InputDecoration(
//                       labelText: 'Start Latitude',
//                       hintText: 'Enter Start Latitude',
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: TextField(
//                     controller: startLngController,
//                     decoration: const InputDecoration(
//                       labelText: 'Start Longitude',
//                       hintText: 'Enter Start Longitude',
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 16),
//             // End Latitude and Longitude
//             Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: endLatController,
//                     decoration: const InputDecoration(
//                       labelText: 'End Latitude',
//                       hintText: 'Enter End Latitude',
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: TextField(
//                     controller: endLngController,
//                     decoration: const InputDecoration(
//                       labelText: 'End Longitude',
//                       hintText: 'Enter End Longitude',
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () async {
//                 var startLat = double.parse(startLatController.text);
//                 var startLng = double.parse(startLngController.text);
//                 var endLat = double.parse(endLatController.text);
//                 var endLng = double.parse(endLngController.text);
//
//                 var start = LatLng(startLat, startLng);
//                 var end = LatLng(endLat, endLng);
//
//                 var url = Uri.parse('https://www.google.com/maps/dir/?api=1&origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&travelmode=driving');
//
//                 if (await canLaunchUrl(url)) {
//                   await launchUrl(url);
//                 } else {
//                   throw 'Could not launch $url';
//                 }
//               },
//               child: const Text('Start Navigation'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }










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
