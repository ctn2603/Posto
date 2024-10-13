import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mvp_one/providers/post_providers/playground_posts_load.dart';
import 'package:mvp_one/providers/time_out.dart';
import 'package:mvp_one/services/credential_storage.service.dart';
import 'package:mvp_one/services/rest/post_services/playground_post.service.dart';
import 'package:mvp_one/utils/payloads/response/post_res.dart' as payload;
import 'package:provider/provider.dart';
import 'package:mvp_one/screens/square/no_more_posts_placeholder.dart';

class Feed extends StatefulWidget {
  const Feed({Key? key}) : super(key: key);

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  String? userId;

  // feed includes no posts placeholder
  final withNoMorePostsPlaceholder = 2;

  // feed doesn't include no posts placeholder
  final withOutNoMorePostsPlaceholder = 1;

  // scroll controller to track the scroll position in device
  final ScrollController _scrollController = ScrollController();

  // load state for lazy loading
  bool _isLoading = false;

  List<payload.PlaygroundPost> _posts = [];

  @override
  Widget build(BuildContext context) {
    bool isTimedOut = context.watch<TimeOut>().isTimeUp();

    bool? hasMorePosts =
        context.select((PlaygroundPostsLoad value) => value.hasMorePosts);

    return ListView.builder(
      itemCount: _posts.length +
          (hasMorePosts!
              ? withNoMorePostsPlaceholder
              : withOutNoMorePostsPlaceholder), // Adjusted itemCount
      itemBuilder: (context, index) {
        // If we're at the last index of the posts list
        if (index == _posts.length) {
          if (hasMorePosts) {
            // If there are more posts, show the loading indicator
            return _buildProgressIndicator();
          } else {
            // If there are no more posts, show the placeholder
            return const NoMorePostsPlaceholder();
          }
        }
        // Regular post rendering
        else if (index < _posts.length) {
          final post = _posts[index];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 23),
                child: Text(
                  // post.name != null ? post.name! : post.username!,
                  "Posto Social", // TODO: hardcode here, change to real username later,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 35),
                child: isTimedOut
                    ? _buildBlurFeed(context, post)
                    : _buildUnblurFeed(context, post),
              )
            ],
          );
        }
        // Default case: return an empty container. Ideally, this won't be hit.
        else {
          return Container();
        }
      },
      controller: _scrollController,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fetch current user ID once
    if (userId == null) {
      getCurrentUserId().then((currUserId) {
        setState(() {
          userId = currUserId;
        });
      });
    }
  }

  // disposing scroll controller
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<String> getCurrentUserId() async {
    return await CredentialStorageService().getUserId();
  }

  // Checks if current user has liked a specific post
  Future<bool> hasUserLikedPost(String postId, String userId) async {
    return (await PlaygroundPostService().getUsersLiked(postId))!
        .contains(userId);
  }

  @override
  void initState() {
    super.initState();

    // load partial posts initially with pagenum = 1, indicating first page
    PlaygroundPostService().getPartialPosts(null).then((value) {
      setState(() {
        if (value != null) {
          setState(() {
            _posts = value.posts!;
          });
        }
      });
    });

    // binding scroll controller to listener
    _scrollController.addListener(() {
      if (_isLoading) {
        return; // Prevent multiple simultaneous data fetches
      }

      // Will reload 10 more items when reach item 8, avoiding
      // waiting performance
      int threshold = 8;
      double triggerPosition = _scrollController.position.maxScrollExtent -
          (_scrollController.position.viewportDimension * threshold);

      if (_scrollController.position.pixels >= triggerPosition) {
        // calling function to batch load more posts to the feed
        _getMoreData(isFromScratch: false);
      }
    });
  }

  Widget _buildBlurFeed(BuildContext context, payload.PlaygroundPost post) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(25)),
          child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: LayoutBuilder(builder: (context, constraints) {
                return AspectRatio(
                    aspectRatio: 2 / 3, // Set the aspect ratio to 0.8:1
                    child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(25)),
                        child: Image.network(
                          post.imageUrl!,
                          fit: BoxFit.cover,
                        )));
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
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white.withOpacity(0.2)),
                              textStyle: MaterialStateProperty.all(
                                  const TextStyle(fontWeight: FontWeight.w600)),
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              )),
                              side: MaterialStateProperty.all(
                                const BorderSide(
                                  color:
                                      Colors.white, // Specify the border color
                                  width: 1.0, // Specify the border width
                                ),
                              ),
                            ),
                            onPressed: () => {},
                            child: const Text(
                              'SHARE NOW',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(height: 50),
                        const FractionallySizedBox(
                          widthFactor: 0.35,
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
    );
  }

  // build loading indicator
  Widget _buildProgressIndicator() {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Opacity(
            opacity: _isLoading ? 1.0 : 0,
            // opacity: 1,
            child: const CircularProgressIndicator(color: Colors.black),
          ),
        ));
  }

  Widget _buildUnblurFeed(BuildContext context, payload.PlaygroundPost post) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(25)),
          child: LayoutBuilder(builder: (context, constraints) {
            return AspectRatio(
                aspectRatio: 2 / 3, // Set the aspect ratio to 0.8:1
                child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(25)),
                    child: Image.network(
                      post.imageUrl!,
                      fit: BoxFit.cover,
                    )));
          }),
        ),
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
                          _hasUserLikedPost(post, userId!)
                              ? const AssetImage(
                                  'assets/icons/like_button_liked.png')
                              : const AssetImage(
                                  'assets/icons/like_button_default.png'),
                          color: Colors.white),
                      onPressed: () async {
                        if (_hasUserLikedPost(post, userId!)) {
                          post.usersLiked!.remove(userId);
                          post.likes = post.likes! - 1;
                          PlaygroundPostService()
                              .removeLike(post.postId!, userId!);
                        } else {
                          post.usersLiked ??= [];
                          post.usersLiked!.add(userId);
                          post.likes = post.likes! + 1;
                          PlaygroundPostService()
                              .addLike(post.postId!, userId!);
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
    );
  }

  // function to lazy load more posts onto feed when user reaches the bottom
  Future<void> _getMoreData({required bool isFromScratch}) async {
    if (!_isLoading) {
      // turn loading on
      setState(() {
        _isLoading = true;
      });

      // batch load 2 more posts to feed
      await Provider.of<PlaygroundPostsLoad>(context, listen: false)
          .loadPartialPosts(isFromScratch: isFromScratch);

      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _hasUserLikedPost(payload.PlaygroundPost post, String userId) {
    if (post.usersLiked == null) {
      return false;
    }
    return post.usersLiked!.contains(userId);
  }
}
