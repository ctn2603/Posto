import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mvp_one/screens/square/live_moment.dart';
import 'package:mvp_one/utils/payloads/response/post_res.dart' as payload;
import 'package:mvp_one/utils/resource_checker.dart';

class TimeOutFeed extends StatefulWidget {
  final payload.SquarePost? post;

  const TimeOutFeed({Key? key, required this.post}) : super(key: key);

  @override
  State<TimeOutFeed> createState() => _TimeOutFeedState();
}

class _TimeOutFeedState extends State<TimeOutFeed> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 23),
          child: Text(
            widget.post!.name != null
                ? widget.post!.name!
                : widget.post!.username!,
            style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3),
          ),
        ),
        _buildPost(context)
      ],
    );
  }

  Widget _buildPost(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 35),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(25)),
            child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                child: LayoutBuilder(builder: (context, constraints) {
                  return AspectRatio(
                      aspectRatio: 2 / 3, // Set the aspect ratio to 0.8:1
                      child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(25)),
                          child: ResourceChecker.isImage(widget.post!.imageUrl!)
                              ? Image.network(
                                  widget.post!.imageUrl!,
                                  fit: BoxFit.cover,
                                )
                              : LiveMoment(
                                  videoPath: widget.post!.imageUrl!,
                                  isThumbnail: true)));
                })),
          ),
          Positioned.fill(
              child: ClipRRect(
            child: Column(
              children: [
                Expanded(
                  child: Container(),
                ),
                Container(
                    alignment: Alignment.center,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text("Time's up!",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              )),
                          const SizedBox(
                            height: 9,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.only(
                                left: 10, top: 2, right: 10, bottom: 2),
                            child: const Text("Next session starts at 12am",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          const FractionallySizedBox(
                            widthFactor: 0.65,
                            child: Text(
                                "See you tomorrow, now go for a run or a coffee.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400)),
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                          SizedBox(
                            width: 166,
                            height: 41,
                            child: ElevatedButton(
                              style: ButtonStyle(
                                // Change button color depending on whether it's disabled or not
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.white.withOpacity(0.2)),
                                textStyle: MaterialStateProperty.all(
                                    const TextStyle(
                                        fontWeight: FontWeight.w600)),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                )),
                                side: MaterialStateProperty.all(
                                  const BorderSide(
                                    color: Colors
                                        .white, // Specify the border color
                                    width: 1, // Specify the border width
                                  ),
                                ),
                              ),
                              onPressed: () => {},
                              child: const Text(
                                'SHARE NOW',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(height: 50),
                          const FractionallySizedBox(
                            widthFactor: 0.4,
                            child: Text(
                                "Clash is coming soon. For now, spread the word.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400)),
                          ),
                        ])),
                Expanded(
                  child: Container(),
                ),
              ],
            ),
          ))
        ],
      ),
    );
  }
}
