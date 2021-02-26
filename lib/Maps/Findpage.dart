import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphene/Datafiles/appbar.dart';
import 'package:graphene/Datafiles/getIp.dart';
import 'package:graphene/Maps/Location.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Datafiles/Drawer.dart';
import 'Deatils.dart';

class Findpage extends StatefulWidget {
  final String name;
  Findpage({Key key, this.name}) : super(key: key);

  final ip = getIp();
  getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String stringValue = prefs.getString('token');
    return stringValue;
  }

  @override
  _FindpageState createState() => _FindpageState();
}

class _FindpageState extends State<Findpage> {
  final _formKey = GlobalKey<FormState>();
  var data;
  var token = null;
  final controller = TextEditingController();

  // Future<MyApp1>post;
  String city = "hyderabad";

  var myTabController;

  @override
  void initState() {
    super.initState();
    setState(() {
      controller.text = widget.name;
    });
    widget.getToken().then((response) => {
          setState(() {
            token = response;
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    var _tabController;
    return Scaffold(
        appBar: ReusableWidgets.getAppBar(context, "show"),
        drawer: ReusableWidgetsSideBar.sideBar(context),
        body: Form(
            key: _formKey,
            child: ListView(scrollDirection: Axis.vertical, children: <Widget>[
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 10,
                    ),
                    token == null
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                // margin: EdgeInsets.all(30.0),
                                // padding: EdgeInsets.all(30.0),
                                child: FlatButton(
                                  onPressed: () {},
                                  child: Text(
                                    "Sign In",
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline),
                                  ),
                                ),
                              ),
                              Container(
                                  child: FlatButton(
                                onPressed: () {},
                                child: Row(
                                  children: [
                                    Text(
                                      "New / Register",
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline),
                                    ),
                                    Icon(
                                      Icons.ac_unit,
                                      color: Colors.black,
                                    ),
                                  ],
                                ),
                              )),
                            ],
                          )
                        : Container(),
                    Row(children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                height: 30,
                              ),
                              Text("I need",
                                  style: TextStyle(
                                    fontSize: 20.0,
                                  )),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.5,
                                    child: TextField(
                                      controller: controller,
                                      autocorrect: true,
                                      decoration: InputDecoration(
                                        prefixIcon: Icon(Icons.search),
                                        suffixIcon: Icon(Icons.mic),
                                        filled: true,
                                        fillColor: Colors.white30,
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.black, width: 2),
                                        ),
                                      ),
                                    )),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(1.0),
                                child: Container(
                                  child: FlatButton(
                                    child: SizedBox(
                                      height: 55,
                                      child: Container(
                                        child: Center(
                                          child: Text(
                                            'Find',
                                            style: TextStyle(fontSize: 20.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                    shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            color: Colors.black, width: 2)),
                                    textColor: Colors.black,
                                    onPressed: () {},
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ]),
                    SizedBox(
                      width: 400.0,
                      height: 400.0,
                      child: DefaultTabController(
                        length: 2,
                        child: Scaffold(
                          appBar: TabBar(
                            labelColor: Colors.black,
                            tabs: [
                              Tab(text: 'Details'),
                              Tab(
                                text: 'Location',
                              ),
                            ],
                          ),
                          body: TabBarView(
                            controller: _tabController,
                            children: [
                              Details(),
                              Location(),
                            ],
                          ),
                        ),
                      ),
                    )
                  ]),
            ])));
  }
}
