import 'dart:convert';
import 'dart:io';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphene/Datafiles/appbar.dart';
import 'package:graphene/Datafiles/getIp.dart';
import 'file:///C:/Users/ARKUser1/AndroidStudioProjects/graphene/lib/Service%20Requests/MyServiceRequests.dart';
import 'package:graphene/Registration/RegistrationThree.dart';
import 'package:graphene/Registration/Registrationtwo.dart';
import 'package:graphene/Update%20Service%20Requests.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import '../Datafiles/AvailableServices.dart';
import '../Datafiles/Drawer.dart';
import 'package:mime/mime.dart';
import 'package:timezone/timezone.dart';

import '../Home.dart';

class CreateService extends StatefulWidget {
  var serviceRequestId;
  bool showContent = true;
  bool assignValues = false;
  CreateService({
    Key key,
    this.serviceRequestId,
  }) : super(key: key);
  final ip = getIp();

  getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String stringValue = prefs.getString('token');
    return stringValue;
  }

  @override
  _CreateServiceState createState() => _CreateServiceState();
}

class _CreateServiceState extends State<CreateService> {
  final services = AvailableServices();
  s1() async {
    return await services.getRequest();
  }

  final serviceRequestDetails = UpdateServiceRequest();
  s2() async {
    return await serviceRequestDetails.serviceId(widget.serviceRequestId);
  }

  var token;
  List availableServices = [];
  var title = TextEditingController();
  var description = TextEditingController();
  bool show = false;
  bool showTime = false;
  DateTime selectedDate = DateTime.now();
  TimeOfDay _time = TimeOfDay(hour: 7, minute: 15);
  final _formKey = GlobalKey<FormState>();
  String serviceid;
  String deliveryMode;
  int _radioValue = 0;
  var date;
  var time;
  var dateTime;
  String fileName;
  Map<String, String> paths;
  List<String> extensions;
  bool isLoadingPath = false;
  FileType fileType;
  List attachments = [];
  var serviceRequestById;

  void _handleRadioValueChange(int value) {
    setState(() {
      _radioValue = value;
      switch (_radioValue) {
        case 0:
          show = false;
          setState(() {
            dateTime = null;
          });
          break;
        case 1:
          show = true;
          break;
      }
    });
  }

  _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate, // Refer step 1
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );

    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
    setState(() {
      date = picked;
      dateTime = DateTimeField.combine(picked, time);
      print(dateTime);
    });
  }

  void _selectTime() async {
    final TimeOfDay newTime = await showTimePicker(
      context: context,
      initialTime: _time,
    );

    if (newTime != null) {
      print("latest ${newTime}");
      setState(() {
        _time = newTime;
      });
    }
    setState(() {
      time = newTime;
      dateTime = DateTimeField.combine(date, newTime);
      print(dateTime);
    });
  }

  void _openFileExplorer() async {
    setState(() => isLoadingPath = true);
    try {
      paths = await FilePicker.getMultiFilePath(
          type: fileType != null ? fileType : FileType.any,
          allowedExtensions: extensions);
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    }
    if (!mounted) return;
    setState(() {
      isLoadingPath = false;
      fileName = paths != null ? paths.keys.toString() : '...';
    });
  }

  base64(name, file) async {
    List fileBytes = await new File(file).readAsBytesSync();
    String encodedFile = base64Encode(fileBytes);
    final type = lookupMimeType(file);
    attachments = [
      ...attachments,
      {
        "content": encodedFile,
        "name": name,
        "type": type,
      }
    ];
  }

  postRequest() async {
    Map data = {
      "servicerequestid":
          "${widget.assignValues ? serviceRequestById["servicerequestid"] : null}",
      'title': "${title.text}",
      'description': "${description.text}",
      "service": {
        'serviceid': "${serviceid}",
      },
      'serviceabletime':
          "${dateTime != null ? dateTime.toUtc().toIso8601String() : null}",
      'attachments': attachments,
      'receivingmethod': "${deliveryMode}",
    };
    String body = json.encode(data);
    print(body);
    widget.assignValues
        ? await http
            .put(
              "${widget.ip}/servicerequest",
              headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                'Authorization': 'Bearer ${await widget.getToken()}',
              },
              body: body,
            )
            .then((response) => {
                  print(response.body),
                  print(response.statusCode),
                  if (response.statusCode == 200)
                    {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MyServiceRequest()),
                      )
                    }
                })
        : await http
            .post(
              "${widget.ip}/servicerequest",
              headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                'Authorization': 'Bearer ${await widget.getToken()}',
              },
              body: body,
            )
            .then((response) => {
                  print(response.body),
                  print(response.statusCode),
                  if (response.statusCode == 200)
                    {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MyServiceRequest()),
                      )
                    }
                });
  }

  void initState() {
    JsonEncoder encoder;
    String respPrint;
    super.initState();
    print(widget.serviceRequestId.runtimeType);

    setState(() {
      widget.showContent =
          widget.serviceRequestId.runtimeType == int ? false : true;
    });
    this.s1().then((response) => setState(() {
          availableServices = response;
        }));

    widget.serviceRequestId.runtimeType == int
        ? this.s2().then((response) => {
              print("old time is ${_time}"),
              setState(() {
                serviceRequestById = response;
                title.text = response["title"];
                description.text = response["description"];
                serviceid = response['service']['serviceid'].toString();
                deliveryMode = response["receivingmethod"];
                if (response["serviceabletime"] != null) {
                  final dat =
                      DateTime.parse(response["serviceabletime"]).toLocal();
                  print(
                      "parsed date is ${dat} and ${response["serviceabletime"]}");
                  selectedDate = dat;
                  _time = TimeOfDay.fromDateTime(dat);
                  dateTime =
                      DateTimeField.combine(dat, TimeOfDay.fromDateTime(dat));
                  date = dat;
                  time = TimeOfDay.fromDateTime(dat);
                  print("new time is ${TimeOfDay.fromDateTime(dat)}");
                  _radioValue = 1;
                  show = true;
                }
                widget.showContent = true;
                widget.assignValues = true;
              }),
              encoder = new JsonEncoder.withIndent('  '),
              respPrint = encoder.convert(serviceRequestById),
              respPrint.split('\n').forEach((element) => print(element)),
              // print(response)
            })
        : null;
  }

  @override
  Widget build(BuildContext context) {
    print("date is ${selectedDate}");
    return Scaffold(
        appBar: ReusableWidgets.getAppBar(context, "show"),
        drawer: ReusableWidgetsSideBar.sideBar(context),
        body: Form(
            key: _formKey,
            child: widget.showContent
                ? ListView(scrollDirection: Axis.vertical, children: <Widget>[
                    Column(
                      children: <Widget>[
                        Container(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              "Create Service Request",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 20),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text("Title of the request"),
                                    )),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.52,
                                  child: TextFormField(
                                    controller: title,
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        hintText: 'title*',
                                        labelText: 'title*'),
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return ' enter title';
                                      }
                                      return null;
                                    },
                                  ),
                                )
                              ]),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text("Description"),
                                    )),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.52,
                                  child: TextFormField(
                                    controller: description,
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        hintText: 'Description*',
                                        labelText: 'Description*'),
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'enter description';
                                      }
                                      return null;
                                    },
                                  ),
                                )
                              ]),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.39,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: Text(
                                    "Priority",
                                  ),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.56,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        new Radio(
                                          value: 0,
                                          groupValue: _radioValue,
                                          onChanged: _handleRadioValueChange,
                                        ),
                                        new Text(
                                          'Asap',
                                          style: new TextStyle(fontSize: 16.0),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        new Radio(
                                          value: 1,
                                          groupValue: _radioValue,
                                          onChanged: _handleRadioValueChange,
                                        ),
                                        new Text(
                                          'Pick a Date',
                                          style: new TextStyle(fontSize: 16.0),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        show
                            ? Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.4,
                                    ),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.52,
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              "${selectedDate.toLocal()}"
                                                  .split(' ')[0],
                                              style: TextStyle(fontSize: 18),
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                Icons.calendar_today,
                                              ),
                                              color: Colors.black,
                                              onPressed: () {
                                                _selectDate(context);
                                              },
                                            ),
                                          ],
                                        ),
                                        Container(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(' ${_time.format(context)}',
                                                  style:
                                                      TextStyle(fontSize: 18)),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.timer,
                                                ),
                                                onPressed: () {
                                                  _selectTime();
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              )
                            : Container(),
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
                                  child: Text("Attachements"),
                                )),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.52,
                              child: new OutlineButton(
                                  child: new Text("Upload files"),
                                  shape: new RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(1.0)),
                                  onPressed: () {
                                    attachments = [];
                                    _openFileExplorer();
                                  }),
                            ),
                          ]),
                    ),
                    new Builder(
                      builder: (BuildContext context) => isLoadingPath
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: const CircularProgressIndicator())
                          : paths != null
                              ? new Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.3,
                                  child: new Scrollbar(
                                      child: new ListView.separated(
                                    itemCount: paths != null && paths.isNotEmpty
                                        ? paths.length
                                        : 1,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      final String name =
                                          paths.keys.toList()[index];
                                      attachments.length <= index
                                          ? base64(paths.keys.toList()[index],
                                              paths.values.toList()[index])
                                          : null;
                                      return new ListTile(
                                        title: new Text(
                                          name,
                                        ),
                                        // subtitle: new Text(filePath),
                                      );
                                    },
                                    separatorBuilder:
                                        (BuildContext context, int index) =>
                                            new Divider(),
                                  )),
                                )
                              : new Container(),
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
                                  child: Text("Service"),
                                )),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.55,
                              child: Container(
                                  padding: const EdgeInsets.only(
                                      left: 10.0, right: 10.0),
                                  child: DropdownButtonFormField(
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'Select Service*'),
                                    value: serviceid,
                                    items: [
                                      for (var i in availableServices)
                                        DropdownMenuItem(
                                          child: Text(i["name"]),
                                          value: i["serviceid"].toString(),
                                        )
                                    ],
                                    onChanged: (value) {
                                      serviceid = value;
                                    },
                                    validator: (value) => value == null
                                        ? 'select serviece id'
                                        : null,
                                  )),
                            )
                          ]),
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
                                  child: Text("Deliverymode"),
                                )),
                            Container(
                                width: MediaQuery.of(context).size.width * 0.55,
                                child: Container(
                                    padding: const EdgeInsets.only(
                                        left: 10.0, right: 10.0),
                                    child: DropdownButtonFormField(
                                        decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: 'Delivery Mode*'),
                                        value: deliveryMode,
                                        items: [
                                          DropdownMenuItem(
                                            child: Text("In-Person Apperance"),
                                            value: "In-Person",
                                          ),
                                          DropdownMenuItem(
                                            child: Text("Virtual"),
                                            value: "Virtual",
                                          ),
                                        ],
                                        validator: (value) => value == null
                                            ? 'select delivery mode'
                                            : null,
                                        onChanged: (value) {
                                          deliveryMode = value;
                                        }))),
                          ]),
                    ),
                    Container(
                      child: FlatButton(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                            child: Text('SAVE'),
                          ),
                          onPressed: () {
                            {
                              serviceid == '' ||
                                      title.text == '' ||
                                      description.text == '' ||
                                      deliveryMode == ''
                                  ? null
                                  : postRequest();
                              if (!_formKey.currentState.validate()) ;
                            }
                          }),
                    ),
                  ])
                : Container()));
  }
}
