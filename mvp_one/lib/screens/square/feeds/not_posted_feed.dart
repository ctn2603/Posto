import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mvp_one/screens/square/post_handling/create_post.dart';
import 'package:mvp_one/screens/square/live_moment.dart';
import 'package:mvp_one/utils/global.dart';
import 'package:mvp_one/utils/page_routes/static_page_route.dart';
import 'package:mvp_one/utils/payloads/response/post_res.dart' as payload;
import 'package:mvp_one/utils/resource_checker.dart';

class NotPostedFeed extends StatefulWidget {
  final payload.SquarePost? post;

  const NotPostedFeed({super.key, required this.post});

  @override
  State<NotPostedFeed> createState() => _NotPostedFeedState();
}

class _NotPostedFeedState extends State<NotPostedFeed> {
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
          SizedBox(
            width: double.infinity,
            child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(25)),
                child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                    child: LayoutBuilder(builder: (context, constraints) {
                      return AspectRatio(
                          aspectRatio: 2 / 3, // Set the aspect ratio to 0.8:1
                          child: ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(25)),
                              child: ResourceChecker.isImage(
                                      widget.post!.imageUrl!)
                                  ? Image.network(
                                      widget.post!.imageUrl!,
                                      fit: BoxFit.cover,
                                    )
                                  : LiveMoment(
                                      videoPath: widget.post!.imageUrl!,
                                      isThumbnail: true)));
                    }))),
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
                    width: 288,
                    height: 90,
                    child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Enter the Square",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                              )),
                          SizedBox(height: 7),
                          Text(
                            "Post something to see your friends",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ])),
                Expanded(
                  child: Container(),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 29.0),
                  child: SizedBox(
                      width: 70,
                      height: 70,
                      child: OutlinedButton(
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all<OutlinedBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                          side: MaterialStateProperty.all<BorderSide>(
                            const BorderSide(color: Colors.white, width: 9),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(Global.getGlobalContext()).push(
                              StaticPageRoute(
                                  child:
                                      const CreatePost(isFromScratch: false)));
                        },
                        child: Container(),
                      )),
                ),
              ],
            ),
          ))
        ],
      ),
    );
  }
}
