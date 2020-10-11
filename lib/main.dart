import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:camera/camera.dart';
import 'home.dart';

List<CameraDescription> cameras;

// IOS용 테마
final ThemeData kIOSTheme = ThemeData(
    primarySwatch: Colors.orange,
    primaryColor: Colors.grey[100],
    primaryColorBrightness: Brightness.light);

// 기본 테마
final ThemeData kDefaultTheme = ThemeData(
  primarySwatch: Colors.purple,
  // 전송버튼에 적용할 색상으로 이용
  accentColor: Colors.orangeAccent[400],
);

Future<Null> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error: $e.code\nError Message: $e.message');
  }
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Inspector',
      theme: defaultTargetPlatform == TargetPlatform.iOS
          ? kIOSTheme
          : kDefaultTheme,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Sir.Manda'),
        ),
        body: HomePage(cameras),
      ),
    );
  }

  void showInSnackBar(String message) {
    scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }
}
