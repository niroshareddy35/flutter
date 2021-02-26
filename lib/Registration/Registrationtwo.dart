import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphene/Datafiles/appbar.dart';
import 'package:graphene/Datafiles/getIp.dart';

import 'package:graphene/Home.dart';
import '../Datafiles/Drawer.dart';
import 'RegistrationThree.dart';
import 'file:///C:/Users/ARKUser1/AndroidStudioProjects/graphene/lib/Login/Login.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegistrationTwo extends StatefulWidget {
  var profile;
  var services;
  RegistrationTwo({Key key, this.profile, this.services}) : super(key: key);

  final ip = getIp();
  getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String stringValue = prefs.getString('token');
    return stringValue;
  }

  @override
  _RegistrationTwoState createState() => _RegistrationTwoState();
}

class _RegistrationTwoState extends State<RegistrationTwo> {
  var token;
  var resp1 = "";
  int _value;
  int _value1;
  final _formKey = GlobalKey<FormState>();
  String addresstype;
  final addressline1 = TextEditingController();
  final addressline2 = TextEditingController();
  final city = TextEditingController();
  final state = TextEditingController();
  final zip = TextEditingController();
  final country = TextEditingController();
  String longitude;
  String latitude;
  String usertype;
  final geoKey = "AIzaSyDWXB7pLY_ubdVDvG1vvD9oNshbUQ9qn80";

  geoCoding() async {
    await http
        .get(
            'https://maps.googleapis.com/maps/api/geocode/json?address=${addressline1.text},${addressline2.text},${city.text},${state.text},${country.text},+CA&key=$geoKey')
        .then((response) => json.decode(response.body))
        .then((data) => {
              print(data),
              print(data["results"][0]["geometry"]["location"]["lat"]),
              print(data["results"][0]["geometry"]["location"]["lng"]),
              setState(() => {
                    latitude =
                        "${data["results"][0]["geometry"]["location"]["lat"]}",
                    longitude =
                        "${data["results"][0]["geometry"]["location"]["lng"]}",
                  }),
            });
  }

  postRequest() async {
    var url = "${widget.ip}/user/address";
    List<Map<String, String>> data = [
      {
        'addresstype': "${addresstype}",
        'addressline1': "${addressline1.text}",
        'addressline2': "${addressline2.text}",
        'city': "${city.text}",
        'state': "${state.text}",
        'zip': "${zip.text}",
        'country': "${country.text}",
        'longitude': "${longitude}",
        'latitude': "${latitude}"
      }
    ];
    String body = json.encode(data);
    widget.getToken().then((response) => print(response));

    await http
        .post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await widget.getToken()}',
      },
      body: body,
    )
        .then((response) {
      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        widget.profile != "profile"
            ? registerUsertype
            : Navigator.pushNamed(context, '/profile');

        print(response.statusCode);
      }
    });
  }

  registerUsertype() async {
    var body = {
      'usertype': "$usertype",
    };
    // print(body);
    post("${widget.ip}/user", headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${await widget.getToken()}',
    }).then((response) => {
          if (response.statusCode == 200) print(response.statusCode),
          {
            if (usertype == 'SERVICE_PROVIDER')
              {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegistrationThree()),
                )
              }
            else
              {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Home()),
                )
              }
          }
        });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      usertype =
          widget.profile == "profile" ? "SERVICE_PROVIDER" : "SERVICE_CONSUMER";
    });
    // geoCoding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ReusableWidgets.getAppBar(context, "show"),
      drawer: ReusableWidgetsSideBar.sideBar(context),
      body: Form(
        key: _formKey,
        child: ListView(scrollDirection: Axis.vertical, children: <Widget>[
          Column(children: <Widget>[
            widget.profile != "profile"
                ? Container(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        "USER REGISTRATION",
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
                    ),
                  )
                : Container(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        "Contact Deatils",
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
                    ),
                  ),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width * 0.35,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                        decoration: BoxDecoration(border: Border.all()),
                        child: DropdownButtonFormField(
                          decoration: InputDecoration(labelText: 'adresstype'),
                          value: _value,
                          items: [
                            DropdownMenuItem(
                              child: Text("home"),
                              value: 1,
                            ),
                            DropdownMenuItem(
                              child: Text("WorkPlace"),
                              value: 2,
                            ),
                            DropdownMenuItem(
                              child: Text("Other"),
                              value: 3,
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              value == 1
                                  ? addresstype = "Home"
                                  : value == 2
                                      ? addresstype = "Work"
                                      : addresstype = "other";
                            });
                          },
                          validator: (value) =>
                              value == null ? 'Please select adresstype' : null,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: TextFormField(
                        controller: addressline1,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Adressline1*'),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'enter adressline';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: TextFormField(
                        controller: addressline2,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Adressline2'),
                      ),
                    ),
                  ),
                ]),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width * 0.45,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        controller: city,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(), labelText: 'City*'),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'plz enter city';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.45,
                      child: TextFormField(
                        controller: state,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(), labelText: 'state*'),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'plz enter state';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ]),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width * 0.45,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        controller: country,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Country*'),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'plz enter country';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.45,
                      child: TextFormField(
                        controller: zip,
                        onTap: () => geoCoding(),
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Zip/Pincode*'),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'enter pincode';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ]),
            widget.profile != "profile"
                ? Container(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(4, 10, 4, 0),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          padding:
                              const EdgeInsets.only(left: 10.0, right: 10.0),
                          decoration: BoxDecoration(border: Border.all()),
                          child: DropdownButtonFormField(
                              decoration: InputDecoration(
                                  labelText:
                                      'Do you want to register as a service provider'),
                              value: _value1,
                              items: [
                                DropdownMenuItem(
                                  child: Text("yes"),
                                  value: 1,
                                ),
                                DropdownMenuItem(
                                  child: Text("no"),
                                  value: 2,
                                ),
                              ],
                              onChanged: (value) {
                                setState(() => {
                                      if (value == 1)
                                        {
                                          setState(() =>
                                              {usertype = "SERVICE_PROVIDER"}),
                                        }
                                      else
                                        {
                                          setState(() =>
                                              {usertype = "SERVICE_CONSUMER"}),
                                        }
                                    });
                              }),
                        ),
                      ),
                    ),
                  )
                : Container(),
            Container(
              child: FlatButton(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Text('SAVE'),
                  ),
                  onPressed: () {
                    print(usertype);
                    addresstype == '' ||
                            addressline1.text == '' ||
                            city.text == '' ||
                            state.text == '' ||
                            country.text == '' ||
                            usertype == '' ||
                            zip.text == ''
                        ? null
                        : postRequest();
                    if (!_formKey.currentState.validate()) ;
                  }),
            ),
          ]),
        ]),
      ),
    );
  }
}
