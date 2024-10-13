import 'dart:async';
import 'dart:io';

import 'package:cached_video_player/cached_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mvp_one/providers/post_providers/create_square_post.dart';
import 'package:mvp_one/utils/dialogs/error_dialog.dart';
import 'package:mvp_one/utils/global.dart';
import 'package:provider/provider.dart';

class CheckPost extends StatefulWidget {
  final String filePath;

  const CheckPost({Key? key, required this.filePath}) : super(key: key);

  @override
  State<CheckPost> createState() => _CheckPostState();
}

class _CheckPostState extends State<CheckPost> {
  bool _isPostButtonDisabled = false;
  bool _isLoading = false;
  bool _isPlaying = false;

  late CachedVideoPlayerController _videoPlayerController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(30),
        child: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle
              .dark, // set status bar icon colors to dark mode, if not, it's hard to see icons like wifi, battery
          automaticallyImplyLeading: false,
          backgroundColor:
              Colors.transparent, // Disable appbar background color
          elevation: 0,
          centerTitle: true,
          title: const Text("NOW SHARE IT ⚡",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.w600)),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          _buildReplayVideo(),
          const SizedBox(
            height: 10.0,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Center(
                child: Text(
                  "MEET YOUR FRIENDS AT THE SQUARE",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(
                height: 7.0,
              ),
              const Center(
                child: Text(
                  "VISIBLE TO COMMUNITY TILL 12AM",
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(128, 0, 0, 0)),
                ),
              ),
              const SizedBox(
                height: 13.0,
              ),
              Container(
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: 200,
                        height: 40,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                const Color.fromARGB(255, 0, 0, 0)),
                            shape: MaterialStateProperty.all<OutlinedBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                          ),
                          onPressed: _isPostButtonDisabled
                              ? null
                              : () async {
                                  // Disable the button after it is pressed
                                  setState(() {
                                    _videoPlayerController.pause();
                                    _isPostButtonDisabled = true;
                                  });

                                  try {
                                    setState(() {
                                      // Show the loading indicator
                                      _isLoading = true;
                                    });

                                    // Create the post
                                    await _createPost();

                                    setState(() {
                                      // Hide the loading indicator
                                      _isLoading = false;
                                    });
                                  } catch (error) {
                                    if (mounted) {
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    }
                                    showErrorDialog(error.toString());
                                  }
                                },
                          child: const Text(
                            'POST NOW',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
          const SizedBox(
            height: 25.0,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initVideoPlayer();
  }

  Widget _buildReplayVideo() {
    return AspectRatio(
      aspectRatio: 2 / 3,
      child: GestureDetector(
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(30)),
              child: Container(
                decoration: BoxDecoration(color: Colors.grey.withOpacity(.4)),
              ),
            ),
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(25)),
              child: Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: GestureDetector(
                          child: AspectRatio(
                            aspectRatio:
                                _videoPlayerController.value.aspectRatio,
                            child: CachedVideoPlayer(_videoPlayerController),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Close button to return to previous screen
                  SizedBox(
                    height: 40,
                    width: 40,
                    child: IconButton(
                      onPressed: _isPostButtonDisabled
                          ? null
                          : () {
                              Navigator.pop(context);
                            },
                      icon: Image.asset('assets/icons/close_button.png'),
                    ),
                  ),

                  Positioned(
                      bottom: 25,
                      left: 0,
                      right: 0,
                      child: Container(
                          width: 190,
                          height: 40,
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Back button
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      30), // Adjust the radius as needed
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            30), // Match the parent ClipRRect's borderRadius
                                        color: Colors.white.withOpacity(0.6),
                                        border: Border.all(
                                            color: Colors.white, width: 1)),
                                    child: SizedBox(
                                      width: 60,
                                      child: ElevatedButton(
                                        onPressed: _isPostButtonDisabled
                                            ? null
                                            : () {
                                                Navigator.pop(context);
                                              },
                                        style: ElevatedButton.styleFrom(
                                          primary: Colors.transparent,
                                          elevation: 0,
                                        ),
                                        child: Image.asset(
                                            'assets/icons/trash_button.png'),
                                      ),
                                    ),
                                  )),

                              const SizedBox(width: 10),

                              // Play button
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      30), // Adjust the radius as needed
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            30), // Match the parent ClipRRect's borderRadius
                                        color: Colors.white.withOpacity(0.6),
                                        border: Border.all(
                                            color: Colors.white, width: 1)),
                                    child: SizedBox(
                                      width: 122,
                                      child: ElevatedButton(
                                        onPressed: _isPostButtonDisabled
                                            ? null
                                            : () {
                                                _playVideo();
                                              },
                                        style: ElevatedButton.styleFrom(
                                          primary: Colors.transparent,
                                          elevation: 0,
                                        ),
                                        child: Row(children: [
                                          // Play icon
                                          SizedBox(
                                              width: 28,
                                              height: 28,
                                              child: Image.asset(
                                                  'assets/icons/play_button.png')),

                                          const SizedBox(width: 5),

                                          // Play text
                                          const DefaultTextStyle(
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 19,
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: "IBMPlexSans"),
                                              child: Text("PLAY")),
                                        ]),
                                      ),
                                    ),
                                  )),
                            ],
                          ))),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _createPost() async {
    // Load the provider or the ChangeNotifier
    final postsProvider = Provider.of<CreateSquarePost>(
      Global.getSquareContext(),
      listen: false,
    );

    // Run the Post creation code in the background
    unawaited(postsProvider.createPost(filePath: widget.filePath));

    // Navigate back to the homepage
    Navigator.of(context).popUntil((route) {
      return route.settings.name == '/home' || route.isFirst;
    });
  }

  Future<void> _playVideo() {
    setState(() {
      _isPlaying = true;
    });
    return _videoPlayerController.play();
  }

  Future<void> _pauseVideo() {
    setState(() {
      _isPlaying = false;
    });
    return _videoPlayerController.pause();
  }

  // bool _initialized = false;
  Future<void> _initVideoPlayer() async {
    _videoPlayerController =
        CachedVideoPlayerController.file(File(widget.filePath));
    await _videoPlayerController.initialize();
    await _videoPlayerController.setLooping(false); // Disable looping
    _videoPlayerController.addListener(() {
      /*setState(() {
        _isPlaying = _videoPlayerController.value.isPlaying;
      });*/
      if (_videoPlayerController.value.position ==
          _videoPlayerController.value.duration) {
        // Video has ended, seek to the beginning and pause
        _videoPlayerController.seekTo(Duration.zero);
        if (_isPlaying) {
          _pauseVideo();
        }
      }
    });
    setState(() {}); // reload video to build appropriate size
  }
}
