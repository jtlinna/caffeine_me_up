import 'package:flutter/material.dart';

class HomeCard extends StatelessWidget {
  final String image;
  final String label;
  final Function onPressed;

  HomeCard({this.image, this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
        height: 150,
        minWidth: 150,
        child: RaisedButton(
          onPressed: onPressed,
          color: Theme.of(context).accentColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Column(children: <Widget>[
            Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: 100,
                height: 100,
                child: Image.asset(image),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                label,
                style: TextStyle(fontSize: 27, color: Colors.white),
              ),
            )
          ]),
        ));
  }
}
