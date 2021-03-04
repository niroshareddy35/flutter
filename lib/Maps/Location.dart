import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:graphene/Datafiles/getIp.dart';
import 'package:location/location.dart';
import 'package:permission/permission.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Location extends StatefulWidget {
  final ip = getIp();
  getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String stringValue = prefs.getString('token');
    return stringValue;
  }

  @override
  _LocationState createState() => _LocationState();
}

class _LocationState extends State<Location> {
  List serviceProviders = [];
  var data;

  Completer<GoogleMapController> _controller = Completer();
  static final CameraPosition _myLocation = CameraPosition(
    target: LatLng(17.4062, 78.3763),
    zoom: 12,
  );

  getPost() async {
    JsonEncoder encoder;
    String respPrint;
    await http
        .get(
          "${widget.ip}/serviceprovider?filter=web&pageNumber=0&pageSize=20&sortColumn=fname&sortOrder=ASC",
        )
        .then((response) => {
              print(response.body),
              print(response.statusCode),
              data = jsonDecode(response.body),
              print(response.statusCode),
              encoder = new JsonEncoder.withIndent('  '),
              respPrint = encoder.convert(data),
              respPrint.split('\n').forEach((element) => print(element)),
              if (response.statusCode == 200)
                {
                  setState(() {
                    serviceProviders = data["serviceproviders"]["content"];
                  }),
                }
            });
  }

  @override
  void initState() {
    super.initState();
    getPost();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
        initialCameraPosition: _myLocation,
        myLocationEnabled: true,
        mapType: MapType.normal,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: {
          for (int i = 0; i < serviceProviders.length; i++)
            Marker(
                markerId: MarkerId(
                    serviceProviders[i]["serviceproviderid"].toString()),
                position: LatLng(serviceProviders[i]["latitude"],
                    serviceProviders[i]["longitude"]),
                onTap: () {})
        });
  }
}
