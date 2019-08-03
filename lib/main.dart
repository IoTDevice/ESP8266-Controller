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
              _setHost();
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
                      ChangeLEDStatus(1,!led1);
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
                      ChangeLEDStatus(2,!led2);
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
//    String host = '192.168.1.101';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String host = prefs.getString("host")??'';
    if (host == ''){
      return _setHost();
    }
    //  /?pin=OFF2
    //  /?pin=ON2
    var url = '';
    if (status){
      url = 'http://$host/?pin=ON$led';
    }else {
      url = 'http://$host/?pin=OFF$led';
    }
    try {
      await http.get(url).timeout(const Duration(seconds: 2));
      setState(() {
        if(led == 1){
          led1 = !led1;
        }else{
          led2 = !led2;
        }
      });
    }catch(e){
      print(e.toString());
      return showDialog(
          context: context,
          builder: (_) => AlertDialog(
              title: Text("出错！"),
              content: ListView(
                children: <Widget>[
                  Text("请检查ESP8266 IP：$host的正确性，确认端口80已经打开！"),
                ],
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text("确定"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
          ),
      );
    }
  }

  _launchURL(String url) async {
    AndroidIntent intent = AndroidIntent(
      action: 'action_view',
      data: url,
    );
    await intent.launch();
  }

  _setHost() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String host = prefs.getString("host")??'192.168.0.2';
    TextEditingController _host_controller =
    TextEditingController.fromValue(TextEditingValue(text: host));
    return showDialog(
        context: context,
        builder: (_) => AlertDialog(
            title: Text("设置ESP8266的IP："),
            content: ListView(
              children: <Widget>[
                TextFormField(
                  controller: _host_controller,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(10.0),
                    labelText: 'ESP8266 的IP',
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("取消"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text("确定"),
                onPressed: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.setString('host',_host_controller.text);
                  Navigator.of(context).pop();
                },
              )
            ]));
  }

}
