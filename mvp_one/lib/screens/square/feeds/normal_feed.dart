import 'package:flutter/material.dart';
import 'package:mvp_one/screens/square/live_moment.dart';
import 'package:mvp_one/services/rest/post_services/square_post.service.dart';
import 'package:mvp_one/utils/payloads/response/post_res.dart' as payload;
import 'package:mvp_one/utils/resource_checker.dart';

class NormalFeed extends StatefulWidget {
  final payload.SquarePost? post;
  final String? userId;

  const NormalFeed({super.key, required this.post, required this.userId});

  @override
  State<NormalFeed> createState() => NormalFeedState();
}

class NormalFeedState extends State<NormalFeed> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 23, top: 15),
          child: Text(
            widget.post!.name != null
                ? widget.post!.name!
                : widget.post!.username!,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildPost()
      ],
    );
  }

  bool _hasUserLikedPost() {
    if (widget.post!.usersLiked == null) {
      return false;
    }
    return widget.post!.usersLiked!.contains(widget.userId);
  }

  Widget _buildPost() {
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(25)),
              child: LayoutBuilder(builder: (context, constraints) {
                return ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(25)),
                  child: ResourceChecker.isImage(widget.post!.imageUrl!)
                      ? Image.network(
                          widget.post!.imageUrl!,
                          fit: BoxFit.cover,
                        )
                      : LiveMoment(videoPath: widget.post!.imageUrl!),
                );
              }),
            ),
            Positioned.fill(
              child: ClipRRect(
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 70,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  image: const DecorationImage(
                                    image: AssetImage(
                                        'assets/icons/blur_background_for_like.png'),
                                    fit: BoxFit.cover,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      spreadRadius: 0.1,
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  iconSize: 60,
                                  icon: ImageIcon(
                                      _hasUserLikedPost()
                                          ? const AssetImage(
                                              'assets/icons/like_button_liked.png')
                                          : const AssetImage(
                                              'assets/icons/like_button_default.png'),
                                      color: Colors.white),
                                  onPressed: () async {
                                    payload.SquarePost post = widget.post!;

                                    if (_hasUserLikedPost()) {
                                      post.usersLiked!.remove(widget.userId);
                                      post.likes = post.likes! - 1;
                                      SquarePostService().removeLike(
                                          post.postId!, widget.userId!);
                                    } else {
                                      post.usersLiked ??= [];
                                      post.usersLiked!.add(widget.userId);
                                      post.likes = post.likes! + 1;
                                      SquarePostService().addLike(
                                          post.postId!, widget.userId!);
                                    }
                                    setState(() {});
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
