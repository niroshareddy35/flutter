import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphene/Datafiles/appbar.dart';
import 'package:graphene/Datafiles/getIp.dart';
import '../Datafiles/Drawer.dart';
import 'file:///C:/Users/ARKUser1/AndroidStudioProjects/graphene/lib/Login/Login.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:email_validator/email_validator.dart';

class Registration extends StatefulWidget {
  final ip = getIp();
  getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String stringValue = prefs.getString('token');
    return stringValue;
  }

  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  var token;
  int _value2;
  bool _obscureText = true;
  var resp1 = '';
  final _formKey = GlobalKey<FormState>();
  final firstname = TextEditingController();
  final middlename = TextEditingController();
  final lastname = TextEditingController();
  final password = TextEditingController();
  final conformpassword = TextEditingController();
  final email = TextEditingController();
  final phonenumber = TextEditingController();
  final phonetype = TextEditingController();
  final countrycode = TextEditingController();

  int _value;

  String _dropDownValue;
  postRequest() async {
    var url = "${widget.ip}/register";
    Map data = {
      'fname': "${firstname.text}",
      'mname': "${middlename.text}",
      'lname': "${lastname.text}",
      'password': "${password.text}",
      'email': "${email.text}",
      "phones": [
        {
          'phonenumber': "${phonenumber.text}",
          'phonetype': "${phonetype.text}",
          'countrycode': "${countrycode.text}"
        }
      ],
    };
    print(data);
    String body = json.encode(data);
    await http
        .post(
          url,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${await widget.getToken()}'
          },
          body: body,
        )
        .then((response) => {
              response.statusCode == 200
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Login()),
                    )
                  : {
                      setState(() => resp1 = "User already exists"),
                      print(response.body)
                    }
            });
  }

  String validateMobile(String value) {
    String patttern = r'(^(?:[+0]9)?[0-9]{10,10}$)';
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
      return 'Please enter mobile number';
    } else if (!regExp.hasMatch(value)) {
      return 'Please enter valid mobile number';
    }
    return null;
  }

  String validateEmail(String value) {
    Pattern pattern =
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?)*$";
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value) || value == null)
      return 'Enter a valid email address';
    else
      return null;
  }

  @override
  void initState() {
    super.initState();
    // postRequest();
  }

  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
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
                  "USER REGISTRATION",
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: firstname,

                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'enter firstname',
                              labelText: 'FirstName*'),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'enter firstname';
                            }
                            return null;
                          },
                          // validator: (text) {
                          //   if (text.length < 2)
                          //     return "first name is mandatory";
                          // }
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: TextField(
                          controller: middlename,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Middle Name'),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: TextField(
                          controller: lastname,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Last Name'),
                        ),
                      ),
                    ),
                  ]),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.3,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: TextField(
                  controller: email,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "example@gmail.com",
                    labelText: 'Email id*',
                    errorText: resp1 == "User already exists" ? '$resp1' : null,
                  ),

                  // validator: (text) {
                  //   print("resp: $resp1");
                  //   if (resp1 == "User already exists") {
                  //     return resp1;
                  //   }
                  //   return null;
                  // },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width * 0.45,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: TextFormField(
                          obscureText: _obscureText,
                          controller: password,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter password',
                              labelText: 'password*'),
                          validator: (value) {
                            if (value.isEmpty) return 'Enterpassword';
                            return null;
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.45,
                        child: TextFormField(
                          obscureText: _obscureText,
                          controller: conformpassword,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter conformpassword',
                              labelText: 'Conformpassword*'),
                          validator: (value) {
                            if (value.isEmpty) return 'enter conformpassword';
                            if (value != password.text)
                              return 'Password  not Match';
                            return null;
                          },
                        ),
                      ),
                    ),
                  ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          // padding:
                          //     const EdgeInsets.only(left: 10.0, right: 10.0),
                          decoration: BoxDecoration(border: Border.all()),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButtonFormField(
                              hint: _dropDownValue == null
                                  ? Text('Code*')
                                  : Text(
                                      _dropDownValue,
                                      style: TextStyle(color: Colors.blue),
                                    ),
                              isExpanded: true,
                              iconSize: 30.0,
                              style: TextStyle(color: Colors.blue),
                              items: ['+91', '+1'].map(
                                (val) {
                                  return DropdownMenuItem<String>(
                                    value: val,
                                    child: Text(val),
                                  );
                                },
                              ).toList(),
                              onChanged: (val) {
                                setState(
                                  () {
                                    _dropDownValue = val;
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: TextFormField(
                          controller: phonenumber,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'phonenumber'),
                          validator: validateMobile,
                          // validator: (value) {
                          //   if (value.isEmpty) {
                          //     return 'valid phone number';
                          //   }
                          //   return null;
                          // },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.32,
                        // child: Container(
                        //   padding:
                        //       const EdgeInsets.only(left: 10.0, right: 10.0),
                        //   // decoration: BoxDecoration(border: Border.all()),
                        child: DropdownButtonFormField(
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Mobiletype'),
                            value: _value2,
                            items: [
                              DropdownMenuItem(
                                child: Text("Cell"),
                                value: 1,
                              ),
                              DropdownMenuItem(
                                child: Text("Landline"),
                                value: 2,
                              ),
                            ],
                            onChanged: (value) {
                              _value2 = value;
                            }),
                      ),
                    ),
                  ]),
            ),
            Container(
              child: FlatButton(
                  child: Text('SIGNUP'),
                  color: Colors.blueAccent,
                  textColor: Colors.white,
                  onPressed: () {
                    {
                      firstname.text == '' ||
                              password.text == '' ||
                              email.text == '' ||
                              phonenumber.text == ''
                          ? null
                          : postRequest();

                      if (!_formKey.currentState.validate()) ;
                    }
                  }),
            )
          ]),
        ]),
      ),
    );
  }
}
