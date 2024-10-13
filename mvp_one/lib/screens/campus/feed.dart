import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mvp_one/providers/post_providers/campus_posts_load.dart';
import 'package:mvp_one/providers/time_out.dart';
import 'package:mvp_one/services/credential_storage.service.dart';
import 'package:mvp_one/services/rest/post_services/campus_post.service.dart';
import 'package:mvp_one/utils/payloads/response/post_res.dart' as payload;
import 'package:provider/provider.dart';
import 'package:mvp_one/screens/square/no_more_posts_placeholder.dart';
import 'package:url_launcher/url_launcher.dart';

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

  List<payload.CampusPost> _posts = [];

  @override
  Widget build(BuildContext context) {
    bool isTimedOut = context.watch<TimeOut>().isTimeUp();

    bool? hasMorePosts =
        context.select((CampusPostsLoad value) => value.hasMorePosts);

    return ListView.builder(
      itemCount: _posts.length +
          (hasMorePosts!
              ? withNoMorePostsPlaceholder
              : withOutNoMorePostsPlaceholder),
      itemBuilder: (context, index) {
        // If we're at the last index of the posts list
        if (index == _posts.length) {
          return hasMorePosts
              ? _buildProgressIndicator()
              : const NoMorePostsPlaceholder();
        }
        // If we're one past the last index of the posts list and there are no more posts
        else if (index == _posts.length + 1 && !hasMorePosts) {
          // This index should only be reachable if there are no more posts, so show the placeholder
          return const NoMorePostsPlaceholder();
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
                  "Posto Social", // TODO: hardcode here, change to real username later
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
        // Default case: return an empty container. This should ideally never be hit.
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

  @override
  void initState() {
    super.initState();

    // load partial posts initially with pagenum = 1, indicating first page
    CampusPostService().getPartialPosts(null).then((value) {
      setState(() {
        if (value != null) {
          _posts = value.posts!;
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

  Widget _buildBlurFeed(BuildContext context, payload.CampusPost post) {
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
                      borderRadius: const BorderRadius.all(Radius.circular(25)),
                      child: Image.network(
                        post.articleUrl!,
                        fit: BoxFit.cover,
                      )),
                );
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
            child: const CircularProgressIndicator(
              color: Colors.black,
            ),
          ),
        ));
  }

  Widget _buildUnblurFeed(BuildContext context, payload.CampusPost post) {
    List<String> captionWords = post.caption!.split('|');
    String title = captionWords.isNotEmpty ? captionWords.first.trim() : '';
    String caption = captionWords.length > 1 ? captionWords[1].trim() : '';

    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(25)),
          child: AspectRatio(
            aspectRatio: 2 / 3,
            child: Image.network(
              post.thumbnailUrl!,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: GestureDetector(
            onTap: () async {
              if (post.articleUrl != null) {
                launchUrl(Uri.parse(post.articleUrl!));
              }
            },
            child: Container(
              height: 130,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 100, 96, 96).withOpacity(0.8),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'IBMPlexSans',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 12.0,
                      right: 12.0,
                      bottom: 12.0,
                    ),
                    child: SizedBox(
                      width: 331,
                      child: Text(
                        caption,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: () async {
              if (_hasUserLikedPost(post, userId!)) {
                post.usersLiked!.remove(userId);
                post.likes = post.likes! - 1;
                CampusPostService().removeLike(post.postId!, userId!);
              } else {
                post.usersLiked ??= [];
                post.usersLiked!.add(userId);
                post.likes = post.likes! + 1;
                CampusPostService().addLike(post.postId!, userId!);
              }
              setState(() {});
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 70,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.transparent,
                  ),
                ),
                ImageIcon(
                  _hasUserLikedPost(post, userId!)
                      ? const AssetImage('assets/icons/like_button_liked.png')
                      : const AssetImage(
                          'assets/icons/like_button_default.png'),
                  color: Colors.white,
                  size: 60,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // functon to lazy load more posts onto feed when user reaches the bottom
  Future<void> _getMoreData({required bool isFromScratch}) async {
    if (!_isLoading) {
      // turn loading on
      setState(() {
        _isLoading = true;
      });

      // batch load 2 more posts to feed
      await Provider.of<CampusPostsLoad>(context, listen: false)
          .loadPartialPosts(isFromScratch: isFromScratch);

      setState(() {
        _isLoading = false;
      });
    }
  }

  // Checks if current user has liked a specific post
  bool _hasUserLikedPost(payload.CampusPost post, String userId) {
    if (post.usersLiked == null) {
      return false;
    }
    return post.usersLiked!.contains(userId);
  }
}
