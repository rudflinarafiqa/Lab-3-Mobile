import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GOOGLE MAP',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('GOOGLE MAP'),
          backgroundColor: Colors.green[900],
        ),
        body: Center(
          child: Maps(),
        ),
      ),
    );
  }
}

class Maps extends StatefulWidget {
  @override
  _MapsState createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  MapType _currentMapType = MapType.normal;
  Position _currentPosition;
  String _homeloc ;
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  double screenHeight = 0.00, screenWidth = 0.00;
  String gmaploc = "";
  Completer<GoogleMapController> _controller = Completer();
  static const LatLng _center = const LatLng(6.4676929, 100.5067673);
  MarkerId markerId1 = MarkerId("marker");
  Set<Marker> _markers = Set();
  LatLng _lastMapPosition = _center;

  String _currentAddress;
  double latitude, longitude, restlat, restlon;
  GoogleMapController gmcontroller;
  CameraPosition _home;
  CameraPosition _userpos;
  

  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  @override
  void initState() {
    super.initState();
    _getLocation();
    _markers.add(Marker(
        markerId: markerId1,
        position: _center,
        draggable: true,
        onTap: () {
          print('marker tapped');
          _getLocation();
        }));
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return StatefulBuilder(
      builder: (context, newSetState) {
        return SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 2 * (MediaQuery.of(context).size.height / 3),
                width: MediaQuery.of(context).size.width - 10,
                child: GoogleMap(
                  mapType: MapType.normal,
                  onMapCreated: _onMapCreated,
                  
                  initialCameraPosition: CameraPosition(
                    target: _center,
                    zoom: 17.0,
                  ),
                  markers: _markers.toSet(),
                  onTap: (newLatLng) {
                    _loadLoc(newLatLng, newSetState);
                  },
                ),
              ),
              SizedBox(
                height: 5,
              ),
              
              Center(
                     child: Column(
                    children: <Widget>[
                       Column(
                        children: <Widget> [
                          
                          Align( alignment: Alignment.center ,child: Text('Latitude: ' + latitude.toString(),)),
                          Align( alignment: Alignment.center ,child: Text('Longitude: ' + longitude.toString(),)),
                          Align( alignment: Alignment.center ,child: Text('Address: ' + _currentAddress.toString(),)),
                        ],
                      ),
                      
                    ] 
                  )
                 
                   ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getLocation() async {
    try {
      final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
      geolocator
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
          .then((Position position) async {
        _currentPosition = position;
        if (_currentPosition != null) {
          final coordinates = new Coordinates(
              _currentPosition.latitude, _currentPosition.longitude);
          var addresses =
              await Geocoder.local.findAddressesFromCoordinates(coordinates);
          setState(() {
            var first = addresses.first;
            if (_homeloc != null) {
              latitude = _currentPosition.latitude;
              longitude = _currentPosition.longitude;
              _homeloc = first.addressLine;
              return;
            }
          });
        }
      }).catchError((e) {
        print(e);
      });
    } catch (exception) {
      print(exception.toString());
    }
  }

  void _loadLoc(LatLng loc, newSetState) async {
    newSetState(() {
      print("insetstate");
      _markers.clear();
      latitude = loc.latitude;
      longitude = loc.longitude;
      _getLocationfromlatlng(latitude, longitude, newSetState);
      _home = CameraPosition(
        target: loc,
        zoom: 17,
      );
      _markers.add(Marker(
        markerId: markerId1,
        position: LatLng(latitude, longitude),
        infoWindow: InfoWindow(
          title: 'New Location',
          snippet: 'New Mark Location',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ));
    });
    _userpos = CameraPosition(
      target: LatLng(latitude, longitude),
      zoom: 17,
    );
    _newhomeLocation();
  }

  _getLocationfromlatlng(double lat, double lng, newSetState) async {
    final Geolocator geolocator = Geolocator()
      ..placemarkFromCoordinates(lat, lng);
    _currentPosition = await geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    final coordinates = new Coordinates(lat, lng);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    newSetState(() {
      _homeloc = first.addressLine;
      if (_homeloc != null) {
        latitude = lat;
        longitude = lng;
        return;
      }
    });
    setState(() {
      _homeloc = first.addressLine;
      if (_homeloc != null) {
        latitude = lat;
        longitude = lng;
        return;
      }
    });
  }

  Future<void> _newhomeLocation() async {
    gmcontroller = await _controller.future;
    gmcontroller.animateCamera(CameraUpdate.newCameraPosition(_home));
  }

          void getCurrentLocation(tappedPoint) async {
           try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          tappedPoint.latitude, tappedPoint.longitude);
      latitude = tappedPoint.latitude;
      longitude = tappedPoint.longitude;
     
  final coordinates = new Coordinates(latitude, longitude);
  var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);

  var first = addresses.first;

      Placemark place = p[0];

      setState(() {
        _currentAddress =
            "${first.addressLine}";
      });
    } catch (e) {
      print(e);
    }
          print(tappedPoint);
        }
}