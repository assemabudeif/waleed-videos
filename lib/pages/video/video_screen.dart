import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({Key? key, required this.url}) : super(key: key);
  final String url;

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late VideoPlayerController _controller;

  late InAppWebViewController _inAppWebViewController;
  double _progress = 0;
  Duration? position;
  StreamSubscription? _positionSubscription;
  bool isMusicOn = true;

  @override
  void initState() {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..addListener(() {
        getCurrentPosition();
      })
      ..initialize().then((_) {
        setState(() {});
      });
    setPortrait();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    setAllOrientations();
  }

  getCurrentPosition() {
    if (_controller.value.isInitialized) {
      _positionSubscription = _controller.position.asStream().listen((p) {
        setState(() {
          log(p!.inSeconds.toString());
          position = p;
        });
      });
    }
  }

  Future setPortrait() async {
    // hide overlays statusbar
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: []);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    await Wakelock.enable(); // keep device awake
  }

  Future setAllOrientations() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    await SystemChrome.setPreferredOrientations(DeviceOrientation.values);

    await Wakelock.disable();
  }

  String getPosition() {
    Duration duration = Duration(
        milliseconds: _controller.value.position.inMilliseconds.round());

    return [
      position?.inHours ?? 00,
      position?.inMinutes ?? 00,
      position?.inSeconds ?? 0
    ].map((seg) => seg.remainder(60).toString().padLeft(2, '0')).join(':');
  }

  String getDuration() {
    Duration duration = Duration(
        milliseconds: _controller.value.duration.inMilliseconds.round());

    return [duration.inHours, duration.inMinutes, duration.inSeconds]
        .map((seg) => seg.remainder(60).toString().padLeft(2, '0'))
        .join(':');
  }

  void soundToggle() {
    setState(() {
      isMusicOn == false
          ? _controller.setVolume(0.0)
          : _controller.setVolume(1.0);
      isMusicOn = !isMusicOn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Stack(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _controller.value.isPlaying
                          ? _controller.pause()
                          : _controller.play();
                    });
                  },
                  child: Center(
                    child: _controller.value.isInitialized
                        ? SizedBox(
                            height: MediaQuery.sizeOf(context).height,
                            child: AspectRatio(
                              aspectRatio: _controller.value.aspectRatio,
                              child: VideoPlayer(_controller),
                            ),
                          )
                        : Container(),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      _controller.value.isPlaying
                          ? _controller.pause()
                          : _controller.play();
                    });
                  },
                  child: Align(
                    alignment: Alignment.center,
                    child: Icon(
                      _controller.value.isPlaying ? null : Icons.play_arrow,
                      size: MediaQuery.sizeOf(context).height * 0.25,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Visibility(
                    visible: _controller.value.isBuffering,
                    child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor.withOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    getPosition(),
                  ),
                  Text(
                    getDuration(),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: VideoProgressIndicator(
                _controller,
                allowScrubbing: true,
                colors: VideoProgressColors(
                  playedColor: Theme.of(context).primaryColor,
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 0,
              child: IconButton(
                onPressed: () {
                  soundToggle();
                },
                icon: Icon(
                  isMusicOn ? Icons.volume_up : Icons.volume_off,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
