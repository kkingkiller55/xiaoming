import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:provide/provide.dart';
import 'package:sqflite/sqflite.dart';
import 'package:xiaoming/src/data/appData.dart';
import 'package:xiaoming/src/data/dbUtil.dart';
import 'package:xiaoming/src/data/settingData.dart';
import 'package:xiaoming/src/language/xiaomingLocalizations.dart';
import 'package:xiaoming/src/view/widget/myButtons.dart';
import 'package:xiaoming/src/view/widget/myTextView.dart';

class HomeRoute extends StatefulWidget {
  HomeRoute({Key key}) : super(key: key);

  @override
  HomeRouteState createState() => new HomeRouteState();
}

class HomeRouteState extends State<HomeRoute> with TickerProviderStateMixin {
  TextEditingController _textController; // _textController用来获取输入文本和控制输入焦点
  FocusNode _textFocusNode; // _textFocusNode用来控制键盘弹出/收回
  static List<TextView> _texts = <TextView>[]; //存储消息的列表
  bool _isComposing = false; //判断是否有输入
  bool _buttonsIsVisible = false; //控制便捷输入栏显示与隐藏
  double tabHeight; //输入框底部高度（防止被底部导航栏遮挡）
  bool isComplete = true; //计算是否完成
  static bool isUnload = true; //历史消息是否加载
  UserData ud;

  ///初始化对象及加载数据
  @override
  void initState() {
    if (isUnload) readText();
    UserData.nowPage = 0;
    SettingData.readSettingData(); //读取设置数据
    _textController = new TextEditingController();
    _textFocusNode = new FocusNode();

    ///添加虚拟键盘事件监听器
    KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible) {
        if (visible) {
          setState(() {
            tabHeight = 0.0;
            _buttonsIsVisible = true;
          });
        } else {
          setState(() {
            tabHeight = MediaQuery.of(context).padding.bottom;
            _buttonsIsVisible = false;
          });
        }
      },
    );

    super.initState();
  }

  ///home界面布局
  @override
  Widget build(BuildContext context) {
    ud = Provide.value<UserData>(context);
    //记录当前语言
    UserData.language = Localizations.localeOf(context).languageCode;
    tabHeight = MediaQuery.of(context).padding.bottom; //初始化底部导航栏高度

    ///处理发送按钮的点击事件
    void _handleSubmitted(String text) async {
      _textController.clear();
      setState(() {
        _isComposing = false;
        isComplete = false;
      });
      String handleText = await ud.handleCommand(text);
      DBUtil.addMessage(text);
      DBUtil.addMessage(handleText);
      TextView textView1 = new TextView(
          text: text,
          context: context,
          animationController: new AnimationController(
              duration: new Duration(milliseconds: 200), vsync: this));
      TextView textView2 = new TextView(
          text: handleText,
          context: context,
          animationController: new AnimationController(
              duration: new Duration(milliseconds: 200), vsync: this));
      setState(() {
        isComplete = true;
        _texts.insert(0, textView1);
        _texts.insert(0, textView2);
      });

      textView1.animationController.forward();
      textView2.animationController.forward();
    }

    ///输入框和发送按钮
    Widget _textComposer = Row(children: <Widget>[
      SizedBox(
        width: 10.0,
      ),
      Flexible(
        child: CupertinoTextField(
          focusNode: _textFocusNode,
          maxLines: 1,
          placeholder: 'Input Command',
          controller: _textController,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(
              color: CupertinoColors.inactiveGray,
              width: 0.0,
            ),
          ),
          onChanged: (String text) {
            setState(() {
              _isComposing = text.length > 0;
            });
          },
          onSubmitted: _handleSubmitted,
        ),
      ),
      new Container(
        margin: new EdgeInsets.symmetric(horizontal: 4.0),
        child: new CupertinoButton(
          child: new Icon(CupertinoIcons.forward),
          onPressed: _isComposing
              ? () => _handleSubmitted(_textController.text)
              : null,
        ),
      ),
    ]);

    ///消息列表，未加载完成时显示加载中动画
    Widget _buildList() {
      if (isUnload) {
        return Center(child: CupertinoActivityIndicator());
      } else {
        if (isComplete) {
          return Column(
            children: <Widget>[
              new Flexible(
                  child: new GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        _textFocusNode.unfocus();
                      },
                      child: ListView(
                        padding: new EdgeInsets.only(left: 5.0),
                        reverse: true,
                        children: _texts,
                      ))),
              new Divider(
                height: _buttonsIsVisible ? 1.0 : 0.0,
                color: _buttonsIsVisible ? Colors.black : null,
              ),
              new Container(
                decoration: new BoxDecoration(
                  color: Theme.of(context).cardColor,
                ),
                child: Container(
                  height: _buttonsIsVisible ? 200.0 : 0.0,
                  child: _buildButtons(),
                ),
              ),
              new Divider(height: 1.0),
              new Container(
                decoration: new BoxDecoration(
                  color: Theme.of(context).cardColor,
                ),
                child: _textComposer,
              ),
              new SizedBox(
                height: tabHeight,
              ),
            ],
          );
        } else {
          return Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CupertinoActivityIndicator(),
              Text("正在计算中"),
            ],
          ));
        }
      }
    }

    ///删除所有交互命令
    void _deleteAllMessage() {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text(XiaomingLocalizations.of(context).deleteAllMessage),
              actions: <Widget>[
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  child: Text(XiaomingLocalizations.of(context).delete),
                  onPressed: () {
                    setState(() {
                      _texts.clear();
                    });
                    DBUtil.deleteAllMessage();
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                ),
                CupertinoDialogAction(
                  child: Text(XiaomingLocalizations.of(context).cancel),
                  onPressed: () =>
                      Navigator.of(context, rootNavigator: true).pop(),
                )
              ],
            );
          });
    }

    ///主界面布局
    return DefaultTextStyle(
      style: const TextStyle(
        fontFamily: '.SF UI Text',
        inherit: false,
        fontSize: 17.0,
        color: CupertinoColors.black,
      ),
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          trailing: buildTrailingBar(<Widget>[
            buildHelpButton(context),
            const SizedBox(
              width: 8.0,
            ),
            SettingButton(_deleteAllMessage),
          ]),
          middle: Text("Home"),
        ),
        resizeToAvoidBottomInset: true,
        child: _buildList(),
      ),
    );
  }

  ///创建便捷输入按钮
  Widget _buildTextButton(String label, {double width = 50.0}) {
    return LimitedBox(
      maxWidth: width,
      child: new FlatButton(
        padding: const EdgeInsets.all(0.0),
        onPressed: () => _handleTextButton(label),
        child: new Text(label, style: new TextStyle(fontSize: 14.0)),
      ),
    );
  }

  ///创建方便输入的按钮栏
  Widget _buildButtons() {
    return Column(children: <Widget>[
      Flexible(
        child: CupertinoScrollbar(
          child: _buildMethodButtons(),
        ),
      ),
      Divider(height: 1.0),
      LimitedBox(
        maxHeight: 40,
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildTextButton(','),
            _buildTextButton(';'),
            _buildTextButton(':'),
            _buildTextButton('['),
            _buildTextButton('='),
            _buildTextButton('('),
          ],
        ),
      ),
      Divider(height: 1.0),
      LimitedBox(
        maxHeight: 40,
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildTextButton('^'),
            _buildTextButton('+'),
            _buildTextButton('-'),
            _buildTextButton('*'),
            _buildTextButton('/'),
          ],
        ),
      ),
    ]);
  }

  ///构造方法按钮列表
  Widget _buildMethodButtons() {
    return Provide<UserData>(
      builder: (context, child, ud) {
        List<Widget> list = [];
        if (ud.userFunctions.isNotEmpty) {
          int i = 0;
          var blist = <Widget>[];
          ud.userFunctions.forEach((u) {
            blist
                .add(_buildTextButton(u.funName + '(', width: double.infinity));
            i++;
            if (i == 4) {
              list.add(Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: blist,
              ));
              blist.clear();
              i = 0;
            }
          });
          if (i != 0) {
            list.add(Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: blist,
            ));
          }
        }
        list
          ..add(Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildTextButton('Fun', width: double.infinity),
              _buildTextButton('inv(', width: double.infinity),
              _buildTextButton('tran(', width: double.infinity),
              _buildTextButton('value(', width: double.infinity),
            ],
          ))
          ..add(Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildTextButton('upmat(', width: double.infinity),
              _buildTextButton('cofa(', width: double.infinity),
              _buildTextButton('calculus(', width: double.infinity),
              _buildTextButton('roots(', width: double.infinity),
            ],
          ))
          ..add(Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildTextButton('sum(', width: double.infinity),
              _buildTextButton('average(', width: double.infinity),
              _buildTextButton('factorial(', width: double.infinity),
              _buildTextButton('sin(', width: double.infinity),
            ],
          ))
          ..add(Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildTextButton('cos(', width: double.infinity),
              _buildTextButton('tan(', width: double.infinity),
              _buildTextButton('asin(', width: double.infinity),
              _buildTextButton('acos(', width: double.infinity),
            ],
          ))
          ..add(Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildTextButton('atan(', width: double.infinity),
              _buildTextButton('formatDeg(', width: double.infinity),
              _buildTextButton('reForDeg(', width: double.infinity),
              _buildTextButton('absSum(', width: double.infinity),
            ],
          ))
          ..add(Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildTextButton('absAverage(', width: double.infinity),
              _buildTextButton('radToDeg(', width: double.infinity),
              _buildTextButton('lagrange(', width: double.infinity),
            ],
          ));
        return ListView(
          reverse: true,
          children: list,
        );
      },
    );
  }

  /// 处理便捷输入按钮的点击事件
  void _handleTextButton(String text) {
    int temp = 0;
    String bracket = text.substring(text.length - 1);
    if (bracket == '(') {
      text = text + ')';
      temp = 1;
    } else if (bracket == '[') {
      text = text + ']';
      temp = 1;
    }
    if (_textController.selection.isValid) {
      int index = _textController.value.selection.extentOffset;
      String newStr = _textController.text.substring(0, index) +
          text +
          _textController.text.substring(index, _textController.text.length);
      setState(() {
        _isComposing = true;
      });
      _textController.value = new TextEditingValue(
        text: newStr,
        selection:
            new TextSelection.collapsed(offset: index + text.length - temp),
      );
    } else {
      _textController.value = new TextEditingValue(
        text: text,
        selection: new TextSelection.collapsed(offset: text.length - temp),
      );
    }
  }

  ///退出该路由时释放动画资源
  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
    _textFocusNode.dispose();
    for (TextView textView in _texts) {
      textView.animationController.dispose();
    }
    _textFocusNode.dispose();
  }

  ///加载数据库中的历史数据
  Future readText() async {
    Database db = await DBUtil.getDB();
    var list = await db.rawQuery('select * from Message');
    list.forEach((m) {
      var textView = TextView(
        context: context,
        text: m['msg'],
        animationController: AnimationController(
            duration: new Duration(milliseconds: 200), vsync: this),
      );
      _texts.insert(0, textView);
      textView.animationController.forward();
    });
    setState(() {
      isUnload = false;
    });
  }
}
