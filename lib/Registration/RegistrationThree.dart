import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphene/Datafiles/appbar.dart';
import '../Datafiles/AvailableServices.dart';
import 'package:graphene/Home.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Datafiles/getIp.dart';
import '../Datafiles/Drawer.dart';

class RegistrationThree extends StatefulWidget {
  var profile1;
  var jobtitle1;
  RegistrationThree({Key key, this.profile1, this.jobtitle1}) : super(key: key);
  final services = AvailableServices();
  s1() async {
    return await services.getRequest();
  }

  final ip = getIp();
  getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String stringValue = prefs.getString('token');
    return stringValue;
  }

  @override
  _RegistrationThreeState createState() => _RegistrationThreeState();
}

class _RegistrationThreeState extends State<RegistrationThree> {
  bool validerror = true;
  final ip = getIp();
  var token;
  int _value;
  int _value1;
  int _value2;
  int _value3;
  List availableServices = [];
  bool addDeatils = true;
  bool showDeatils = false;
  bool remansDatails = false;
  final _formKey = GlobalKey<FormState>();
  final jobtitle = TextEditingController();
  final experiencelevel = TextEditingController();
  final hourlyrate = TextEditingController();
  final yearofexperience = TextEditingController();
  final serviceid = TextEditingController();
  String paymentrecieptmethodid = "1";
  var jobtitle2;
  var userServices = {
    'experiencelevel': "",
    'hourlyrate': "",
    'yearofexperience': "",
    'currency': "",
    'serviceid': "",
  };
  List serviceoffered = [];
  postRequest() async {
    var url = "${widget.ip}/user/service";
    Map data = {
      "jobTitle":
          "${widget.profile1 != "profile1" ? jobtitle.text : jobtitle2}",
      "userServices": [
        {...userServices}
      ],
      "paymentReceiptMethodId": "${paymentrecieptmethodid}"
    };
    print(data);
    // print(data["jobTitle"].runtimeType);
    // print(data["userServices"].runtimeType);
    //
    // print(data["paymentReceiptMethodId"].runtimeType);

    String body = json.encode(data);
    print(body);

    await http
        .post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${token}',
      },
      body: body,
    )
        .then((response) {
      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
      } else {
        setState(() {
          _showMyDialog();
        });
      }
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      jobtitle2 = widget.profile1 == "profile1" ? widget.jobtitle1 : "";
    });
    widget.s1().then((response) => setState(() {
          availableServices = response;
        }));
    widget.getToken().then((response) => setState(() {
          token = response;
        }));
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      //this means the user must tap a button to exit the Alert Dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('AlertDialog Title'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Already registered with same serviceid'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Go Out'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ReusableWidgets.getAppBar(context, "show"),
      drawer: ReusableWidgetsSideBar.sideBar(context),
      body: Form(
        key: _formKey,
        child: ListView(
          scrollDirection: Axis.vertical,
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.all(20.0),
                child: widget.profile1 != "profile1"
                    ? Container(
                        alignment: Alignment.center,
                        child: Text(
                          "USER REGISTRATION",
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        ),
                      )
                    : Container(
                        alignment: Alignment.center,
                        child: Text(
                          "Add More Services",
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        ),
                      )),
            addDeatils
                ? Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: <Widget>[
                          Container(
                            child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                      Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.45,
                                          child: availableServices.length > 0
                                              ? Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10.0,
                                                          right: 10.0),
                                                  // decoration: BoxDecoration(border: Border.all()),
                                                  child:
                                                      DropdownButtonFormField(
                                                    decoration: InputDecoration(
                                                        border:
                                                            OutlineInputBorder(),
                                                        labelText:
                                                            'Service Offer*'),
                                                    value: _value1,
                                                    items: [
                                                      for (var i
                                                          in availableServices)
                                                        DropdownMenuItem(
                                                          child:
                                                              Text(i["name"]),
                                                          value: i["serviceid"],
                                                        )
                                                    ],
                                                    onChanged: (value) {
                                                      print(value.runtimeType);
                                                      setState(() => {
                                                            userServices = {
                                                              ...userServices,
                                                              "serviceid": value
                                                                  .toString()
                                                            },
                                                            _value1 = value,
                                                          });
                                                    },
                                                    validator: (value) => value ==
                                                            null
                                                        ? 'select serviece id'
                                                        : validerror == false
                                                            ? "service already  registered "
                                                            : null,
                                                  ),
                                                )
                                              : null),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.42,
                                          child: Container(
                                            padding: const EdgeInsets.only(
                                                left: 10.0, right: 10.0),
                                            // decoration: BoxDecoration(border: Border.all()),
                                            child: DropdownButtonFormField(
                                              decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  labelText: 'Seniority Level'),
                                              value: _value2,
                                              items: [
                                                DropdownMenuItem(
                                                  child: Text("Senior"),
                                                  value: 1,
                                                ),
                                                DropdownMenuItem(
                                                  child: Text("Junior"),
                                                  value: 2,
                                                ),
                                                DropdownMenuItem(
                                                  child: Text("Beginner"),
                                                  value: 3,
                                                ),
                                              ],
                                              onChanged: (value) {
                                                setState(() => {
                                                      userServices = {
                                                        ...userServices,
                                                        if (value == 1)
                                                          "experiencelevel":
                                                              "Senior"
                                                        else if (value == 2)
                                                          "experiencelevel":
                                                              "Junior"
                                                        else
                                                          "experiencelevel":
                                                              "Beginner"
                                                      },
                                                      _value2 = value,
                                                    });
                                              },
                                              validator: (value) =>
                                                  value == null
                                                      ? ' select senority type'
                                                      : null,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ]))),
                          ),
                          Container(
                              child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.45,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: TextFormField(
                                                  controller: hourlyrate,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  inputFormatters: <
                                                      TextInputFormatter>[
                                                    FilteringTextInputFormatter
                                                        .allow(
                                                            RegExp(r'[0-9]')),
                                                  ],
                                                  decoration: InputDecoration(
                                                      border:
                                                          OutlineInputBorder(),
                                                      labelText:
                                                          'Hourly Rate*'),
                                                  validator: (value) {
                                                    if (value.isEmpty) {
                                                      return ' enter hourlyrate';
                                                    }
                                                    return null;
                                                  },
                                                  onChanged: (value) {
                                                    setState(
                                                        () => userServices = {
                                                              ...userServices,
                                                              "hourlyrate": value
                                                                  .toString(),
                                                            });
                                                  },
                                                ),
                                              )),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.42,
                                              child: Container(
                                                padding: const EdgeInsets.only(
                                                    left: 10.0, right: 10.0),
                                                // decoration:
                                                //     BoxDecoration(border: Border.all()),
                                                child: TextFormField(
                                                  controller: yearofexperience,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  inputFormatters: <
                                                      TextInputFormatter>[
                                                    FilteringTextInputFormatter
                                                        .allow(
                                                            RegExp(r'[0-9]')),
                                                  ],
                                                  decoration: InputDecoration(
                                                      border:
                                                          OutlineInputBorder(),
                                                      labelText:
                                                          'Year Of Experience*'),
                                                  validator: (value) {
                                                    if (value.isEmpty) {
                                                      return ' enter year of experience';
                                                    }
                                                    return null;
                                                  },
                                                  onChanged: (value) {
                                                    setState(() =>
                                                        userServices = {
                                                          ...userServices,
                                                          "yearofexperience":
                                                              value.toString(),
                                                        });
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ]),
                                  ))),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: DropdownButtonFormField(
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Currency'),
                              value: _value3,
                              items: [
                                DropdownMenuItem(
                                  child: Text("INR"),
                                  value: 1,
                                ),
                                DropdownMenuItem(
                                  child: Text("USD"),
                                  value: 2,
                                ),
                              ],
                              onChanged: (value) {
                                setState(() => {
                                      userServices = {
                                        ...userServices,
                                        if (value == 1)
                                          "currency": "INR"
                                        else
                                          "currency": "USD"
                                      },
                                      _value3 = value,
                                    });
                              },
                              validator: (value) =>
                                  value == null ? ' select currency' : null,
                            ),
                          ),
                          Container(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: FlatButton(
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                    child: Text('Next'),
                                  ),
                                  onPressed: () {
                                    serviceid == '' ||
                                            yearofexperience.text == '' ||
                                            experiencelevel == '' ||
                                            hourlyrate.text == ''
                                        ? null
                                        : setState(() {
                                            serviceoffered = [
                                              ...serviceoffered,
                                              userServices
                                            ];
                                            addDeatils = false;
                                            showDeatils = true;
                                          });
                                    if (!_formKey.currentState.validate()) ;
                                    print(userServices);
                                  }),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                : Container(),
            showDeatils
                ? Container(
                    width: 400,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 10,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (var i in serviceoffered)
                              Container(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Experience Level: ${i["experiencelevel"]}",
                                    ),
                                    Text("Hourly Rate: ${i["hourlyrate"]}"),
                                    Text(
                                        "years of Experience: ${i["yearofexperience"]}"),
                                    Text("Service id: ${i["serviceid"]}"),
                                    Text("currency:${i["currency"]}"),
                                  ],
                                ),
                              ),
                            Container(
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    FlatButton(
                                      child: const Text(
                                        'Add More Services',
                                      ),
                                      textColor: Colors.green,
                                      onPressed: () {
                                        setState(() {
                                          userServices = {
                                            'experiencelevel': "",
                                            'hourlyrate': "",
                                            'yearofexperience': "",
                                            'serviceid': "",
                                            'currency': "",
                                          };
                                          addDeatils = true;
                                          showDeatils = false;
                                        });
                                      },
                                    ),
                                    FlatButton(
                                      child: const Text(
                                        'Continue',
                                      ),
                                      textColor: Colors.green,
                                      onPressed: () {
                                        setState(() {
                                          remansDatails = true;
                                          // showDeatils = false;
                                        });
                                      },
                                    ),
                                  ]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : Container(),
            remansDatails
                ? Container(
                    child: Column(
                      children: [
                        widget.profile1 != "profile1"
                            ? Container(
                                child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Container(
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.6,
                                              child: TextFormField(
                                                  controller: jobtitle,
                                                  decoration: InputDecoration(
                                                      border:
                                                          OutlineInputBorder(),
                                                      labelText: 'Jobtitle*')),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(20.0),
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.6,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10.0,
                                                          right: 10.0),
                                                  decoration: BoxDecoration(
                                                      border: Border.all()),
                                                  child:
                                                      DropdownButtonFormField(
                                                          decoration:
                                                              InputDecoration(
                                                                  labelText:
                                                                      'preferred paymentreciept method'),
                                                          value: _value,
                                                          items: [
                                                            DropdownMenuItem(
                                                              child: Text(
                                                                  "bankaccount"),
                                                              value: 1,
                                                            ),
                                                            DropdownMenuItem(
                                                              child: Text(
                                                                  "paypal"),
                                                              value: 2,
                                                            ),
                                                          ],
                                                          onChanged: (value) {
                                                            setState(() {
                                                              paymentrecieptmethodid =
                                                                  value
                                                                      .toString();
                                                            });
                                                          }),
                                                ),
                                              ),
                                            ),
                                          ]),
                                    )))
                            : Container(),
                        Container(
                          child: FlatButton(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                child: Text('SAVE'),
                              ),
                              onPressed: () {
                                // if (!_formKey.currentState.validate()) ;

                                postRequest();
                              }),
                        ),
                      ],
                    ),
                  )
                : Container(
                    height: 0,
                  ),
          ],
        ),
      ),
    );
  }
}
