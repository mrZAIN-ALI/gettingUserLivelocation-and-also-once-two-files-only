// import 'package:flutter/foundation.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:url_launcher/url_launcher.dart';

// class MyMap extends StatelessWidget {

//   @override
//   Widget build(BuildContext context) {
//     return FlutterMap(
//       options: MapOptions(
//         center: LatLng(51.509364, -0.128928),
//         zoom: 9.2,
//       ),
//       nonRotatedChildren: [
//         RichAttributionWidget(
//           attributions: [
//             TextSourceAttribution(
//               'OpenStreetMap contributors',
//               onTap: () =>
//                   launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
//             ),
//           ],
//         ),
//       ],
//       children: [
//         TileLayer(
//           urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
//           userAgentPackageName: 'com.example.app',
//         ),
//       ],
//     );
//   }
// }
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocode/geocode.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';

class MyMap extends StatefulWidget {
  const MyMap({super.key});

  @override
  State<MyMap> createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {

  LatLng _currentLocation=LatLng(0,0);
  Position ?position;
  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    print("returning current locaiton");
    return await Geolocator.getCurrentPosition();
  }
  void _getLocation() async {
    position = await _determinePosition();
    setState(() {
      
    _currentLocation = LatLng(position!.latitude, position!.longitude);
    });
    print(_currentLocation);
  }
  @override
  void didChangeDependencies() {
    _determinePosition();
    // TODO: implement didChangeDependencies
    _getLocation();
    super.didChangeDependencies();
  }
  @override
  void initState() {
    
    // TODO: implement initState
    _getLocation();
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(width: 6),),
      child: Text("Hehe Your Current lcoation is : ${_currentLocation} "),
    );
  }
}
// class MyMap extends StatefulWidget {
//   @override
//   _MyMapState createState() => _MyMapState();
// }

// class _MyMapState extends State<MyMap> {
//   LatLng _currentPosition=LatLng(34,-12);
//   List<String> _suggestions = [];
//   late StreamSubscription<Position> _locationSubscription;

//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//     _listenForLocationChanges();
//   }

//   @override
//   void dispose() {
//     _locationSubscription?.cancel();
//     super.dispose();
//   }

//   void _getCurrentLocation() async {
//     try {
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//       setState(() {
//         _currentPosition = LatLng(position.latitude, position.longitude);
//         print("Got position: Lat ${_currentPosition.latitude}, Long ${_currentPosition.longitude}");
//       });
//     } catch (e) {
//       print("Failed to get location: $e");
//     }
//   }

//   void _listenForLocationChanges() {
//     _locationSubscription = Geolocator.getPositionStream( locationSettings: AndroidSettings(accuracy:LocationAccuracy.high),)
//         .listen((Position position) {
//       setState(() {
//         _currentPosition = LatLng(position.latitude, position.longitude);
//       });
//     });
//   }

//   Future<List<String>> _fetchSuggestions(String query) async {
//     if (query.isEmpty) {
//       return [];
//     }

//     final url =
//         "https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1";
//     final response = await http.get(Uri.parse(url));

//     if (response.statusCode == 200) {
//       final List<dynamic> data = jsonDecode(response.body);
//       return data.map((place) => place['display_name'] as String).toList();
//     } else {
//       throw Exception("Failed to fetch suggestions");
//     }
//   }

//   Future<List<MapLocation>> _fetchPlaces(String query) async {
//     final url =
//         "https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1";
//     final response = await http.get(Uri.parse(url));

//     if (response.statusCode == 200) {
//       final List<dynamic> data = jsonDecode(response.body);
//       return data.map((place) => MapLocation.fromJson(place)).toList();
//     } else {
//       throw Exception("Failed to fetch places");
//     }
//   }

//   void _selectSuggestion(int index) async {
//     if (index >= 0 && index < _suggestions.length) {
//       final selectedSuggestion = _suggestions[index];
//       print("Selected suggestion: $selectedSuggestion");

//       final places = await _fetchPlaces(selectedSuggestion);
//       if (places.isNotEmpty) {
//         final selectedLocation = places[0];
//         setState(() {
//           _currentPosition =
//               LatLng(selectedLocation.latitude, selectedLocation.longitude);
//         });
//       }

//       setState(() {
//         _suggestions.clear();
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           FlutterMap(
//             options: MapOptions(
//               center: _currentPosition,
//               zoom: 10.0,
//             ),
//             children: [
//               TileLayer(
//                 urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
//                 subdomains: ['a', 'b', 'c'],
//               ),
//               // MarkerLayerOptions(
//               //   markers: [
//               //     Marker(
//               //       width: 40,
//               //       height: 40,
//               //       point: LatLng(_currentPosition.latitude, _currentPosition.longitude),
//               //       builder: (ctx) => Container(
//               //         child: Icon(Icons.location_on),
//               //       ),
//               //     ),
//               //   ],
//               // ),
//             ],
//           ),
//           buildFloatingSearchBar(),
//           Container(
//             child: Text("Your location is: ${_currentPosition?.longitude ?? ""}"),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget buildFloatingSearchBar() {
//     return FloatingSearchBar(
//       hint: 'Search locations...',
//       scrollPadding: const EdgeInsets.only(top: 16.0),
//       transitionDuration: const Duration(milliseconds: 800),
//       transitionCurve: Curves.easeInOut,
//       physics: const BouncingScrollPhysics(),
//       openAxisAlignment: 0.0,
//       debounceDelay: const Duration(milliseconds: 500),
//       onQueryChanged: (query) {
//         if (query.isNotEmpty) {
//           _fetchSuggestions(query).then((suggestions) {
//             setState(() {
//               _suggestions = suggestions;
//             });
//           }).catchError((error) {
//             print(error);
//           });
//         } else {
//           setState(() {
//             _suggestions = [];
//           });
//         }
//       },
//       actions: [
//         FloatingSearchBarAction.icon(
//           icon: Icons.place,
//           onTap: () {},
//         ),
//         FloatingSearchBarAction.searchToClear(),
//       ],
//       builder: (context, transition) {
//         return ClipRRect(
//           borderRadius: BorderRadius.circular(8),
//           child: Material(
//             color: Colors.white,
//             elevation: 4.0,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 ListView.builder(
//                   shrinkWrap: true,
//                   itemCount: _suggestions.length,
//                   itemBuilder: (context, index) {
//                     final suggestion = _suggestions[index];
//                     return ListTile(
//                       title: Text(suggestion),
//                       onTap: () {
//                         _selectSuggestion(index);
//                       },
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// class MapLocation {
//   final double latitude;
//   final double longitude;
//   final String displayName;
//   final String? address;

//   MapLocation({
//     required this.latitude,
//     required this.longitude,
//     required this.displayName,
//     this.address,
//   });

//   factory MapLocation.fromJson(Map<String, dynamic> json) {
//     return MapLocation(
//       latitude: double.parse(json['lat']),
//       longitude: double.parse(json['lon']),
//       displayName: json['display_name'],
//       address: json['address'] != null ? json['address']['formatted'] : null,
//     );
//   }
// }
