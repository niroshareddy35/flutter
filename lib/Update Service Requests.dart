import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'file:///C:/Users/ARKUser1/AndroidStudioProjects/graphene/lib/Service%20Requests/CreateService.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Datafiles/Drawer.dart';
import 'Datafiles/appbar.dart';
import 'package:http/http.dart' as http;

import 'Datafiles/getIp.dart';

class UpdateServiceRequest extends StatefulWidget {
  var serviceRequestId;
  var serviceRequestDetails;
  UpdateServiceRequest({
    Key key,
    this.serviceRequestId,
  }) : super(key: key);

  getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String stringValue = prefs.getString('token');
    return stringValue;
  }

  final ip = getIp();
  var serviceRequestById;
  serviceId(serviceRequestId) async {
    return await getRequest(serviceRequestId);
  }

  getRequest(serviceRequestId) async {
    print("this is service request id${serviceRequestId}");
    serviceRequestById = await http.get(
      "${this.ip}/servicerequest/${serviceRequestId}",
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await this.getToken()}'
      },
    ).then((response) {
      print(response.statusCode);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    });
    return serviceRequestById;
  }

  @override
  _UpdateServiceRequestState createState() => _UpdateServiceRequestState();
}

class _UpdateServiceRequestState extends State<UpdateServiceRequest> {
  final _formKey = GlobalKey<FormState>();
  var data;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
