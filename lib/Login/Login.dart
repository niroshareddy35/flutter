import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphene/Datafiles/appbar.dart';
import 'package:graphene/Datafiles/getIp.dart';
import 'package:graphene/Home.dart';
import 'package:graphene/Login/Forgotpassword.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Registration/Registration.dart';
import '../Registration/Registrationtwo.dart';

class Login extends StatefulWidget {
  final ip = getIp();

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  var token;
  // final _formKey = GlobalKey<FormState>();
  final username = TextEditingController();
  final password = TextEditingController();
  var resp1 = '';
  postRequest() async {
    var url = "${widget.ip}/authenticate";

    Map data = {
      'username': "${username.text}",
      'password': "${password.text}",
    };

    String body = json.encode(data);
    await http
        .post(
          url,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: body,
        )
        .then((response) => json.decode(response.body))
        .then((data) => {
              print("data ${data}"),
              //  print("resp1 ${resp1}"),
              if (data["token"] != null)
                {
                  this.setState(() => {
                        resp1 = data["fname"],
                        resp1 = data["lname"],
                        resp1 = data["userid"],
                        resp1 = data["mname"],
                        resp1 = data["token"],
                        print("${resp1}"),
                      }),
                  redirectTo(data["token"]),
                  saveInLocalStorage("fname", data["fname"]),
                  saveInLocalStorage("token", data["token"])
                }
              else if (data["message"] == null)
                {
                  this.setState(() => resp1 = "Invalid Username"),
                  print("if ${data["message"]}")
                }
              else if (data["message"] == "INVALID_CREDENTIALS")
                {
                  this.setState(() => resp1 = "Incorrect Password"),
                  print("if ${data["message"]}")
                }
              else if (data["message"] == "USER_DISABLED")
                {
                  this.setState(() => resp1 = "Not verified"),
                  print("if ${data["message"]}")
                }
              // print("resp1 ${resp1}")
            });
  }

  redirectTo(token) async {
    http
        .get("${widget.ip}/servexuser", headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token}',
        })
        .then((response) => json.decode(response.body))
        .then((data) => {
              print(data),
              print("addresses ${data[0]["addresses"].length}"),
              if (data[0]["addresses"].length > 0)
                {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Home()),
                  )
                }
              else
                {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegistrationTwo()),
                  )
                }
            });
  }

  @override
  void initState() {
    super.initState();

    // postRequest();
  }

  void dispose() {
    username.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ReusableWidgets.getAppBar(context, null),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
              child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Text(
              'LOGINPAGE',
              style: TextStyle(color: Colors.black, fontSize: 20),
            ),
          )),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              child: TextField(
                autofocus: false,
                controller: username,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Username*',
                  errorText:
                      resp1 == "Invalid Username" || resp1 == "Not verified"
                          ? '$resp1'
                          : null,
                ),
                // validator: (text) {
                //   if (text == null || text.isEmpty) {
                //     return 'Text is empty';
                //   } else if (resp1 == "Invalid Username") {
                //     return resp1;
                //   } else if (resp1 == "Not verified") {
                //     return "Please verify your account through the link sent to your mail";
                //   }
                //   return null;
                // },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              child: TextField(
                autofocus: false,
                controller: password,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'password*',
                  errorText: resp1 == "Incorrect Password" ? '$resp1' : null,
                ),
                // validator: (text) {
                //   if (text == null || text.isEmpty) {
                //     return 'Text is empty';
                //   } else if (resp1 == "Incorrect Password") {
                //     return resp1;
                //   }
                //   return null;
                // },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: Column(
                      children: [
                        FlatButton(
                          child: Text('Forgot Password'),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Forgotpassword()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.2,
                    child: FlatButton(
                        child: Text('Signin'),
                        onPressed: () {
                          postRequest();

                          // if (!_formKey.currentState.validate()) ;
                        }),
                  ),
                ]),
          ),
          FlatButton(
            child: Text('New/Register'),
            textColor: Colors.black,
            onPressed: () {
              Navigator.pushNamed(context, '/registration');
            },
          ),
        ],
      ),
    );
  }

  Future<void> saveInLocalStorage(String key, String value) async {
    var pref = await SharedPreferences.getInstance();
    pref.setString(key, value);
  }
}
