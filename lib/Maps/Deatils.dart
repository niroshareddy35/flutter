import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:graphene/Datafiles/getIp.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Details extends StatefulWidget {
  final String title;
  final String description;
  final ip = getIp();

  Details({Key key, @required this.title, this.description}) : super(key: key);

  getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String stringValue = prefs.getString('token');
    return stringValue;
  }

  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  var pagesize = 5;
  var pageNumber = 0;
  var totalElements;
  var data;
  List serviceProviders = [];
  final _formKey = GlobalKey<FormState>();

  getPost() async {
    JsonEncoder encoder;
    String respPrint;
    await http
        .get(
          "${widget.ip}/serviceprovider?filter=web&pageNumber=0&pageSize=20&sortColumn=fname&sortOrder=ASC",
        )
        .then((response) => {
              print(response.body),
              print(response.statusCode),
              data = jsonDecode(response.body),
              print(response.statusCode),
              encoder = new JsonEncoder.withIndent('  '),
              respPrint = encoder.convert(data),
              respPrint.split('\n').forEach((element) => print(element)),
              if (response.statusCode == 200)
                {
                  setState(() {
                    totalElements = data["totalelements"];
                    serviceProviders = data["serviceproviders"]["content"];
                  }),
                  print("length is:${serviceProviders.length}"),
                }
            });
  }

  @override
  void initState() {
    super.initState();
    getPost();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter REST API Example',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: Scaffold(
          body: Form(
              key: _formKey,
              child:
                  ListView(scrollDirection: Axis.vertical, children: <Widget>[
                Column(children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                    ),
                  ),
                ]),
                for (var i = 0; i < serviceProviders.length; i++)
                  Column(mainAxisSize: MainAxisSize.min, children: [
                    Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Name:${serviceProviders[i]["name"]}",
                              ),
                              Text(
                                "Specialization:${serviceProviders[i]["description"]}",
                              ),
                              Text(
                                "Experience:${serviceProviders[i]["yearofexperience"]}",
                              ),
                              Text(
                                "HourlyRate:${serviceProviders[i]["hourlyrate"]}",
                              ),
                              Text(
                                "Location:${serviceProviders[i]["addressline1"]}",
                              ),
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    FlatButton(
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 10, 0, 0),
                                          child: Text('Ask for Service'),
                                        ),
                                        onPressed: () {}),
                                    // IconButton(
                                    //   icon: Icon(Icons.edit),
                                    //   color: Colors.black,
                                    //   onPressed: () {},
                                    // ),
                                  ],
                                ),
                              ),
                            ])),
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
                                            getPost()
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
                                        getPost()
                                      };
                              },
                            ))
                      ]),
                ),
              ]))),
    );
  }
}
