import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:android_intent/android_intent.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ESP8266 Controller',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'ESP8266 Controller'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool led1 = false;
  bool led2 = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: (){
//              TODO Setting
            },
          ),
          IconButton(
            icon: Icon(Icons.info),
            onPressed: (){
              _launchURL("https://github.com/iotdevice/ESP8266-Controller");
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'ESP8266-Controller',
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('LED1'),
                  Switch(
                    onChanged: (_){
                      //TODO http request
                      ChangeLEDStatus(1,!led1);
                      setState(() {
                        led1 = !led1;
                      });
                    },
                    value: led1,
                    activeColor: Colors.green,
                    inactiveThumbColor: Colors.red,
                  ),
                ],
              ),
            ),
            Center(
              child:Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('LED2'),
                  Switch(
                    onChanged: (_){
                      //TODO http request
                      ChangeLEDStatus(2,!led2);
                      setState(() {
                        led2 = !led2;
                      });
                    },
                    value: led2,
                    activeColor: Colors.green,
                    inactiveThumbColor: Colors.red,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future ChangeLEDStatus(int led, bool status) async {
    String host = '192.168.1.101';
//    TODO from sf
    //  /?pin=OFF2
    //  /?pin=ON2
    var url = '';
    if (status){
      url = 'http://$host/?pin=ON$led';
    }else {
      url = 'http://$host/?pin=OFF$led';
    }
    await http.get(url);
  }

  _launchURL(String url) async {
    AndroidIntent intent = AndroidIntent(
      action: 'action_view',
      data: url,
    );
    await intent.launch();
  }
}
