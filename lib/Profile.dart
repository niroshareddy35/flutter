import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphene/Datafiles/appbar.dart';
import 'package:graphene/Datafiles/getIp.dart';
import 'package:graphene/Registration/RegistrationThree.dart';
import 'package:graphene/Registration/Registrationtwo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'Datafiles/Drawer.dart';

class Profile extends StatefulWidget {
  final ip = getIp();
  getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String stringValue = prefs.getString('token');
    return stringValue;
  }

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _formKey = GlobalKey<FormState>();
  var profile1 = "profile1";
  var profile = "profile";
  var token;
  var details = [];
  var services;
  var data;
  JsonEncoder encoder;
  String respPrint;
  getServexuser() async {
    var url = '${widget.ip}/servexuser';
    await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await widget.getToken()}',
      },
    ).then((response) {
      data = jsonDecode(response.body);
      print(response.statusCode);
      encoder = new JsonEncoder.withIndent('  ');
      respPrint = encoder.convert(data);
      respPrint.split('\n').forEach((element) => print(element));

      print(response.statusCode);
      if (response.statusCode == 200) {
        setState(() {
          details = json.decode(response.body);
        });
      } else {}
    });
  }

  getuserservice() async {
    var url = '${widget.ip}/user/service';
    await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await widget.getToken()}',
      },
    ).then((response) {
      data = jsonDecode(response.body);
      print(response.statusCode);
      encoder = new JsonEncoder.withIndent('  ');
      respPrint = encoder.convert(data);
      respPrint.split('\n').forEach((element) => print(element));
      if (response.statusCode == 200) {
        setState(() {
          services = json.decode(response.body);
        });
      } else {}
    });
  }

  delete(serviceId) async {
    await http
        .delete('${widget.ip}/user/service?serviceids=${serviceId}', headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${await widget.getToken()}',
    }).then((response) => {
              // // data = jsonDecode(response.body),
              // print(response.body),
              // print(response.statusCode),
              // // encoder = new JsonEncoder.withIndent('  '),
              // // respPrint = encoder.convert(data),
              // // respPrint.split('\n').forEach((element) => print(element)),
              if (response.statusCode == 200) {getuserservice()}
            });
  }

  @override
  void initState() {
    super.initState();
    getServexuser();
    getuserservice();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: ReusableWidgets.getAppBar(context, "show"),
          drawer: ReusableWidgetsSideBar.sideBar(context),
          body: SizedBox(
            child: Scaffold(
              appBar: TabBar(
                labelColor: Colors.black,
                isScrollable: true,
                tabs: [
                  Tab(text: "Basic Details"),
                  Tab(
                    text: "Contact Details",
                  ),
                  Tab(
                    text: "Services Offered",
                  ),
                  Tab(
                    text: " Add Payment Details",
                  ),
                ],
              ),
              body: TabBarView(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: details.length > 0
                              ? Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            "First Name: ${details[0]["fname"]}"),
                                        details[0]['mname'] != ''
                                            ? Text(
                                                "Middle Name: ${details[0]['mname']}")
                                            : Container(
                                                height: 0,
                                              ),
                                        Text(
                                            "Last Name: ${details[0]["lname"]}"),
                                        Text(
                                            "Job Title:${details[0]["jobtitle"]}"),
                                        Text("Email Id:${details[0]["email"]}"),
                                      ],
                                    ),
                                  ),
                                )
                              : Container())
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: details.length > 0
                              ? Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            "Addressestype:${details[0]["addresses"][0]["addresstype"]}"),
                                        Text(
                                            "Addressesline1:${details[0]["addresses"][0]["addressline1"]}"),
                                        Text(
                                            "Addressline2:${details[0]["addresses"][0]["addressline2"]}"),
                                        Text(
                                            "City:${details[0]["addresses"][0]["city"]}"),
                                        Text(
                                            "Country:${details[0]["addresses"][0]["country"]}"),
                                        Text(
                                            "State:${details[0]["addresses"][0]["state"]}"),
                                        Text(
                                            "Zip:${details[0]["addresses"][0]["zip"]}"),
                                        Text(
                                            "Phonenumber:${details[0]["phones"][0]["phonenumber"]}"),
                                        Container(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              IconButton(
                                                icon: Icon(Icons.edit),
                                                color: Colors.black,
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            RegistrationTwo(
                                                                profile:
                                                                    profile,
                                                                services: services
                                                                    .length)),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              : Container()),
                    ],
                  ),
                  Container(
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: details.length > 0
                            ? Card(
                                child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ListView(
                                      scrollDirection: Axis.vertical,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            FlatButton(
                                              child: Text(
                                                'ADD MORE SERVICES',
                                              ),
                                              onPressed: () {
                                                // print("ser ${details[0]["jobtitle"]}");
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          RegistrationThree(
                                                            profile1: profile1,
                                                            jobtitle1: details[
                                                                0]["jobtitle"],
                                                          )),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                        for (var i in services)
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  "Experience Level:${i["experiencelevel"]}"),
                                              Text(
                                                  "Hourly rate:${i["hourlyrate"]}"),
                                              Text(
                                                  "service Id:${i["servicename"]}"),
                                              Text(
                                                  "Experience:${i["yearofexperience"]}"),
                                              Container(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    IconButton(
                                                      icon: Icon(Icons.delete),
                                                      color: Colors.black,
                                                      onPressed: () {
                                                        delete(i["serviceid"]);
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    )),
                              )
                            : Container()),
                  ),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text("PAYMENT DETAILS"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
