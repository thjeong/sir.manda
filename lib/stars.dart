import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'models.dart';

class Stars extends StatelessWidget {
  final List<dynamic> results;
  final int previewH;
  final int previewW;
  final double screenH;
  final double screenW;
  final String model;

  Stars(this.results, this.previewH, this.previewW, this.screenH, this.screenW,
      this.model);

  @override
  Widget build(BuildContext context) {
    List<Widget> _renderStrings() {
      return results.map((re) {
        return Row(mainAxisSize: MainAxisSize.min, children: [
          Text(
            "${re["label"]} ${(re["confidence"] * 100).toStringAsFixed(0)}%",
            style: TextStyle(
              color: Color.fromRGBO(37, 213, 253, 1.0),
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Icon(Icons.star,
              color: re['confidence'] > 0 ? Colors.green[500] : Colors.black),
          Icon(Icons.star,
              color: re['confidence'] > 0.2 ? Colors.green[500] : Colors.black),
          Icon(Icons.star,
              color: re['confidence'] > 0.4 ? Colors.green[500] : Colors.black),
          Icon(Icons.star,
              color: re['confidence'] > 0.6 ? Colors.green[500] : Colors.black),
          Icon(Icons.star,
              color: re['confidence'] > 0.8 ? Colors.green[500] : Colors.black),
        ]);
      }).toList();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _renderStrings(),
    );
  }
}
