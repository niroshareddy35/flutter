import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Datafiles/appbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'file:///C:/Users/ARKUser1/AndroidStudioProjects/graphene/lib/Datafiles/Drawer.dart';
import 'Maps/Findpage.dart';

class Home extends StatefulWidget {
  getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String stringValue = prefs.getString('token');
    return stringValue;
  }

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var token = null;
  @override
  void initState() {
    super.initState();
    widget.getToken().then((response) => {
          setState(() {
            token = response;
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    return Scaffold(
      appBar: ReusableWidgets.getAppBar(context, "show"),
      drawer: ReusableWidgetsSideBar.sideBar(context),
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
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
                        onPressed: () {
                          Navigator.pushNamed(context, '/registration');
                        },
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
            Padding(
              padding: const EdgeInsets.all(50.0),
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text("I need",
                        style: TextStyle(
                          fontSize: 20.0,
                        )),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: TextField(
                            controller: nameController,
                            autocorrect: true,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.search),
                              suffixIcon: Icon(Icons.mic),
                              hintStyle: TextStyle(color: Colors.grey),
                              filled: true,
                              fillColor: Colors.white70,
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.black, width: 2),
                              ),
                            ),
                          )),
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  child: FlatButton(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Find',
                          style: TextStyle(fontSize: 20.0),
                        ),
                      ],
                    ),
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.black, width: 2)),
                    textColor: Colors.black,
                    onPressed: () {
                      nameController.text == ''
                          ? null
                          : Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Findpage(
                                  name: nameController.text,
                                ),
                              ));
                    },
                  ),
                ),
              ),
            ),
            // FlatButton(onPressed: getStringValuesSF, child: Text("abc"))
          ]),
    );
  }
}
