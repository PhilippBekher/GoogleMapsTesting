import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_application_1/location_service.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps Demo',
      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Completer<GoogleMapController> _controller = Completer();
  TextEditingController _originController = TextEditingController();
  TextEditingController _destinationController = TextEditingController();
  Set<Marker> _markers = Set<Marker>();
  List<LatLng> polygonLatLngs = <LatLng>[];
  Set<Polygon> _polygons = Set<Polygon>();
  Set<Polyline> _polylines = Set<Polyline>();

  int _polygonIdCounter = 1;
  int _polylineIdCounter = 1;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  // static final Marker _kGooglePlexMarker = Marker(
  //     markerId: MarkerId('_kGooglePlex'),
  //     infoWindow: InfoWindow(title: 'Google Plex'),
  //     icon: BitmapDescriptor.defaultMarker,
  //     position: LatLng(39.43296265331129, -122.08832357078792));

  // static final Marker _kLakeMarker = Marker(
  //     markerId: MarkerId('_kLakeMarker'),
  //     infoWindow: InfoWindow(title: 'Lake'),
  //     icon: BitmapDescriptor.defaultMarker,
  //     position: LatLng(37.43296265331129, -122.08832357078792));
  @override
  void initState() {
    _markers.add(Marker(
      //add marker on google map
      markerId: MarkerId('34'),
      position:
          LatLng(39.43296265331129, -122.08832357078792), //position of marker
      infoWindow: InfoWindow(
        //popup info
        title: 'My Custom Title ',
        snippet: 'My Custom Subtitle',
      ),
      icon: BitmapDescriptor.defaultMarker, //Icon for Marker
    ));

    //you can add more markers here

    super.initState();
    // _setMarker(LatLng(39.43296265331129, -122.08832357078792));
  }

  void _setMarker(LatLng point) {
    setState(() {
      _markers.add(Marker(markerId: MarkerId('3'), position: point));
    });
  }

  void _setPolygon() {
    final String polygonIdVal = 'polygon_$_polygonIdCounter';
    _polygonIdCounter++;

    _polygons.add(Polygon(
        polygonId: PolygonId(polygonIdVal),
        points: polygonLatLngs,
        strokeWidth: 2,
        fillColor: Colors.transparent));
  }

  void _setPopyline(List<PointLatLng> points) {
    final String polylineIdval = 'polyline_$_polylineIdCounter';
    _polygonIdCounter++;

    _polylines.add(Polyline(
        polylineId: PolylineId(polylineIdval),
        width: 2,
        color: Colors.blue,
        points: points
            .map(
              (point) => LatLng(point.latitude, point.longitude),
            )
            .toList()));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text('GM'),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _originController,
                  decoration: InputDecoration(hintText: 'Search By City'),
                  onChanged: (value) {
                    print(value);
                  },
                ),
              ),
              IconButton(
                  onPressed: () async {
                    var directions = await LocationService().getDirections(
                        _originController.text, _destinationController.text);

                    _goToPlace(
                        directions['start_location']['lat'],
                        directions['start_location']['lng'],
                        directions['bounds_ne'],
                        directions['bounds_sw']);
                    _setPopyline(directions['polyline_decoded']);
                  },
                  icon: Icon(Icons.search))
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _destinationController,
                  decoration: InputDecoration(hintText: 'Search By City'),
                  onChanged: (value) {
                    print(value);
                  },
                ),
              ),
            ],
          ),
          Expanded(
            child: GoogleMap(
              // markers: {_kGooglePlexMarker},
              polylines: _polylines,
              markers: _markers,
              mapType: MapType.hybrid,
              initialCameraPosition: _kGooglePlex,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              onTap: (point) {
                setState(() {
                  polygonLatLngs.add(point);
                  _setPolygon();
                });
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: Text('To the lake!'),
        icon: Icon(Icons.directions_boat),
      ),
    );
  }

  Future<void> _goToPlace(
    double lat,
    double lng,
    Map<String, dynamic> boundsNe,
    Map<String, dynamic> boundsSw,
  ) async {
    // final double lat = place['geometry']['location']['lat'];
    // final double lng = place['geometry']['location']['lng'];

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 12)));
    controller.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
            southwest: LatLng(boundsSw['lat'], boundsSw['lng']),
            northeast: LatLng(boundsNe['lat'], boundsNe['lng'])),
        25));
    _setMarker(LatLng(lat, lng));
  }
}
