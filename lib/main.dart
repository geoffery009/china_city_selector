import 'package:flutter/material.dart';
import './china_cities.dart';
import 'dart:collection';

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
      home: new MyHomePage(title: 'Flutter Demo Home Page'),
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
  Map<String, dynamic> cityUpWordStartIndex = new HashMap();
  List<String> cityUpWordArr = new List();
  ScrollController scrollController = new ScrollController();
  double tileHeight = 48.0;
  double tileTileHeight = 32.0;

  @override
  void initState() {
    super.initState();

    //前提是数据已按拼音字母排序
    for (int i = 0; i < china_cities_data.length; i++) {
      String currentFLetter = getFirstLetter(china_cities_data[i]["pinyin"]);
      String preFLetter =
          i >= 1 ? getFirstLetter(china_cities_data[i - 1]["pinyin"]) : "";

      if (currentFLetter != preFLetter) {
        cityUpWordStartIndex[currentFLetter] = i;
        cityUpWordArr.add(currentFLetter);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Stack(
        children: <Widget>[
          new ListView(
            children: _getData(),
            controller: scrollController,
          ),
          new Center(
            child: new RaisedButton(
              onPressed: () {
                //滚动到指定位置
                scrollController.animateTo(
                    (cityUpWordStartIndex["Q"] * tileHeight +
                        cityUpWordArr.indexOf("Q") * tileTileHeight),
                    duration: new Duration(milliseconds: 300),
                    curve: Curves.ease);
                debugPrint("hahah");
              },
              child: new Text("search Q"),
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _getData() {
    List<Widget> arr = new List();
    for (int i = 0; i < china_cities_data.length; i++) {
      String currentFLetter = getFirstLetter(china_cities_data[i]["pinyin"]);
      String preFLetter =
          i >= 1 ? getFirstLetter(china_cities_data[i - 1]["pinyin"]) : "";

      if (currentFLetter != preFLetter) {
        //多加一行首字母
        arr.add(new Container(
          color: Colors.grey[300],
          height: tileTileHeight,
          padding: const EdgeInsets.only(left: 24.0),
          child: new Row(
            children: <Widget>[new Text(currentFLetter)],
          ),
        ));
      }
      //添加城市名称布局
      arr.add(new GestureDetector(
        child: new Container(
          height: tileHeight,
          padding: const EdgeInsets.only(left: 24.0),
          child: new Row(
            children: <Widget>[new Text(china_cities_data[i]["name"])],
          ),
        ),
        onTap: () {
          _onTileClick(china_cities_data[i]["name"]);
        },
      ));
    }
    return arr;
  }

  _onTileClick(String name) {
    debugPrint(name);
  }

  //获取拼音的首字母（大写）
  String getFirstLetter(String pinyin) {
    return pinyin.substring(0, 1).toUpperCase();
  }
}
