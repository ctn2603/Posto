import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mvp_one/screens/square/post_handling/check_post.dart';
import 'package:mvp_one/screens/square/live_moment.dart';
import 'package:mvp_one/utils/dialogs/error_dialog.dart';
import 'package:mvp_one/utils/global.dart';
import 'package:mvp_one/utils/page_routes/static_page_route.dart';
import 'package:mvp_one/utils/resource_checker.dart';

class CreatePost extends StatefulWidget {
  final bool? isFromScratch;

  const CreatePost({super.key, required this.isFromScratch});

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  final GlobalKey _videoPlayerKey = GlobalKey();
  List<CameraDescription>? _cameras; //list out the camera available
  late CameraController _cameraController;
  XFile? _disImg; //for captured live photo
  bool? _isFrontCamera;
  bool _isFlashOn = false;
  bool _isLoading = true;
  bool _isRecording = false;
  double _progressValue = 0.0;
  Timer? _timer;
  int _timeCollapsed = 0;

  _CreatePostState() {
    _isFrontCamera = true;
  }

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
          title: const Text("CAPTURE 3 SECONDS OF REAL LIFE 🔥️",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.w600)),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          _buildVideo(),
          const SizedBox(
            height: 15.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // left flash button
              SizedBox(
                width: 50,
                height: 50,
                child: AnimatedOpacity(
                  opacity: _isRecording ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Visibility(
                    visible: !_isFrontCamera!,
                    child: IconButton(
                      icon: !_isFlashOn
                          ? Image.asset(
                              'assets/icons/flash_button_on.png',
                            )
                          : Image.asset(
                              'assets/icons/flash_button_off.png',
                            ),
                      onPressed: () {
                        _cameraController.setFlashMode(
                            _isFlashOn ? FlashMode.off : FlashMode.torch);
                        setState(() {
                          _isFlashOn = !_isFlashOn;
                        });
                      },
                    ),
                  ),
                ),
              ),

              // buffer space
              const SizedBox(width: 20),

              // middle take photo button
              SizedBox(
                width: 90,
                height: 90,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      iconSize: 90,
                      icon: Image.asset(
                        'assets/icons/take_photo_button.png',
                      ),
                      onPressed: _isRecording
                          ? null
                          : () async {
                              // Disable the button when recording is in progress
                              _recordVideo();
                            },
                    ),
                    if (_isRecording) // Show the loading buffer circle progress bar when recording is in progress
                      Stack(children: [
                        Center(
                          child: SizedBox(
                            width: 45,
                            height: 45,
                            child: CircularProgressIndicator(
                              value: _progressValue, // Set the progress value
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFFED1C1C)),
                            ),
                          ),
                        ),
                        Center(
                            child: Text(
                          (_timeCollapsed ~/ 1000).toString(),
                          style: const TextStyle(
                              color: Color(0xFFED1C1C), fontSize: 22),
                        ))
                      ]),
                  ],
                ),
              ),

              // buffer space
              const SizedBox(width: 20),

              // right flip camera button
              SizedBox(
                width: 50,
                height: 50,
                child: AnimatedOpacity(
                  opacity: _isRecording ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: IconButton(
                    icon: Image.asset('assets/icons/flip_camera_button.png'),
                    onPressed: _isRecording
                        ? null
                        : () {
                            _flipCamera();
                          },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Called when coming back from CheckPost
  @override
  void didUpdateWidget(covariant CreatePost oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if the widget was updated and reinitialize the camera controller if needed
    if (widget != oldWidget) {
      _initCamera();
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // initial run for camera
    _loadCameraDescriptions()
        .then(
      (value) => _initCamera(),
    )
        .catchError((error) async {
      await showErrorDialog("Unable to load cameras");
    });
  }

  Widget _buildVideo() {
    return AspectRatio(
      aspectRatio: 2 / 3,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(30)),
            child: Container(
                decoration: BoxDecoration(color: Colors.grey.withOpacity(.4))),
          ),
          if (_isLoading)
            const Center(child: Text("Loading Camera..."))
          else if (_disImg == null)
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(25)),
              child: Stack(children: [
                SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,

                      // Disabling double tap to switch cameras through live photo
                      child: _isRecording
                          ? CameraPreview(
                              _cameraController) // Show the camera preview when recording is in progress
                          : GestureDetector(
                              onDoubleTap: () async {
                                await _flipCamera();
                              },
                              child: CameraPreview(_cameraController),
                            ),
                    ),
                  ),
                ),
                Visibility(
                  visible: !_isRecording,
                  child: SizedBox(
                    height: 40,
                    width: 40,
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Image.asset('assets/icons/close_button.png'),
                    ),
                  ),
                ),
                Column(children: [
                  const SizedBox(
                    height: 15,
                  ),
                  const Text("🔴 LIVE MOMENT",
                      style: TextStyle(color: Color(0xFFED1C1C), fontSize: 16)),
                  Expanded(
                    child: Container(),
                  ),
                  const SizedBox(
                    height: 20,
                  )
                ]),
              ]),
            )
          else
            SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(25)),
                  child: ResourceChecker.isImage(_disImg!.path)
                      ? Image.file(
                          File(_disImg!.path),
                          fit: BoxFit.cover,
                        )
                      : LiveMoment(
                          key: _videoPlayerKey,
                          videoPath: _disImg!.path,
                          isNetworkVideo: false)),
            ),
        ],
      ),
    );
  }

  Future<void> _flipCamera() async {
    if (!_isLoading) {
      CameraDescription newCamera;

      if (_isFrontCamera!) {
        newCamera = _cameras!.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back);
      } else {
        newCamera = _cameras!.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front);
      }

      await _cameraController.dispose();
      _cameraController = CameraController(newCamera, ResolutionPreset.max,
          imageFormatGroup: ImageFormatGroup.bgra8888);
      await _cameraController.initialize();
      setState(() {
        _isFrontCamera = !_isFrontCamera!;
      });
    }
  }

  Future<void> _initCamera() async {
    final front = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front);
    _cameraController = CameraController(front, ResolutionPreset.max,
        imageFormatGroup: ImageFormatGroup.bgra8888);

    await _cameraController.initialize();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadCameraDescriptions() async {
    _cameras = await availableCameras();
  }

  Future<void> _recordVideo() async {
    await _cameraController.prepareForVideoRecording();
    await _cameraController.startVideoRecording();
    setState(() {
      _isRecording = true;
      _progressValue = 0.0;
      _timeCollapsed = 0;
    });

    // record only 3 second video and update progress bar
    _progressValue = 0.0; // Reset the progress
    const stepDuration =
        Duration(milliseconds: 30); // Duration between each progress update
    const totalSteps = 100; // The number of steps to complete 100% progress
    const progressIncrement =
        1.0 / totalSteps; // The amount to increment the progress for each step

    _timer = Timer.periodic(stepDuration, (timer) {
      if (_isRecording) {
        setState(() {
          _timeCollapsed += stepDuration.inMilliseconds;
          _progressValue += progressIncrement;
          if (_progressValue >= 1.0) {
            _progressValue = 1.0;
            _timer?.cancel(); // Stop the timer when the progress reaches 100%
            _stopRecording(); // Call a function to stop recording after 3 seconds
          }
        });
      }
    });
  }

  Future<void> _stopRecording() async {
    if (_isRecording) {
      if (_isFlashOn) {
        _isFlashOn = false;
        _cameraController.setFlashMode(FlashMode.off); // turn off flash
      }

      final file = await _cameraController.stopVideoRecording();
      setState(() {
        _isRecording = false;
        Navigator.push(
          Global.getGlobalContext(),
          StaticPageRoute(
            child: CheckPost(filePath: file.path),
          ),
        );
      });
    }
  }
}
