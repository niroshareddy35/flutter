import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Datafiles/Drawer.dart';
import '../Datafiles/appbar.dart';
import 'package:http/http.dart' as http;
import '../Datafiles/getIp.dart';

class WorkOrderQueue extends StatefulWidget {
  getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String stringValue = prefs.getString('token');
    return stringValue;
  }

  final ip = getIp();
  @override
  _WorkOrderQueueState createState() => _WorkOrderQueueState();
}

class _WorkOrderQueueState extends State<WorkOrderQueue> {
  bool validMsg = true;
  var offerprice = TextEditingController();
  int selectCurrency;
  int selectOfferType;
  String Currency;
  String OfferType;
  List serviceRequests = [];
  List attachments;
  List serviceproviderdeatils;
  var data;
  var serviceRequestId;
  var idInAttachments;
  var atchs;
  var services;
  var pagesize = 5;
  var pageNumber = 0;
  var totalElements;
  Map<String, dynamic> atchIncluded;
  Map<String, dynamic> spIncluded;
  JsonEncoder encoder;
  String respPrint;
  final _formKey = GlobalKey<FormState>();
  bool showMsg = false;

  Future<void> _MyDialog() async {
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
                Text(
                    "An offer made by you already exists! You can't make another offer on the same service request! Instead you can edit the bid in MyBids section"),
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

  Future<void> _showMyDialog(serviceRequestId) async {
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
                  getPost(serviceRequestId);
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  getPost(serviceRequestId) async {
    Map data = {
      'currency': "${Currency}",
      'offerprice': "${offerprice.text}",
      'offertype': "${OfferType}",
      'servicerequest': {
        "servicerequestid": "${serviceRequestId}",
      },
    };
    print(data);
    String body = json.encode(data);
    http
        .post("${widget.ip}/servicerequestoffer",
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${await widget.getToken()}',
            },
            body: body)
        .then((response) => {
              print(response.statusCode),
              if (response.statusCode == 200)
                {
                  print(response.body),
                  print(response.statusCode),
                  setState(() {
                    getRequest();
                  })
                }
              else
                {
                  setState(() {
                    _MyDialog();
                  })
                }
            });
  }

  getRequest() async {
    await http.get(
      "${widget.ip}/servicerequest?filter=all&pageNumber=${pageNumber}&pageSize=${pagesize}&sortDirection=ASC&sortField=servicerequestid&status=%7BOpen,OpenOffered%7D",
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
          // respPrint.split('\n').forEach((element) => print(element)),
          print(response.statusCode),
          if (response.statusCode == 200)
            {
              data["servicerequests"].length == 0
                  ? setState(() {
                      showMsg = true;
                    })
                  : serviceRequests = data["servicerequests"],
              totalElements = data["totalelements"],

              data["attachments"].forEach((i, j) => attachments = [
                    ...attachments,
                    {"$i": "$j"}
                  ]),
              for (var i = 0; i < serviceRequests.length; i++)
                {
                  for (var j = 0; j < attachments.length; j++)
                    {
                      attachments[j].forEach((i, j) => setState(() {
                            idInAttachments = i;
                            atchs = j;
                          })),
                      if (idInAttachments ==
                          serviceRequests[i]["servicerequestid"].toString())
                        setState(() {
                          atchIncluded = {
                            ...serviceRequests[i],
                            "attachments": atchs
                          };
                          serviceRequests[i] = atchIncluded;
                        }),
                    },
                },
              // encoder = new JsonEncoder.withIndent('  '),
              // respPrint = encoder.convert(serviceRequests),
              // respPrint.split('\n').forEach((element) => print(element)),
            },
          serviceproviderdeatils = data["serviceproviderdetails"],
          for (var i = 0; i < serviceRequests.length; i++)
            {
              for (var j = 0; j < serviceproviderdeatils.length; j++)
                {
                  if (serviceRequests[i]["servicerequestid"] ==
                      serviceproviderdeatils[j]["servicerequestid"])
                    print('matched'),
                  setState(() {
                    spIncluded = {
                      ...serviceRequests[i],
                      "serviceproviderdetails": serviceproviderdeatils[j]
                    };
                    serviceRequests[i] = spIncluded;
                  }),
                },
            },
          encoder = new JsonEncoder.withIndent('  '),
          respPrint = encoder.convert(serviceRequests),
          // respPrint.split('\n').forEach((element) => print(element)),
          // print(jsonDecode(serviceRequests[0]["attachments"]).runtimeType),
          print(data["servicerequests"].runtimeType)
        });
  }

  @override
  void initState() {
    super.initState();
    attachments = [];
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
                          "Work Order Queue",
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        ),
                      ),
                    ),
                    for (var i = 0; i < serviceRequests.length; i++)
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Title:${serviceRequests[i]["title"]}"),
                                Text(
                                    "Description:${serviceRequests[i]["description"]}"),
                                Text("Status:${serviceRequests[i]["status"]}"),
                                Text(
                                    "Servicetype:${serviceRequests[i]["servicename"]}"),
                                Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      FlatButton(
                                          child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 10, 0, 0),
                                              child: Text('Place a Bid')),
                                          onPressed: () {
                                            _showMyDialog(serviceRequests[i]
                                                ["servicerequestid"]);
                                          }),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 10, 0, 0),
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
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 10, 0, 0),
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
                  ])
                ]))
            : Container(
                alignment: Alignment.center,
                child: Text(
                  "There are no  work orders for you",
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),
              ));
  }
}
