import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Datafiles/Drawer.dart';
import 'Datafiles/appbar.dart';
import 'package:http/http.dart' as http;

import 'Datafiles/getIp.dart';

class MyAssignments extends StatefulWidget {
  getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String stringValue = prefs.getString('token');
    return stringValue;
  }

  final ip = getIp();
  @override
  _MyAssignmentsState createState() => _MyAssignmentsState();
}

class _MyAssignmentsState extends State<MyAssignments> {
  List servicerequestoffers = [];
  final _formKey = GlobalKey<FormState>();
  var data;
  var pagesize = 5;
  var pageNumber = 0;
  var totalElements;
  JsonEncoder encoder;
  String respPrint;
  bool showMsg = false;
  getRequest() async {
    await http.get(
      "${widget.ip}/bid?status=%7BAccepted,SPAwaited%7D&pageNumber=${pageNumber}&pageSize=${pagesize}&sortDirection=ASC&sortField=servicerequestid",
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

  getput(serviceRequestofferId, serviceRequestId) async {
    Map data = {
      'servicerequestofferid': "${serviceRequestofferId}",
      'status': 'Accepted',
      'servicerequest': {
        'servicerequestid': "${serviceRequestId}",
      },
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
              print(response.statusCode),
              if (response.statusCode == 200)
                {
                  print(response.body),
                  print(response.statusCode),
                }
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
                        "My Assignments",
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
                              "Service Type:${servicerequestoffers[i]["servicename"]}"),
                          Text(
                              "Bid Status:${servicerequestoffers[i]["servicerequeststatus"]}"),
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                FlatButton(
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                    child: Text('Accept'),
                                  ),
                                  onPressed: servicerequestoffers[i]
                                              ["servicerequeststatus"] ==
                                          'OfferedToSP'
                                      ? () {
                                          getput(
                                              servicerequestoffers[i]
                                                  ["servicerequestofferid"],
                                              servicerequestoffers[i]
                                                  ["servicerequestid"]);
                                        }
                                      : null,
                                ),
                              ],
                            ),
                          ),
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
                "You don't have Assignments!",
                style: TextStyle(color: Colors.black, fontSize: 20),
              ),
            ),
    );
  }
}
