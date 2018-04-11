import 'package:flutter/material.dart';
import "package:flutter/rendering.dart";
import 'dart:collection';
import './china_cities.dart';
import './strings.dart';

class SelectorPage extends StatefulWidget {
  SelectorPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _SelectorPageState createState() => new _SelectorPageState();
}

class _SelectorPageState extends State<SelectorPage> {
  Map<String, dynamic> cityUpWordStartIndex = new HashMap();
  List<String> cityUpWordArr = new List();
  ScrollController scrollController = new ScrollController();
  double tileHeight = 48.0; //城市列表每项高度
  double tileTileHeight = 32.0; //列表标题每项高度
  double selectUpWordTileHeight = 24.0; //字母选择列表每项高度
  int hotCityHeightScale = 1;
  String selectedUpWord = "", curSelectedUpWord = "";
  double appBarHeight = 0.0;

  TextEditingController textEditingController = new TextEditingController();

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
        title: new Row(
          children: <Widget>[
            new Expanded(
                child: new Container(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              margin: const EdgeInsets.only(right: 20.0),
              child: new TextField(
                style: new TextStyle(fontSize: 14.0, color: Colors.black),
                decoration: new InputDecoration(
                  hintText: Strings.SEARCH_HINT_TEXT,
                  hintStyle: new TextStyle(color: Colors.grey),
                ),
                controller: textEditingController,
              ),
              decoration: new BoxDecoration(color: Colors.grey[200]),
            )),
            new GestureDetector(
              child: new Text(
                Strings.CANCEL,
                style: new TextStyle(fontSize: 14.0),
              ),
              onTap: () {
                _onTileClick("");
              },
            )
          ],
        ),
      ),
      body: new Stack(
        alignment: Alignment.topRight,
        children: <Widget>[
          _getCityList(),
          _getWordSelectWidget(),
          _getShowSelectedCenterWidget()
        ],
      ),
    );
  }

  //城市列表
  Widget _getCityList() {
    return new ListView(
      children: _getData(),
      controller: scrollController,
    );
  }

  Widget _getHotCityList() {
    return new Container(
        padding: const EdgeInsets.only(right: 20.0),
        child: new Column(
          children: _getHotCityItem(),
        ));
  }

  List<Widget> _getHotCityItem() {
    //热门城市先计算行数，每行高度为tileHeight，这样方便计算滚动位置
    int rowNum = 3; //每行3列
    int columnNum = 1;
    columnNum = (china_cities_hot_data.length % rowNum > 0)
        ? (china_cities_hot_data.length / rowNum + 1).toInt()
        : (china_cities_hot_data.length / rowNum).toInt();
    if (columnNum >= 1) {
      hotCityHeightScale = columnNum;
    }
    List<Widget> arr = new List();
    for (int i = 0; i < columnNum; i++) {
      List<Widget> row = new List();
      for (int j = 0; j < rowNum; j++) {
        if ((i * rowNum + j) <= (china_cities_hot_data.length - 1)) {
          row.add(new GestureDetector(
            child: new Container(
              alignment: Alignment.center,
              color: Colors.grey[200],
              child: new Text(china_cities_hot_data[i * rowNum + j]["name"]),
              width: 76.0,
              height: 32.0,
            ),
            onTap: () {
              _onTileClick(china_cities_hot_data[i * rowNum + j]["name"]);
            },
          ));
        } else {
          //补充空缺位
          row.add(new Container(
            width: 76.0,
            height: 32.0,
          ));
        }
      }
      arr.add(new Container(
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: row,
        ),
        height: tileHeight,
      ));
    }

    return arr;
  }

  //字母选择列表
  Widget _getWordSelectWidget() {
    return new SizedBox(
      child: new ListView.builder(
        itemBuilder: (BuildContext c, int index) {
          return new GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (TapUpDetails detail) {
              _setUpWordUpState();
            },
            onTapDown: (TapDownDetails detail) {
              _setUpWordDownState(cityUpWordArr[index]);
            },
            onVerticalDragUpdate: (DragUpdateDetails detail) {
              _setSlideState(detail.globalPosition.dy);
            },
            onVerticalDragEnd: (DragEndDetails detail) {
              _setUpWordUpState();
            },
            child: new Container(
              height: selectUpWordTileHeight,
              alignment: Alignment.center,
              child: new Text(_isHotCityDes(cityUpWordArr[index])
                  ? Strings.HOT_CITY_UP_WORD
                  : (_isLocationCityDes(cityUpWordArr[index])
                      ? Strings.LOCATION_CITY_UP_WORD
                      : cityUpWordArr[index])),
            ),
          );
        },
        itemCount: cityUpWordArr.length,
      ),
      width: 44.0,
    );
  }

  //中心弹出内容
  Widget _getShowSelectedCenterWidget() {
    if (selectedUpWord.length > 0) {
      return new Center(
        child: new Container(
          color: Colors.grey,
          child: new SizedBox(
            width: 100.0,
            height: 100.0,
            child: new Center(
              child: new Text(
                selectedUpWord,
                style: new TextStyle(color: Colors.white, fontSize: 50.0),
              ),
            ),
          ),
        ),
      );
    }
    return new Container();
  }

  _setUpWordDownState(String name) {
    debugPrint("Select Word---" + name);

    setState(() {
      selectedUpWord = name;
    });

    _setScrollToWord(name);
  }

  _setUpWordUpState() {
    setState(() {
      selectedUpWord = "";
    });
  }

  //这里要用当前滑到的位置除以高度；计算出滑动到哪个字母了
  _setSlideState(double globalPosition) {
    double minHeight = appBarHeight;
    double maxHeight =
        cityUpWordArr.length * selectUpWordTileHeight + appBarHeight;
    if (globalPosition >= minHeight && globalPosition <= maxHeight) {
      double index = (globalPosition - appBarHeight) / selectUpWordTileHeight;
      if (index >= 0) {
        String slideToWord = cityUpWordArr[index.toInt()];

        if (curSelectedUpWord != slideToWord) {
          //防止重复animateTo动画
          debugPrint("Slide Word To---" + slideToWord);
          setState(() {
            selectedUpWord = slideToWord;
          });
          _setScrollToWord(slideToWord);
          curSelectedUpWord = slideToWord;
        }
      }
    }
  }

  _setScrollToWord(String word) {
    double value = 0.0;
    if (cityUpWordArr.indexOf(word) == 0) {
      //最上层
    } else {
      //热门城市以下的布局都需要补偿热门城市布局内的额外高度
      value = (cityUpWordStartIndex[word] +
                  (hotCityHeightScale - 1) * (_isHotCityDes(word) ? 0 : 1)) *
              tileHeight +
          cityUpWordArr.indexOf(word) * tileTileHeight;
    }
    //滚动到指定位置
    scrollController.animateTo(value,
        duration: new Duration(milliseconds: 10), curve: Curves.ease);
  }

  List<Widget> _getData() {
    List<Widget> arr = new List();
    for (int i = 0; i < china_cities_data.length; i++) {
      String currentFLetter = getFirstLetter(china_cities_data[i]["pinyin"]);
      String preFLetter =
          i >= 1 ? getFirstLetter(china_cities_data[i - 1]["pinyin"]) : "";

      if (currentFLetter != preFLetter) {
        String tempTitle = currentFLetter;
        if (_isHotCityDes(tempTitle)) {
          tempTitle = Strings.HOT_CITY_TITLE;
        } else if (_isLocationCityDes(tempTitle)) {
          tempTitle = Strings.LOCATION_CITY_TITLE;
        }
        //多加一行首字母
        arr.add(new Container(
          alignment: Alignment.centerLeft,
          color: Colors.grey[200],
          height: tileTileHeight,
          padding: const EdgeInsets.only(left: 24.0),
          child: new Text(tempTitle),
        ));
      }

      if (_isHotCityDes(currentFLetter)) {
        //热门城市内容
        arr.add(_getHotCityList());
      } else {
        //添加城市名称布局
        arr.add(new GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: new Container(
            height: tileHeight,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 24.0),
            child: new Text(china_cities_data[i]["name"]),
          ),
          onTap: () {
            _onTileClick(china_cities_data[i]["name"]);
          },
        ));
      }
    }
    return arr;
  }

  _onTileClick(String name) {
    Navigator.of(context).pop(name);
  }

  //获取拼音的首字母（大写）
  String getFirstLetter(String pinyin) {
    return pinyin.substring(0, 1).toUpperCase();
  }

  bool _isHotCityDes(String pinyin) {
    return pinyin == "0";
  }

  bool _isLocationCityDes(String pinyin) {
    return pinyin == "1";
  }
}
