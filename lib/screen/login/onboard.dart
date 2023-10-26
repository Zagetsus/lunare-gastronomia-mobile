import 'package:flutter/material.dart';
import 'package:labella_app/screen/login/login.dart';
import 'package:video_player/video_player.dart';

class Onboard extends StatefulWidget {
  @override
  _OnboardState createState() => _OnboardState();
}

class _OnboardState extends State<Onboard> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/video/onboard.mp4')
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
    _controller.setLooping(true);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size?.width ?? 0,
                height: _controller.value.size?.height ?? 0,
                child: GestureDetector(
                  onTap: _handleTap,
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 24, right: 24, bottom: 24, top: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(),
                    child: SizedBox(
                      width: 500,
                      child: Text(
                        "Lunare Gastronomia",
                        textAlign: TextAlign.left,
                        textDirection: TextDirection.ltr,
                        style: TextStyle(
                          height: 1.1,
                          letterSpacing: 0.5,
                          color: Colors.white,
                          fontSize: 38.0,
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                                offset: Offset(-1.5, -1.5),
                                color: Colors.black
                            ),
                            Shadow(
                                offset: Offset(1.5, -1.5),
                                color: Colors.black
                            ),
                            Shadow(
                                offset: Offset(1.5, 1.5),
                                color: Colors.black
                            ),
                            Shadow(
                                offset: Offset(-1.5, 1.5),
                                color: Colors.black
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 32, bottom: 36),
                    child: MaterialButton(
                      color: Color.fromRGBO(139, 0, 0, 1.000),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100)),
                      onPressed: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Login()),
                        );
                      },
                      height: 50,
                      minWidth: 500,
                      child: Padding(
                        padding: EdgeInsets.only(left: 32, right: 32),
                        child: Text(
                          'Começar',
                          style: TextStyle(
                              fontFamily: 'Circular Medium',
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              fontSize: 18),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _handleTap() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }
}
