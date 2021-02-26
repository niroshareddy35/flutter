import 'dart:io';
import 'package:flutter/material.dart';
import 'package:graphene/Home.dart';
import 'file:///C:/Users/ARKUser1/AndroidStudioProjects/graphene/lib/Datafiles/Drawer.dart';
import 'package:graphene/Profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_sidebar/mobile_sidebar.dart';

class ReusableWidgets {
  static getAppBar(context, String displayIcon) {
    Future<void> handleClick(String value) async {
      switch (value) {
        case 'Profile':
          {
            Navigator.pushNamed(context, '/profile');
          }
          break;
        case 'Logout':
          {
            SharedPreferences preferences =
                await SharedPreferences.getInstance();
            await preferences.setString("token", null);
            Navigator.pushNamed(context, '/login');
          }
          break;
      }
    }

    return AppBar(
        title: GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/');
          },
          child: Text("Servex"),
        ),
        actions: <Widget>[
          displayIcon != null
              ? PopupMenuButton<String>(
                  onSelected: handleClick,
                  icon: Icon(
                    Icons.account_circle,
                    color: Colors.white,
                  ),
                  itemBuilder: (BuildContext context) {
                    return {'Profile', 'Logout'}.map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                      );
                    }).toList();
                  },
                )
              : Container(),
        ]);
  }
}
