import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphene/Datafiles/appbar.dart';
import 'package:graphene/Home.dart';
import 'package:http/http.dart' as http;
import '../Datafiles/Drawer.dart';
import 'file:///C:/Users/ARKUser1/AndroidStudioProjects/graphene/lib/Login/Login.dart';

import 'package:graphene/Datafiles/getIp.dart';

class Forgotpassword extends StatefulWidget {
  final ip = getIp();

  @override
  _ForgotpasswordState createState() => _ForgotpasswordState();
}

class _ForgotpasswordState extends State<Forgotpassword> {
  var token;
  String errormessage;
  bool adddeatils = false;
  bool forgotpassword = true;
  bool validEmail = true;
  bool empty = false;
  final emailid = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  getServices() async {
    print(emailid.text);
    await http
        .get("${widget.ip}/forgotpassword?email=${emailid.text}")
        .then((response) {
      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        setState(() {
          forgotpassword = false;
          adddeatils = true;
        });
      } else {
        setState(() {
          validEmail = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ReusableWidgets.getAppBar(context, "show"),
      drawer: ReusableWidgetsSideBar.sideBar(context),
      body: Form(
        key: _formKey,
        child: ListView(scrollDirection: Axis.vertical, children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              alignment: Alignment.center,
              child: Text(
                "FORGOT PASSWORD",
                style: TextStyle(color: Colors.black, fontSize: 20),
              ),
            ),
          ),
          forgotpassword
              ? Container(
                  child: Column(
                    children: [
                      Container(
                          child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: TextField(
                          controller: emailid,
                          onChanged: (value) => setState(() {
                            empty = false;
                          }),
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Email id*',
                              errorText: empty == true
                                  ? "Please enter email id"
                                  : validEmail == false
                                      ? "Email id is not registered with us"
                                      : null),
                        ),
                      )),
                      FlatButton(
                          child: Text("SUBMIT"),
                          onPressed: () {
                            print("${emailid}");
                            emailid.text == ''
                                ? setState(() {
                                    empty = true;
                                  })
                                : getServices();
                            if (!_formKey.currentState.validate()) ;
                          }),
                    ],
                  ),
                )
              : Container(),
          adddeatils
              ? Container(
                  child: Column(
                    children: [
                      Container(
                          child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                            "Reset link has been sent to your registered mail."),
                      )),
                      FlatButton(
                          child: Text("OK"),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Home()),
                            );
                          }),
                    ],
                  ),
                )
              : Container(),
        ]),
      ),
    );
  }
}
