import 'dart:io';
import 'package:flutter/material.dart';
import 'file:///C:/Users/ARKUser1/AndroidStudioProjects/graphene/lib/Service%20Requests/CreateService.dart';
import 'package:graphene/Login/Forgotpassword.dart';
import 'package:graphene/Maps/Findpage.dart';
import 'package:graphene/Maps/Location.dart';
import 'package:graphene/My%20Assignments.dart';
import 'file:///C:/Users/ARKUser1/AndroidStudioProjects/graphene/lib/Bids/My%20Bids.dart';
import 'file:///C:/Users/ARKUser1/AndroidStudioProjects/graphene/lib/Service%20Requests/MyServiceRequests.dart';
import 'Maps/Deatils.dart';
import 'Bids/Offered Bids.dart';
import 'Service Requests/Work Order Queue.dart';
import 'file:///C:/Users/ARKUser1/AndroidStudioProjects/graphene/lib/Datafiles/Drawer.dart';
import 'package:graphene/Registration/Registration.dart';
import 'Registration/RegistrationThree.dart';
import 'Registration/Registrationtwo.dart';
import 'Home.dart';
import 'Login/Login.dart';
import 'Profile.dart';
import 'File.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = new MyHttpOverrides();
  runApp(MaterialApp(
    routes: {
      '/': (context) => Home(),
      '/file': (context) => File(),
      '/login': (context) => Login(),
      '/findpage': (context) => Findpage(),
      '/registration': (context) => Registration(),
      '/registration2': (context) => RegistrationTwo(),
      '/registration3': (context) => RegistrationThree(),
      '/profile': (context) => Profile(),
      '/createService': (context) => CreateService(),
      '/myServiceRequest': (context) => MyServiceRequest(),
      '/workOrderqueue': (context) => WorkOrderQueue(),
      '/offeredBids': (context) => OfferedBids(),
      '/myBids': (context) => MyBids(),
      '/myAssignments': (context) => MyAssignments(),
    },
  ));
}
