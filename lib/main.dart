import 'package:flutter/material.dart';
import './selector.dart';
import 'dart:async';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: "Selector"),
      routes: <String, WidgetBuilder>{
        '/a': (BuildContext context) => new SelectorPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String city = "";

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(32.0),
        child: new Column(
          children: <Widget>[
            new RaisedButton(
                child: new Text("城市选择器"),
                onPressed: () {
                  _go(); //跳转
                }),
            new Container(
              child: new Text(city),
              padding: const EdgeInsets.all(32.0),
            )
          ],
        ),
      ),
    );
  }

  _go() async {
    //打开并接收返回值
    String result = await Navigator.pushNamed(context, '/a');

    setState(() {
      city = result == null ? "" : result;
    });
  }
}
