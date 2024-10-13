import 'dart:async';
import 'dart:io';

import 'package:cached_video_player/cached_video_player.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class LiveMoment extends StatefulWidget {
  final String videoPath;
  final bool isNetworkVideo;
  final bool isThumbnail;

  const LiveMoment(
      {super.key,
      required this.videoPath,
      this.isNetworkVideo = true,
      this.isThumbnail = false});

  @override
  State<LiveMoment> createState() => _LiveMomentState();
}

class _LiveMomentState extends State<LiveMoment> {
  CachedVideoPlayerController? _controller;
  double _scale = 1.0;
  bool _enableLive = true;
  final UniqueKey _visibilityDetectorKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) {
        if (!widget.isThumbnail) {
          setState(() {
            _startScalingAnimation();
            _controller!.play(); // Start playing the video
          });
        }
      },
      onLongPressEnd: (_) {
        if (!widget.isThumbnail) {
          setState(() {
            _stopScalingAnimation();
            _controller!.pause(); // Pause the video
            _controller!.seekTo(Duration.zero); // Seek back to the beginning
          });
        }
      },
      child: VisibilityDetector(
        key: _visibilityDetectorKey,
        onVisibilityChanged: (visibilityInfo) {
          if (!widget.isThumbnail) {
            // The feeds is no longer visible in the viewport,
            // so re-enable live playing in order to allow
            // users to see the live moment again once they
            // go back
            if (visibilityInfo.visibleFraction == 0) {
              _enableLive = true;
            }
            // Auto play the live moment when the feed is
            // at least 50% visible in the viewport
            else if (_enableLive && visibilityInfo.visibleFraction >= 0.5) {
              _controller!.play();
              // Start a timer to pause the video after the first 1 second
              Future.delayed(const Duration(seconds: 1), () {
                if (_controller != null) {
                  if (_controller!.value.isPlaying) {
                    _controller!.pause();
                    _enableLive = false;
                  }
                }
              });
            }
          }
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            _buildVideo(),
            Transform.scale(
              scale: _scale,
              child: _buildVideo(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    _controller!.dispose();
    _controller = null;

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initVideoPlayer();
  }

  Future<void> _initVideoPlayer() async {
    // Create and store the VideoPlayerController. The VideoPlayerController
    // offers several different constructors to play videos from assets, files,
    // or the internet.
    if (widget.isNetworkVideo) {
      _controller = CachedVideoPlayerController.network(widget.videoPath);
    } else {
      _controller = CachedVideoPlayerController.file(File(widget.videoPath));
    }

    // Initialize the controller and store the Future for later use.
    await _controller!.initialize();

    // Use the controller to loop the video.
    await _controller!.setLooping(false);
    setState(() {}); // reload video to build appropriate size
  }

  Widget _buildVideo() {
    return AspectRatio(
      aspectRatio: 2 / 3,
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(25)),
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: GestureDetector(
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: CachedVideoPlayer(_controller!),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // scaling gradually upon hold
  void _startScalingAnimation() {
    const scaleTarget = 1.10;
    const animationDuration = Duration(milliseconds: 15);

    // Start a timer to gradually increase the scale
    Timer.periodic(animationDuration, (timer) {
      setState(() {
        _scale += 0.005;
        if (_scale >= scaleTarget) {
          timer.cancel();
          _scale = scaleTarget;
        }
      });
    });
  }

  // de-scaling upon release
  void _stopScalingAnimation() {
    const scaleTarget = 1.0;
    const animationDuration = Duration(milliseconds: 15);

    // Start a timer to gradually decrease the scale
    Timer.periodic(animationDuration, (timer) {
      setState(() {
        _scale -= 0.01;
        if (_scale <= scaleTarget) {
          timer.cancel();
          _scale = scaleTarget;
        }
      });
    });
  }
}
