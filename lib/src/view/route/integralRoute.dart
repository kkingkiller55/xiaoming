import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xiaoming/src/command/cmdMethod.dart';
import 'package:xiaoming/src/data/appData.dart';
import 'package:xiaoming/src/data/settingData.dart';
import 'package:xiaoming/src/language/xiaomingLocalizations.dart';
import 'dart:async';

class IntegralRoute extends StatefulWidget {
  @override
  _IntegralRouteState createState() => _IntegralRouteState();
}

class _IntegralRouteState extends State<IntegralRoute> {
  TextEditingController _dController;
  TextEditingController _pController;
  TextEditingController _iController;
  String result = '';
  bool isReady = true;

  @override
  void initState() {
    _dController = TextEditingController();
    _pController = TextEditingController();
    _iController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    UserData.nowPage = 1;
    UserData.pageContext = context;

    Future<String> getResult() async {
      if (_dController.text.length == 0 ||
          _pController.text.length == 0 ||
          _iController.text.length == 0) {
        return "积分函数，积分变量，积分区间都不能为空！";
      }
      if (!_iController.text.contains(',')) {
        return "请用逗号分隔积分区间";
      }
      UserFunction uf = UserFunction("__temp__", _pController.text.split(','),
          _dController.text.split(";"));
      int a = int.tryParse(_iController.text.split(',')[0]);
      int b = int.tryParse(_iController.text.split(',')[1]);
      if (a == null || b == null) {
        return "积分区间必须为整数";
      }
      num r = await CmdMethodUtil.handleCalculate(uf, a, b);
      return "积分结果为：  " + r.toStringAsFixed(SettingData.fixedNum.round());
    }

    return DefaultTextStyle(
      style: TextStyle(
        fontFamily: '.SF UI Text',
        inherit: false,
        fontSize: 17.0,
        color: CupertinoColors.black,
      ),
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(XiaomingLocalizations.of(context).definiteIntegral),
          previousPageTitle: "Functions",
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {},
            child: Icon(CupertinoIcons.info),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(12.0),
          child: ListView(
            children: <Widget>[
              SizedBox(
                height: 80.0,
              ),
              Container(
                //方程输入窗口
                padding: EdgeInsets.only(left: 12.0, bottom: 50.0),
                child: CupertinoTextField(
                  clearButtonMode: OverlayVisibilityMode.editing,
                  controller: _dController,
                  textCapitalization: TextCapitalization.words,
                  decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            width: 0.0, color: CupertinoColors.black)),
                  ),
                  placeholder:
                      XiaomingLocalizations.of(context).integralFunction,
                ),
              ),
              Container(
                padding: EdgeInsets.only(
                  left: 12.0,
                  bottom: 50.0,
                ),
                child: CupertinoTextField(
                  clearButtonMode: OverlayVisibilityMode.editing,
                  controller: _pController,
                  textCapitalization: TextCapitalization.words,
                  decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            width: 0.0, color: CupertinoColors.black)),
                  ),
                  placeholder:
                      XiaomingLocalizations.of(context).integralVariable,
                ),
              ),
              Container(
                padding: EdgeInsets.only(
                  left: 12.0,
                  bottom: 50.0,
                ),
                child: CupertinoTextField(
                  clearButtonMode: OverlayVisibilityMode.editing,
                  controller: _iController,
                  textCapitalization: TextCapitalization.words,
                  decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            width: 0.0, color: CupertinoColors.black)),
                  ),
                  placeholder: XiaomingLocalizations.of(context).integralRange +
                      '  ps: 3,5',
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 50.0,
                  vertical: 20.0,
                ),
                child: CupertinoButton(
                  color: Colors.blue,
                  onPressed: () {
                    setState(() {
                      isReady = false;
                    });
                    getResult().then((str) {
                      setState(() {
                        result = str;
                        isReady = true;
                      });
                    });
                  },
                  child: Text(XiaomingLocalizations.of(context).calculate),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 40.0),
                child: Center(
                  child: isReady
                      ? GestureDetector(
                          onLongPress: () {
                            Clipboard.setData(new ClipboardData(text: result));
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CupertinoAlertDialog(
                                    title: Text(
                                        XiaomingLocalizations.of(context)
                                            .copyHint),
                                  );
                                });
                          },
                          child: Text(
                            result,
                            style:
                                TextStyle(color: Colors.purple, fontSize: 20.0),
                          ),
                        )
                      : Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                        CupertinoActivityIndicator(),
                        Text("正在计算中"),
                      ],),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _dController.dispose();
    _pController.dispose();
    _iController.dispose();
    super.dispose();
  }
}