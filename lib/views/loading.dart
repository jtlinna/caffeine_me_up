import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  final double size;
  final Color color;

  Loading({this.size = 50.0, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color ?? Theme.of(context).backgroundColor,
      child: Center(
        child: SpinKitChasingDots(
          color: Theme.of(context).primaryColor,
          size: size,
        ),
      ),
    );
  }
}
