import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Datafiles/Drawer.dart';
import '../Datafiles/appbar.dart';
import 'package:http/http.dart' as http;
import '../Datafiles/getIp.dart';
import 'package:intl/intl.dart';

class MyBids extends StatefulWidget {
  getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String stringValue = prefs.getString('token');
    return stringValue;
  }

  final ip = getIp();
  @override
  _MyBidsState createState() => _MyBidsState();
}

class _MyBidsState extends State<MyBids> {
  var offerprice = TextEditingController();
  int selectCurrency;
  int selectOfferType;
  String Currency;
  String OfferType;
  final _formKey = GlobalKey<FormState>();
  var filterid;
  JsonEncoder encoder;
  String respPrint;
  var data;
  var servicerequestid;
  List servicerequestoffers = [];
  var pagesize = 5;
  var pageNumber = 0;
  var totalElements;
  var showMsg = false;

  getRequest() async {
    await http.get(
      "${widget.ip}/bid?pageSize=${pagesize}&pageNumber=${pageNumber}&sortField=created_at&sortDirection=DESC",
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await widget.getToken()}'
      },
    ).then((response) => {
          data = jsonDecode(response.body),
          print(response.statusCode),

          encoder = new JsonEncoder.withIndent('  '),
          respPrint = encoder.convert(data),
          respPrint.split('\n').forEach((element) => print(element)),
          // print(response.statusCode),
          // print(response.body),
          if (response.statusCode == 200)
            {
              data["servicerequestoffers"].length == 0
                  ? setState(() {
                      showMsg = true;
                    })
                  : servicerequestoffers = data["servicerequestoffers"],
              totalElements = data["totalelements"],
              setState(() {
                servicerequestoffers = data["servicerequestoffers"];
              })
            }
        });
  }

  Future<void> _showMyDialog(serviceRequestOfferId, serviceRequestId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      //this means the user must tap a button to exit the Alert Dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: Padding(
            padding: const EdgeInsets.only(left: 50.0),
            child: Text(
              'Offer Service',
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      child: DropdownButtonFormField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Currency*'),
                          value: selectCurrency,
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
                                  if (value == 1)
                                    Currency = "INR"
                                  else
                                    Currency = "USD"
                                });
                          }),

                      // _currency = value;
                    )),
                Container(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      controller: offerprice,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Offer Price*'),
                    ),
                  ),
                ),
                Container(
                    child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: DropdownButtonFormField(
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Offer Type*'),
                      value: selectOfferType,
                      items: [
                        DropdownMenuItem(
                          child: Text("Fixed"),
                          value: 1,
                        ),
                        DropdownMenuItem(
                          child: Text("Hourly"),
                          value: 2,
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => {
                              if (value == 1)
                                OfferType = "Fixed"
                              else
                                OfferType = "Hourly"
                            });
                      }),
                )),
              ],
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 100.0),
              child: FlatButton(
                child: Text('SAVE'),
                onPressed: () {
                  getPut(serviceRequestOfferId, serviceRequestId);
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  getPut(serviceRequestOfferId, serviceRequestId) async {
    Map data = {
      'currency': "${Currency}",
      'offerprice': "${offerprice.text}",
      'offertype': "${OfferType}",
      'servicerequest': {
        'servicerequestid': serviceRequestId,
      },
      "servicerequestofferid": serviceRequestOfferId
    };
    print(data);
    String body = json.encode(data);
    http
        .put("${widget.ip}/servicerequestoffer",
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${await widget.getToken()}',
            },
            body: body)
        .then((response) => {
              if (response.statusCode == 200)
                {print(response.body), print(response.statusCode), getRequest()}
            });
  }

  @override
  void initState() {
    super.initState();
    getRequest();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ReusableWidgets.getAppBar(context, "show"),
      drawer: ReusableWidgetsSideBar.sideBar(context),
      body: !showMsg
          ? Form(
              key: _formKey,
              child:
                  ListView(scrollDirection: Axis.vertical, children: <Widget>[
                Column(children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        "My Bids",
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
                    ),
                  ),
                ]),
                for (var i = 0; i < servicerequestoffers.length; i++)
                  Column(mainAxisSize: MainAxisSize.min, children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              "Title:${servicerequestoffers[i]["servicerequesttitle"]}"),
                          Text(
                              "Description:${servicerequestoffers[i]["servicerequestdescription"]}"),
                          Text(
                              "Price:${servicerequestoffers[i]["currency"]}${servicerequestoffers[i]["offerprice"]}"),
                          Text(
                              "Bid Type:${servicerequestoffers[i]["offertype"]}"),
                          Text(
                              "Bid Status:${servicerequestoffers[i]["servicerequeststatus"]}"),
                          Text(
                              "date:${DateFormat("yy-MM-dd").format(DateTime.parse(servicerequestoffers[i]["created_at"]))}"),
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  color: Colors.black,
                                  onPressed: servicerequestoffers[i]
                                              ["servicerequeststatus"] !=
                                          'BidAccepted'
                                      ? () {
                                          _showMyDialog(
                                              servicerequestoffers[i]
                                                  ["servicerequestofferid"],
                                              servicerequestoffers[i]
                                                  ["servicerequestid"]);
                                        }
                                      : null,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ]),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: FlatButton(
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                    child: Text('Previous'),
                                  ),
                                  onPressed: () {
                                    pageNumber > 0
                                        ? {
                                            setState(() {
                                              pageNumber = pageNumber - 1;
                                            }),
                                            getRequest()
                                          }
                                        : null;
                                  })),
                        ),
                        Container(
                            width: MediaQuery.of(context).size.width * 0.52,
                            child: FlatButton(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                child: Text('Next'),
                              ),
                              onPressed: () {
                                (pageNumber + 1) * pagesize >= totalElements
                                    ? null
                                    : {
                                        setState(() {
                                          pageNumber = pageNumber + 1;
                                        }),
                                        getRequest()
                                      };
                              },
                            ))
                      ]),
                ),
              ]))
          : Container(
              alignment: Alignment.center,
              child: Text(
                "You don't have any bids",
                style: TextStyle(color: Colors.black, fontSize: 20),
              ),
            ),
    );
  }
}
