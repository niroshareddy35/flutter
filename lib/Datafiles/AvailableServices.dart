import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import './getIp.dart';

class AvailableServices extends StatefulWidget {
  final ip = getIp();
  List result = [];
  List indexes = [];
  List services = [];
  List availableServices = [];
  getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String stringValue = prefs.getString('token');
    return stringValue;
  }

  getRequest() async {
    return (availableServices.length == 0
        ? await getServices()
        : availableServices);
  }

  getServices() async {
    print("rdrdtr");
    var url = '${this.ip}/service';
    availableServices = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
    ).then((response) {
      print(response.statusCode);
      if (response.statusCode == 200) {
        result = json.decode(response.body);
        return parentServicesIndex(json.decode(response.body));
      }
    });
    return availableServices;
  }

  parentServicesIndex(res) {
    if (res.length > 0) {
      for (var i = 0; i < res.length; i++) {
        for (var j = 0; j < res.length; j++) {
          if (res[i]["serviceid"] == res[j]["parentid"]) {
            indexes = [...indexes, i];
          }
        }
      }
    }
    indexes = indexes.toSet().toList();
    for (var i in indexes) {
      var res = [...result];
      res.removeAt(i);
      services = [...services, res];
    }
    final commonElements = [
      ...services.fold<Set>(
          services.first.toSet(), (a, b) => a.intersection(b.toSet()))
    ];
    return commonElements;
  }

  @override
  _AvailableServicesState createState() => _AvailableServicesState();
}

class _AvailableServicesState extends State<AvailableServices> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
