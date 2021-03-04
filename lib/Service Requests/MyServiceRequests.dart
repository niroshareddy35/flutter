import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphene/Chat/ChatRoom.dart';
import 'file:///C:/Users/ARKUser1/AndroidStudioProjects/graphene/lib/Service%20Requests/CreateService.dart';
import 'file:///C:/Users/ARKUser1/AndroidStudioProjects/graphene/lib/Bids/Offered%20Bids.dart';
import 'package:graphene/Update%20Service%20Requests.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Datafiles/Drawer.dart';
import '../Datafiles/appbar.dart';
import 'package:http/http.dart' as http;
import '../Datafiles/getIp.dart';

class MyServiceRequest extends StatefulWidget {
  getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String stringValue = prefs.getString('token');
    return stringValue;
  }

  final ip = getIp();
  @override
  _MyServiceRequestState createState() => _MyServiceRequestState();
}

class _MyServiceRequestState extends State<MyServiceRequest> {
  var serviceRequestId = "serviceRequestId";
  List serviceRequests = [];
  List attachments;
  List serviceproviderdeatils;
  var pagesize = 5;
  var pageNumber = 0;
  var totalElements;
  var data;
  var idInAttachments;
  var atchs;
  var services;
  Map<String, dynamic> atchIncluded;
  Map<String, dynamic> spIncluded;
  final _formKey = GlobalKey<FormState>();
  bool showMsg = false;
  getRequest() async {
    JsonEncoder encoder;
    String respPrint;
    await http.get(
      "${widget.ip}/servicerequest?pageNumber=${pageNumber}&pageSize=${pagesize}&sortDirection=ASC&sortField=servicerequestid",
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
          // print("${data["servicerequests"]}"),
          // print("${data["attachments"]}"),

          if (response.statusCode == 200)
            {
              data["servicerequests"].length == 0
                  ? setState(() {
                      showMsg = true;
                    })
                  : serviceRequests = data["servicerequests"],

              totalElements = data["totalelements"],
              serviceRequests = data["servicerequests"],
              serviceproviderdeatils = data["serviceproviderdetails"],

              data["servicerequests"].length > 0
                  ? data["attachments"].forEach((i, j) => attachments = [
                        ...attachments,
                        {"$i": "$j"}
                      ])
                  : null,
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
          // encoder = new JsonEncoder.withIndent('  '),
          // respPrint = encoder.convert(serviceRequests),
          // respPrint.split('\n').forEach((element) => print(element)),
          // print(jsonDecode(serviceRequests[0]["attachments"]).runtimeType),
          // print(data["servicerequests"].runtimeType)
        });
  }

  delete(deleteId) async {
    await http.delete('${widget.ip}/servicerequest?servicerequestids=$deleteId',
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await widget.getToken()}',
        }).then((response) => {
          print(response.statusCode),
          print(response.body),
          if (response.statusCode == 200) {getRequest()}
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
                        "MyServiceRequests",
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
                    ),
                  ),
                  if (serviceRequests.length > 0)
                    for (var i = 0; i < serviceRequests.length; i++)
                      Column(mainAxisSize: MainAxisSize.min, children: [
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
                                  "Servietype:${serviceRequests[i]["servicename"]}"),
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    FlatButton(
                                        child: Text('Chat With Provider'),
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ChatRoom()));
                                        }),
                                    FlatButton(
                                        child: Text('View Offers'),
                                        onPressed:
                                            serviceRequests[i]["status"] !=
                                                    'BidAccepted'
                                                ? () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    OfferedBids(
                                                                      serviceRequestId:
                                                                          serviceRequests[i]
                                                                              [
                                                                              "servicerequestid"],
                                                                    )));
                                                  }
                                                : null),
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      color: Colors.black,
                                      onPressed:
                                          serviceRequests[i]["status"] ==
                                                  'OpenOffered'
                                              ? () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder:
                                                              (context) =>
                                                                  CreateService(
                                                                    serviceRequestId:
                                                                        serviceRequests[i]
                                                                            [
                                                                            "servicerequestid"],
                                                                  )));
                                                }
                                              : null,
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed:
                                          serviceRequests[i]["status"] == 'Open'
                                              ? () {
                                                  delete(serviceRequests[i]
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
              ]),
            )
          : Container(
              alignment: Alignment.center,
              child: Text(
                "You haven't created any service requests!",
                style: TextStyle(color: Colors.black, fontSize: 20),
              ),
            ),
    );
  }
}
