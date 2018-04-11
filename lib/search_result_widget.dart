import 'package:china_city_selector/strings.dart';
import 'package:flutter/material.dart';

class SearchResultWidget extends StatefulWidget {
  List<Map> searchMap = new List();

  SearchResultWidget(this.searchMap);

  @override
  _SearchResultWidgetState createState() => new _SearchResultWidgetState();
}

class _SearchResultWidgetState extends State<SearchResultWidget> {
  @override
  Widget build(BuildContext context) {
    return _getContentWidget();
  }

  Widget _getContentWidget() {
    if (widget.searchMap.length > 0) {
      return new ListView.builder(
        itemBuilder: (BuildContext c, int index) {
          return new GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: new Container(
              height: Values.TILE_HEIGHT,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 24.0),
              child: new Text(widget.searchMap[index]["name"]),
            ),
            onTap: () {
              _onTileClick(widget.searchMap[index]["name"]);
            },
          );
        },
        itemCount: widget.searchMap.length,
      );
    } else {
      return new Center(
        child: new Text(Strings.DATA_NONE),
      );
    }
  }

  _onTileClick(String name) {
    Navigator.of(context).pop(name);
  }
}
