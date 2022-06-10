import 'dart:collection';

import 'package:flutter/material.dart';

import 'package:web3auth_flutter/web3auth_flutter.dart';
import 'package:web3authflutterdemo/transaction.dart';
import 'package:web3dart/web3dart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Web3AuthFlutterDemo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool logoutVisible = false;
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    HashMap themeMap = HashMap<String, String>();
    themeMap['primary'] = "#fff000";

    await Web3AuthFlutter.init(
        clientId:
            'BCSgZ_yxdfS-QNNoHl2BsWit8wke2Jf4CRhyQ-x-xcJF9a5ZQBeWkfw5mO0rEmr0lImMbA6tF01NJ20G3MgNXBI',
        network: Network.testnet,
        redirectUri: 'com.example.web3authflutterdemo://auth',
        whiteLabelData: WhiteLabelData(
            dark: true, name: "Web3Auth Flutter App", theme: themeMap));
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
                onPressed: _login(_withGoogle), child: const Text('Google')),
            ElevatedButton(
                onPressed: _login(_withFacebook),
                child: const Text('Facebook')),
            ElevatedButton(
                onPressed: _login(_withDiscord), child: const Text('Discord')),
            ElevatedButton(
                onPressed: _login(_withTwitter), child: const Text('Twitter')),
            Visibility(
              visible: logoutVisible,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.red),
                onPressed: _logout(),
                child: const Text('Logout'),
              ),
            ),
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  VoidCallback _logout() {
    return () async {
      try {
        await Web3AuthFlutter.logout();
        setState(() {
          logoutVisible = false;
        });
      } on UserCancelledException {
        print('UserCancelledException');
      } on UnKnownException {
        print("UnKnownException");
      }
    };
  }

  VoidCallback _login(Future<Web3AuthResponse> Function() method) {
    return () async {
      try {
        final Web3AuthResponse response = await method();
        setState(() {
          logoutVisible = true;
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => TransactionPage(
                        response: response,
                      )));
        });
      } on UserCancelledException {
        print('User cancelled');
      } on UnKnownException {
        print('Unknown exception occurred');
      }
    };
  }

  Future<Web3AuthResponse> _withGoogle() {
    return Web3AuthFlutter.login(provider: Provider.google);
  }

  Future<Web3AuthResponse> _withFacebook() {
    return Web3AuthFlutter.login(provider: Provider.facebook);
  }

  Future<Web3AuthResponse> _withDiscord() {
    return Web3AuthFlutter.login(provider: Provider.discord);
  }

  Future<Web3AuthResponse> _withTwitter() {
    return Web3AuthFlutter.login(provider: Provider.twitter);
  }
}
