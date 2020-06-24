import 'dart:math';
import 'dart:ui';

import 'package:file_manager_web/dirMapping.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'File Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'File Manager'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _Colors {
  static Color background = Color(0x00000000);
  static Color iconColor = Color(0xffffffff);
  static Color subIcon = Color(0xffbec4ca);
  static Color subIconActive = Color(0xff27cff1);
  static Color subBackground = Color(0xfff6f6f6);
  static Color subTextColor = Color(0xff71777a);
  static Color subHintTextColor = Color(0xffc5cacd);
  static Color dirColor = Color(0xfff6d334);
  static Color fileColor = Color(0xff27cff1);
  static Color dirSize = Color(0xff27cff1);
  static Color dirSizeBackground = Color(0xffe8e8e8);
  static Color infoBackground = Color(0x99000000);
  static Color infoText = Color(0xffffffff);
  static Color infoDivider = Color(0xffffffff);
}

class _MyHomePageState extends State<MyHomePage> {
  bool isFullScreen = false;
  bool isUpPressed = false;
  bool isBackPressed = false;
  bool isForwardPressed = false;
  bool hideInfo = false;
  TextEditingController _searchController = new TextEditingController();
  final List<List<String>> backPathList = [];
  final List<List<String>> forwardPathList = [];
  final List<String> pathList = [""];
  final Map<String, dynamic> currentDirData = {};

  void forwardBackHandler() {
    if (isBackPressed && backPathList.length > 0) {
      List<String> pathListClone = [];
      pathListClone.addAll(pathList);
      List<String> d = backPathList.last;
      pathList.clear();
      pathList.addAll(d);
      forwardPathList.add(pathListClone);
      backPathList.removeLast();
    } else if (isForwardPressed && forwardPathList.length > 0) {
      List<String> pathListClone = [];
      pathListClone.addAll(pathList);
      List<String> d = forwardPathList.last;
      pathList.clear();
      pathList.addAll(d);
      backPathList.add(pathListClone);
      forwardPathList.removeLast();
    } else {
      if (backPathList.length > 0 && pathList == backPathList.last) return;
      List<String> pathListClone = [];
      pathListClone.addAll(pathList);
      backPathList.add(pathListClone);
      forwardPathList.clear();
    }

    isBackPressed = false;
    isForwardPressed = false;
    isUpPressed = false;
  }

  Map<String, dynamic> currentMap = DirMap.a();

  void loadDirData() {
    currentMap = DirMap.a();
    List<String> newPathList = [];
    String currentPath =
        "/Users/luckycreations/AndroidStudioProjects/flutter/file_manager_web";
    for (int i = 5; i < pathList.length; i++) {
      newPathList.add(pathList[i]);
    }
    newPathList.forEach((p) {
      currentPath += "/$p";
      List c = currentMap['children'];
      c.forEach((x) {
        if (x['path'] == currentPath) {
          currentMap = x;
          return null;
        }
      });
    });

    currentDirData['name'] = currentMap['name'];
    currentDirData['size'] = currentMap['size'];
    currentDirData['type'] = currentMap['type'];
    currentDirData['path'] = currentMap['path'];
    currentDirData['extension'] = currentMap['extension'];
    currentDirData['childrens'] = currentMap['children'].length;
    currentDirData['sizeUsed'] = 23;
  }

  @override
  void initState() {
    pathList.clear();
    pathList.add("Users");
    pathList.add("luckycreations");
    pathList.add("AndroidStudioProjects");
    pathList.add("flutter");
    pathList.add("file_manager_web");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    loadDirData();
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      padding: isFullScreen ? EdgeInsets.zero : EdgeInsets.all(100),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/bg.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: new BackdropFilter(
        filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Center(
          child: Container(
            child: Scaffold(
              backgroundColor: _Colors.background,
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.white30,
                title: Text(widget.title),
                actions: [
                  IconButton(
                    icon: Icon(
                      isFullScreen
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_up,
                      color: _Colors.iconColor,
                    ),
                    onPressed: () {
                      setState(() {
                        isFullScreen = !isFullScreen;
                      });
                    },
                  ),
                ],
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    getSecondAppBar(),
                    Expanded(
                      child: Container(
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                color: Colors.white,
                                child: Row(
                                  children: [
                                    getQuickAccessWidget(),
                                    VerticalDivider(
                                      color: _Colors.subIcon,
                                      thickness: 1,
                                      width: 1,
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: double.maxFinite,
                                        width: double.maxFinite,
                                        child: currentDirData.length > 0
                                            ? folderList()
                                            : Center(
                                                child: Container(
                                                  child:
                                                      Text("Empty Directory"),
                                                ),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            getInfoWidget(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getSecondAppBar() {
    return Container(
      height: 60,
      color: _Colors.subBackground,
      width: double.maxFinite,
      child: Row(
        children: [
          SizedBox(
            width: 300,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: backPathList.length > 0
                        ? _Colors.subIconActive
                        : _Colors.subIcon,
                  ),
                  onPressed: () {
                    if (backPathList.length > 0)
                      setState(() {
                        isBackPressed = true;
                        forwardBackHandler();
                      });
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.arrow_forward,
                    color: forwardPathList.length > 0
                        ? _Colors.subIconActive
                        : _Colors.subIcon,
                  ),
                  onPressed: () {
                    if (forwardPathList.length > 0)
                      setState(() {
                        isForwardPressed = true;
                        forwardBackHandler();
                      });
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.arrow_upward,
                    color: currentDirData.length > 1
                        ? _Colors.subIconActive
                        : _Colors.subIcon,
                  ),
                  onPressed: () {
                    if (currentDirData.length > 1)
                      setState(() {
                        isUpPressed = true;
                        isBackPressed = true;
                        forwardBackHandler();
                      });
                  },
                ),
              ],
            ),
          ),
          VerticalDivider(
            color: _Colors.subIcon,
            thickness: 1,
            width: 1,
          ),
          getPathWidget(),
          Spacer(),
          VerticalDivider(
            color: _Colors.subIcon,
            thickness: 1,
            width: 1,
          ),
          Container(
            width: 300,
            child: TextField(
              controller: _searchController,
              onChanged: (_) {
                setState(() {});
              },
              style: TextStyle(
                fontSize: 14,
                color: _Colors.subTextColor,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                hintText: "Search in ${pathList.last}",
                hintStyle: TextStyle(
                  color: _Colors.subHintTextColor,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: _Colors.subIcon,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getPathWidget() {
    List<InlineSpan> w = [TextSpan(text: pathList[0])];
    for (int i = 1; i < pathList.length; i++) {
      w.add(TextSpan(text: " > "));
      String p = pathList[i];
      if (i == pathList.length - 1) {
        print("BOLD");
        w.add(
          TextSpan(
            text: p,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      } else {
        w.add(TextSpan(text: p));
      }
    }
    return Container(
      margin: EdgeInsets.only(
        left: 20,
        right: 20,
      ),
      child: Text.rich(
        TextSpan(
          children: w,
        ),
      ),
    );
  }

  Widget getQuickAccessWidget() {
    return Container(
      width: 300,
      child: ListView.builder(
          padding: EdgeInsets.zero,
          itemBuilder: (c, i) {
            return Container(
              child: FlatButton(
                onPressed: () {
                  setState(() {
                    forwardBackHandler();
                    pathList.clear();
                    pathList.add("sdcard");
                    //TODO pathList.add(quickAccessPathList[i]);
                  });
                },
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(
                      Icons.folder,
                      color: _Colors.dirColor,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      //TODO quickAccessPathList[i],
                      "",
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
                color: Colors.transparent,
              ),
            );
          },
          itemCount: 0 //TODO quickAccessPathList.length,
          ),
    );
  }

  Widget getInfoWidget() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      width: hideInfo ? 50 : 301,
      height: double.maxFinite,
      color: hideInfo ? Colors.white : _Colors.infoBackground,
      padding: EdgeInsets.all(hideInfo ? 0 : 20),
      child: hideInfo
          ? Container(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: IconButton(
                  icon: Icon(
                    Icons.info,
                    color: _Colors.subIcon,
                  ),
                  tooltip: 'Show Info',
                  onPressed: () {
                    setState(() {
                      hideInfo = false;
                    });
                  },
                ),
              ),
            )
          : Column(
              children: [
                Scrollbar(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(
                            top: 10,
                            bottom: 10,
                          ),
                          child: Text(
                            currentDirData['name'],
                            style: TextStyle(
                              color: _Colors.infoText,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Divider(
                          color: _Colors.infoDivider,
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            height: 150,
                            width: 150,
                            margin: EdgeInsets.only(
                              top: 10,
                              bottom: 10,
                            ),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Positioned.fill(
                                  child: Center(
                                    child: Text(
                                      "${currentDirData['sizeUsed']}%",
                                      style: TextStyle(
                                        color: _Colors.infoText,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                CircularProgressIndicator(
                                  strokeWidth: 15,
                                  value: currentDirData['sizeUsed'] / 100,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      _Colors.dirSize),
                                  backgroundColor: _Colors.dirSizeBackground
                                      .withOpacity(0.3),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Divider(
                          color: _Colors.infoDivider,
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            top: 10,
                            bottom: 10,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Total Size:",
                                style: TextStyle(
                                  color: _Colors.infoText,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                formatBytes(
                                    int.parse(
                                        currentDirData['size'].toString()),
                                    2),
                                style: TextStyle(
                                  color: _Colors.dirSize,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          ),
                        ),
                        Divider(
                          color: _Colors.infoDivider,
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            top: 10,
                            bottom: 10,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Total Items:",
                                style: TextStyle(
                                  color: _Colors.infoText,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                currentDirData['childrens'].toString(),
                                style: TextStyle(
                                  color: _Colors.dirSize,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Spacer(),
                Container(
                  margin: EdgeInsets.only(
                    top: 10,
                    bottom: 10,
                  ),
                  child: Column(
                    children: [
                      Divider(
                        color: _Colors.infoDivider,
                        thickness: 1,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total Disk Size:",
                            style: TextStyle(
                              color: _Colors.infoText,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            formatBytes(1234567890, 2),
                            style: TextStyle(
                              color: _Colors.dirSize,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.maxFinite,
                  child: Tooltip(
                    message: 'Hide Info',
                    child: FlatButton(
                      padding: EdgeInsets.all(10),
                      textColor: _Colors.infoText.withOpacity(0.5),
                      onPressed: () {
                        setState(() {
                          hideInfo = true;
                        });
                      },
                      child: Text("Hide"),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget folderList() {
    List<Widget> _dirListWidgets = [];
    Map<String, dynamic> dirList = {};
    Map<String, dynamic> filesList = {};
    List c = currentMap['children'];

    c.forEach((x) {
      String _name = x['name'];
      String _type = x['type'];
      var _searchText = _searchController.text;
      bool found = true;
      if (_searchText.isNotEmpty &&
          !(_name.contains(_searchText) || _name.startsWith(_searchText))) {
        found = false;
      }
      if (found) {
        if (_type == "directory") {
          dirList[_name] = x;
        }
        if (_type == "file") {
          filesList[_name] = x;
        }
      }
    });

    dirList.forEach((k, v) {
      var d = v[k];
      _dirListWidgets.add(
        DirFileWidget(
          title: k,
          isFile: false,
          onDoubleClick: () {
            setState(() {
              forwardBackHandler();
              pathList.add(k);
            });
          },
        ),
      );
    });
    filesList.forEach((k, v) {
      var d = v[k];
      _dirListWidgets.add(
        DirFileWidget(title: k, isFile: true),
      );
    });
    return Container(
      child: Scrollbar(
        child: GridView.count(
          crossAxisCount: hideInfo ? 5 : 4,
          children: _dirListWidgets,
        ),
      ),
    );
  }

  static String formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) +
        ' ' +
        suffixes[i];
  }
}

class DirFileWidget extends StatefulWidget {
  final String title;
  final bool isFile;
  final Function onDoubleClick;
  final Function onLongClick;

  DirFileWidget(
      {@required this.title,
      this.isFile = false,
      this.onDoubleClick,
      this.onLongClick});

  @override
  _DirFileWidgetState createState() => _DirFileWidgetState();
}

class _DirFileWidgetState extends State<DirFileWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onDoubleTap: widget.onDoubleClick,
      onLongPress: widget.onLongClick,
      child: Column(
        children: [
          Icon(
            widget.isFile ? Icons.attach_file : Icons.folder,
            color: widget.isFile ? _Colors.fileColor : _Colors.dirColor,
            size: 80,
          ),
          Container(
            width: 80,
            child: Row(
              children: [
                Container(
                  width: 60,
                  child: RichText(
                    textAlign: TextAlign.center,
                    softWrap: true,
                    text: TextSpan(
                      text: widget.title,
                      style: TextStyle(
                        color: _Colors.subTextColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 20,
                  child: PopupMenuButton<String>(
                    onSelected: (_) {
                      if (_ == "Open") widget.onDoubleClick();
                    },
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.more_vert,
                      color: _Colors.subIcon,
                    ),
                    itemBuilder: (BuildContext context) {
                      return {'Open', 'Download'}.map((String choice) {
                        return PopupMenuItem<String>(
                          value: choice,
                          child: Text(choice),
                        );
                      }).toList();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
