import 'package:flutter/material.dart';
import 'package:memorare/state/colors.dart';

class LoadingAnimation extends StatelessWidget {
  final String title;
  final TextStyle style;

  LoadingAnimation({
    this.style = const TextStyle(fontSize: 40.0,),
    this.title = 'Loading...',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          overflow: Overflow.visible,
          children: <Widget>[
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(stateColors.primary),
            ),

            Positioned(
              top: 5.0,
              left: 5.0,
              child: Image(
                image: AssetImage('assets/images/app-icon-32.png'),
                width: 25.0,
                height: 25.0,
              ),
            ),
          ],
        ),

        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            title,
            style: style
          ),
        ),
      ],
    );
  }
}
