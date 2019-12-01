import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: white,
        backgroundColor: Colors.purple,
      ),
      home: MyHomePage(),
    );
  }
}

const MaterialColor white = const MaterialColor(
  0xFFFFFFFF,
  const <int, Color>{
    50: const Color(0xFFFFFFFF),
    100: const Color(0xFFFFFFFF),
    200: const Color(0xFFFFFFFF),
    300: const Color(0xFFFFFFFF),
    400: const Color(0xFFFFFFFF),
    500: const Color(0xFFFFFFFF),
    600: const Color(0xFFFFFFFF),
    700: const Color(0xFFFFFFFF),
    800: const Color(0xFFFFFFFF),
    900: const Color(0xFFFFFFFF),
  },
);

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class CobissAPIBody {
  final int status;
  final String message;

  CobissAPIBody({this.status, this.message});

  factory CobissAPIBody.fromJson(Map<String, dynamic> json) {
    return CobissAPIBody(
      status: json["status"],
      message: json["message"],
    );
  }
}

class CobissApi {
  static const _API_KEY = "f9d62cfc";
  static const _TOKEN = "64bb-4168-a291-36102a29888a";

  Future<CobissAPIBody> startProcedure() async {
    final url = "https://izumc3-tst.izum.si/inventorygw/v1/start";
    final response = await http.get(
      url,
      headers: {
        "apikey": _API_KEY,
        "token": _TOKEN,
      },
    );
    final responseJson = json.decode(response.body);
    print(responseJson);
    return new CobissAPIBody.fromJson(responseJson);
  }

  Future<CobissAPIBody> sendCode(String code) async {
    if (code.length == 12 && !(code.contains(","))) {
      code = code.substring(0, code.length - 1);
    }
    String url = "https://izumc3-tst.izum.si/inventorygw/v1/scan/$code";
    final response = await http.get(
      url,
      headers: {
        "apikey": _API_KEY,
        "token": _TOKEN,
      },
    );
    final responseJson = json.decode(response.body);
    print(responseJson);

    AudioCache player = new AudioCache();

    print(responseJson["status"]);
    if (responseJson["status"] == 0) {
      const alarmAudioPath = "OK.mp3";
      player.play(alarmAudioPath);
    } else if (responseJson["status"] == 11) {
      const alarmAudioPath = "Duplikat.mp3";
      player.play(alarmAudioPath);
    } else if (responseJson["status"] == 12) {
      const alarmAudioPath = "Izposojeno.mp3";
      player.play(alarmAudioPath);
    } else {
      const alarmAudioPath = "Napaka.mp3";
      player.play(alarmAudioPath);
    }
    return new CobissAPIBody.fromJson(responseJson);
  }

  Future<CobissAPIBody> stopProcedure() async {
    final url = "https://izumc3-tst.izum.si/inventorygw/v1/stop";
    final response = await http.get(
      url,
      headers: {
        "apikey": _API_KEY,
        "token": _TOKEN,
      },
    );
    final responseJson = json.decode(response.body);
    print(responseJson);
    return new CobissAPIBody.fromJson(responseJson);
  }
}

class _MyHomePageState extends State<MyHomePage> {
  String barcode = "";
  String bcCompanionText = "\nPozdravljeni!";

  Future scanCode() async {
    try {
      String barcode = await BarcodeScanner.scan();
      bcCompanionText = "Vaša skenirana koda:";
      setState(() => this.barcode = barcode);
      _callCobissApi(2, barcode);
    } catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this.barcode = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() => this.barcode = 'Unknown error: $e');
      }
    }
  }

  void _callCobissApi(int code, String barcode) {
    var api = new CobissApi();
    if (code == 0) {
      // Start
      api.startProcedure();
    } else if (code == 1) {
      // Stop
      api.stopProcedure();
    } else if (code == 2) {
      api.sendCode(barcode);
    }
  }

  void _showToast(BuildContext context, String scannedCode) {
    final scaffold = Scaffold.of(context);
    scaffold.showSnackBar(SnackBar(
      content: Text(scannedCode),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(image: AssetImage('assets/kodko2.png')),
            Container(width: 100, height: 125),
            Container(
              width: 375,
              height: 125,
              decoration: BoxDecoration(
                color: white,
                borderRadius: new BorderRadius.circular(5)
              ),
              margin: EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(bcCompanionText,
                      textAlign: TextAlign.center,
                      style: new TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.purple)),
                  Text(
                    barcode,
                    textAlign: TextAlign.center,
                    style: new TextStyle(fontSize: 28.0, color: Colors.purple),
                  ),
                ],
              ),
            ),
            //Text(bcCompanionText,
            //    textAlign: TextAlign.center,
            //    style: new TextStyle(
            //        fontSize: 20.0, fontWeight: FontWeight.bold, color: white)),
            //Text(
            //  barcode,
            //  textAlign: TextAlign.center,
            //  style: new TextStyle(fontSize: 30.0, color: white),
            //),
            Container(width: 100, height: 75),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                SizedBox(
                  width: 150,
                  height: 50,
                  child: new RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(5),
                      side: BorderSide(color: white),
                    ),
                    color: Colors.purple,
                    textColor: white,
                    onPressed: () {
                      _callCobissApi(0, "");
                      setState(() {
                        bcCompanionText = "\n";
                        barcode = "Skenirajte vašo kodo!\n";
                      });
                    },
                    child: new Text("Start"),
                  ),
                ),
                SizedBox(
                  width: 150,
                  height: 50,
                  child: new RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(5),
                      side: BorderSide(color: white),
                    ),
                    color: Colors.purple,
                    textColor: white,
                    onPressed: () {
                      _callCobissApi(1, "");
                      setState(() {
                        bcCompanionText = "\n";
                        barcode = "Skeniranje zaključeno!\n";
                      });
                    },
                    child: new Text("Stop"),
                  ),
                ),
              ],
            ),
            Container(width: 100, height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                SizedBox(
                  width: 375,
                  height: 75,
                  child: new RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(5),
                      side: BorderSide(color: white),
                    ),
                    color: Colors.purple,
                    textColor: white,
                    onPressed: scanCode,
                    child: new Text(
                      "Novo skeniranje",
                      style: new TextStyle(fontSize: 20.0),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      //floatingActionButton: FloatingActionButton(
      //  onPressed: scanCode,
      //  tooltip: 'Scan',
      //  child: Icon(Icons.photo_camera),
      //),
      backgroundColor: Colors.purple,
    );
  }
}
