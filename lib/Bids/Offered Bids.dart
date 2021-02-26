import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Datafiles/Drawer.dart';
import '../Datafiles/appbar.dart';
import 'package:http/http.dart' as http;

import '../Datafiles/getIp.dart';
import 'package:intl/intl.dart';

class OfferedBids extends StatefulWidget {
  var serviceRequestId;
  OfferedBids({
    Key key,
    this.serviceRequestId,
  }) : super(key: key);
  getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String stringValue = prefs.getString('token');
    return stringValue;
  }

  final ip = getIp();
  @override
  _OfferedBidsState createState() => _OfferedBidsState();
}

class _OfferedBidsState extends State<OfferedBids> {
  var data;
  var pagesize = 5;
  var pageNumber = 0;
  var totalElements;
  List servicerequestoffers = [];
  final _formKey = GlobalKey<FormState>();
  getRequest() async {
    JsonEncoder encoder;
    String respPrint;
    var filterid;
    await http.get(
      '${widget.ip}/servicerequestoffer?pageSize=${pagesize}&pageNumber=${pageNumber}${widget.serviceRequestId != null ? '&servicerequestid=${widget.serviceRequestId}' : ''}&sortField=created_at&sortDirection=DESC',
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
          if (response.statusCode == 200)
            {
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
                  getRequest(),
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
        body: Form(
            key: _formKey,
            child: ListView(scrollDirection: Axis.vertical, children: <Widget>[
              Column(children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      "Offered Bids",
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
                            "Bid Type:${servicerequestoffers[i]["offertype"]}"),
                        Text(
                            "Bid Status:${servicerequestoffers[i]["offerstatus"]}"),
                        Text(
                            "Price:${servicerequestoffers[i]["currency"]}${servicerequestoffers[i]["offerprice"]}"),
                        Text(
                            "Service Provider:${servicerequestoffers[i]["fname"]}${servicerequestoffers[i]["mname"]}${servicerequestoffers[i]["lname"]}"),
                        Text(
                            "date:${DateFormat("yy-MM-dd").format(DateTime.parse(servicerequestoffers[i]["created_at"]))}"),
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
                                            ["offerstatus"] ==
                                        'Offered'
                                    ? () {
                                        getput(
                                            servicerequestoffers[i]
                                                ["servicerequestofferid"],
                                            servicerequestoffers[i]
                                                ["servicerequestid"]);
                                      }
                                    : null,
                              ),
                              // IconButton(
                              //   icon: Icon(Icons.edit),
                              //   color: Colors.black,
                              //   onPressed: () {},
                              // ),
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
            ])));
  }
}
