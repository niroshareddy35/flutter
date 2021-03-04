import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphene/Datafiles/getIp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class ChatRoom extends StatefulWidget {
  getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String stringValue = prefs.getString('token');
    return stringValue;
  }

  final ip = getIp();
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  var token;
  @override
  void initState() {
    super.initState();
    stompClient.activate();
    token = widget.getToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}

dynamic onConnect(StompClient client, StompFrame frame) {
  client.subscribe(
      destination: '/user/6/queue/messages',
      callback: (StompFrame frame) {
        List<dynamic> result = json.decode(frame.body);
        print(result);
      });

  Timer.periodic(Duration(seconds: 10), (_) {
    client.send(
        destination: '/app/chat',
        body: json.encode({
          "senderId": "6",
          "recipientId": "7",
          "timestamp": new DateTime.now()
        }));
  });
}

final stompClient = StompClient(
    config: StompConfig(
  url: "https://3.141.194.55:8443/servex/api/v1/ws",
  onConnect: onConnect,
  onWebSocketError: (dynamic error) => print(error.toString()),
));
