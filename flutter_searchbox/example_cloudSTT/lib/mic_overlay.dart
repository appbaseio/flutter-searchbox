import 'package:flutter/material.dart';

// This widget is used to display the mic icon with the animation, audio recording & conversion status
// and transformed output text back from the Google STT server
class MicOverlay extends StatefulWidget {
  final String value;
  const MicOverlay({Key key, this.value = ''})
      : assert(value != null),
        super(key: key);

  @override
  _MicOverlayState createState() => _MicOverlayState();
}

class _MicOverlayState extends State<MicOverlay>
    with SingleTickerProviderStateMixin {
  var _width, _height;

  AnimationController _animationController;
  Animation _animation;

  // initialising the _animationController and setting up the animation for the recording icon
  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    _animationController.repeat(reverse: true);
    _animation = Tween(begin: 2.0, end: 15.0).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });
    super.initState();
  }

  // disposing the animation controller when this widget gets disposed
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // checking the size of the current media to set the overlay size accordingly
    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;
    return Container(
      alignment: Alignment.topCenter,
      padding: new EdgeInsets.only(top: _height * .35, right: 20.0, left: 20.0),
      child: Container(
        height: _width * .65,
        width: _width * .65,
        child: Card(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.white70, width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          color: Colors.white,
          elevation: 4.0,
          child: Column(
            children: [
              // to display the icon
              Expanded(
                flex: 4,
                child: Container(
                  height: 75,
                  width: 75,
                  child: Icon(
                    Icons.mic,
                    color: Colors.white,
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.lightBlue,
                          blurRadius: _animation.value,
                          spreadRadius: _animation.value),
                    ],
                  ),
                ),
              ),
              // to display the text
              Expanded(
                flex: 3,
                child: Container(
                  height: 50,
                  width: _width * .5,
                  child: Center(
                    child: RichText(
                      text: TextSpan(
                        text: widget.value,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
