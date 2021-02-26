import 'dart:io';
import 'package:flutter/material.dart';
import 'package:graphene/Home.dart';
import 'file:///C:/Users/ARKUser1/AndroidStudioProjects/graphene/lib/Service%20Requests/MyServiceRequests.dart';
import 'file:///C:/Users/ARKUser1/AndroidStudioProjects/graphene/lib/Datafiles/Drawer.dart';
import 'package:graphene/Profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_sidebar/mobile_sidebar.dart';

import '../Service Requests/CreateService.dart';

class ReusableWidgetsSideBar {
  static sideBar(context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text('Drawer Header'),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ExpansionTile(
            title: Text("Bids"),
            children: <Widget>[
              FlatButton(
                  child: Text('My Bids'),
                  textColor: Colors.black,
                  onPressed: () {
                    Navigator.pushNamed(context, '/myBids');
                  }),
              FlatButton(
                  child: Text('Offered Bids'),
                  textColor: Colors.black,
                  onPressed: () {
                    Navigator.pushNamed(context, '/offeredBids');
                  }),
            ],
          ),
          ExpansionTile(
            title: Text("Service Requests"),
            children: <Widget>[
              FlatButton(
                  child: Text('Create Service Request'),
                  textColor: Colors.black,
                  onPressed: () {
                    Navigator.pushNamed(context, '/createService');
                  }),
              FlatButton(
                  child: Text('My Service Requests'),
                  textColor: Colors.black,
                  onPressed: () {
                    Navigator.pushNamed(context, '/myServiceRequest');
                  }),
              FlatButton(
                  child: Text(' Work Order Queue'),
                  textColor: Colors.black,
                  onPressed: () {
                    Navigator.pushNamed(context, '/workOrderqueue');
                  }),
            ],
          ),
          ListTile(
            title: Text("My Assignments"),
            onTap: () {
              Navigator.pushNamed(context, '/myAssignments');
            },
          ),
        ],
      ),
    );
  }
}
