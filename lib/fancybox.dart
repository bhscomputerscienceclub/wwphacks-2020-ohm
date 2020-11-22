import 'package:flutter/material.dart';

class FancyBox extends StatelessWidget {
  Widget block(String text, int degree) {
    return Container(
      color: Color(
          255 * 255 * 255 * 255 + degree * 256 * 256 + (255 - degree) * 256),
      width: 150,
      height: 51,
      child: Center(
          child: Text(
        text,
        textAlign: TextAlign.center,
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      block('Good', 0),
      block('Fine', 60),
      block('Some Noise', 80),
      block('It is Noisy', 150),
      block('It is too loud', 200),
    ]);
  }
}
