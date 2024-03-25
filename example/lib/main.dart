import 'package:flutter/material.dart';
import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ConnectyCube CallKit Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'ConnectyCube Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _simulateIncomingCall,
                child: const Text('Simulate incoming call'),
              ),
            ],
          ),
        ));
  }

  Future<void> _simulateIncomingCall() async {
    P2PCallSession incomingCall = P2PCallSession(
      sessionId: const Uuid().v4(),
      callerId: 1234,
      callerName: 'callerName',
      callSubtitle: 'callSubtitle',
      callerImageUrl: 'https://picsum.photos/id/177/100/100',
      opponentsIds: {789},
      callType: 1,
    );

    final info = {'key': 'value'};

    CallEvent callEvent = CallEvent(
      sessionId: incomingCall.sessionId,
      callType: incomingCall.callType,
      callerId: incomingCall.callerId,
      callerName: incomingCall.callerName,
      callerSubtitle: incomingCall.callSubtitle,
      callPhoto: incomingCall.callerImageUrl,
      opponentsIds: incomingCall.opponentsIds,
      userInfo: info,
    );
    ConnectycubeFlutterCallKit.showCallNotification(callEvent);
  }
}

class P2PCallSession {
  const P2PCallSession({
    required this.sessionId,
    required this.callerId,
    required this.callerName,
    this.callSubtitle,
    this.callerImageUrl,
    required this.opponentsIds,
    required this.callType,
  });

  final String sessionId;
  final int callerId;
  final String callerName;
  final String? callSubtitle;
  final String? callerImageUrl;
  final Set<int> opponentsIds;
  final int callType;
}