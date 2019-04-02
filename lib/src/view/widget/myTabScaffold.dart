import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:xiaoming/src/data/appData.dart';
import 'package:xiaoming/src/view/route/dataRoute.dart';
import 'package:xiaoming/src/view/route/equationRoute.dart';
import 'package:xiaoming/src/view/route/homeRoute.dart';

final Widget myTabScaffold = WillPopScope(
  onWillPop: () {
    switch (UserData.nowPage){
      case 0:
        return Future.value(true);
        break;
      case 1:
        UserData.nowPage = 0;
        Navigator.pop(UserData.pageContext);
        return Future.value(false);
        break;
      case 2:
        Navigator.pop(UserData.pageContext);
        return Future.value(false);
        break;
      case 3:
        UserData.nowPage = 0;
        Navigator.pop(UserData.pageContext);
        return Future.value(false);
        break;
    }
  } ,
  child: CupertinoTabScaffold(
      tabBar: CupertinoTabBar(items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.message),
          title: Text("Home"),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.save),
          title: Text("Saved"),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.apps),
          title: Text("Equation"),
        ),
      ]),
      tabBuilder: (BuildContext context, int index) {
        switch (index) {
          case 0:
            return CupertinoTabView(builder: (BuildContext context) {
              return HomeRoute();
            });
            break;
          case 1:
            return CupertinoTabView(builder: (BuildContext context) {
              return DataRoute();
            });
          case 2:
            return CupertinoTabView(builder: (BuildContext context) {
              return EquationRoute();
            });
        }
      }),
) ;