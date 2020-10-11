import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;

import 'camera.dart';
import 'chat.dart';
import 'message.dart';
import 'bndbox.dart';
import 'models.dart';
import 'stars.dart';

enum Quality { Best, Better, Moderate, Poor }

class HomePage extends StatefulWidget {
  final List<CameraDescription> cameras;

  HomePage(this.cameras);

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  List<dynamic> _recognitions;
  List<ChatMessage> _messages = <ChatMessage>[];
  int _imageHeight = 0;
  int _imageWidth = 0;
  String _model = teachable;
  var thisInstant = new DateTime.now();
  Map<String, dynamic> predMap = new Map();

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  loadModel() async {
    String res;
    switch (_model) {
      case yolo:
        res = await Tflite.loadModel(
          model: "assets/yolov2_tiny.tflite",
          labels: "assets/yolov2_tiny.txt",
        );
        break;

      case mobilenet:
        res = await Tflite.loadModel(
            model: "assets/mobilenet_v1_1.0_224.tflite",
            labels: "assets/mobilenet_v1_1.0_224.txt");
        break;

      case posenet:
        res = await Tflite.loadModel(
            model: "assets/posenet_mv1_075_float_from_checkpoints.tflite");
        break;

      case teachable:
        res = await Tflite.loadModel(
          model: "assets/teachable_tflite_20201004.tflite",
          labels: "assets/teachable_tflite_20201004.txt",
        );
        break;

      default:
        res = await Tflite.loadModel(
            model: "assets/ssd_mobilenet.tflite",
            labels: "assets/ssd_mobilenet.txt");
    }
    print(res);
  }

  onSelect(model) {
    setState(() {
      _model = model;
    });
    loadModel();
  }

  setRecognitions(recognitions, imageHeight, imageWidth) {
    var diff = (new DateTime.now()).difference(thisInstant).inSeconds;

    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });

    _recognitions == null ? [] : recognitions;

    for (var item in _recognitions) {
      if (!predMap.containsKey(item['label'])) {
        predMap[item['label']] = 0;
      }
      predMap[item['label']] += item['confidence'];
    }

    // 매 5초마다
    if (diff > 5) {
      var max = 0.0;
      var total = 0.0;
      var selected = '';
      predMap.forEach((k, v) {
        if (max < v) {
          max = v;
          selected = k;
        }
        total += v;
      });

      String msg = '내가 보기엔 ' +
          selected +
          ' 인 것 같네! ' +
          ((max / total) * 100).toStringAsFixed(0) +
          '% 정도 확신이 드네!';

      ChatMessage message = ChatMessage(
        text: msg,
        name: 'Sir.Manda',
        // animationController 항목에 애니메이션 효과 설정
        // ChatMessage은 UI를 가지는 위젯으로 새로운 message가 리스트뷰에 추가될 때
        // 발생할 애니메이션 효과를 위젯에 직접 부여함
        animationController: AnimationController(
          duration: Duration(milliseconds: 700),
          vsync: this,
        ),
      );

      // Window 초기화
      thisInstant = new DateTime.now();
      predMap = new Map();

      setState(() {
        _messages.insert(0, message);
      });

      // 위젯의 애니메이션 효과 발생
      message.animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
        body: _model == ""
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    RaisedButton(
                      child: const Text(ssd),
                      onPressed: () => onSelect(ssd),
                    ),
                    RaisedButton(
                      child: const Text(yolo),
                      onPressed: () => onSelect(yolo),
                    ),
                    RaisedButton(
                      child: const Text(mobilenet),
                      onPressed: () => onSelect(mobilenet),
                    ),
                    RaisedButton(
                      child: const Text(posenet),
                      onPressed: () => onSelect(posenet),
                    ),
                  ],
                ),
              )
            : Stack(children: [
                // Stars(
                //     _recognitions == null ? [] : _recognitions,
                //     math.max(_imageHeight, _imageWidth),
                //     math.min(_imageHeight, _imageWidth),
                //     screen.height,
                //     screen.width,
                //     _model),
                BndBox(
                    _recognitions == null ? [] : _recognitions,
                    math.max(_imageHeight, _imageWidth),
                    math.min(_imageHeight, _imageWidth),
                    screen.height,
                    screen.width,
                    _model),
                ChatScreen(_messages),
                Positioned(
                    right: screen.width / 30,
                    top: screen.height / 30,
                    width: screen.width / 3,
                    height: screen.height / 3,
                    child: Camera(
                      widget.cameras,
                      _model,
                      setRecognitions,
                    )),
              ]));
  }
}
