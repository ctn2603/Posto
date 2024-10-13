// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:mvp_one/providers/post_providers/create_square_post.dart';
import 'package:mvp_one/providers/post_providers/square_posts_load/other_square_posts_load.dart';
import 'package:mvp_one/providers/time_out.dart';
import 'package:mvp_one/providers/user_post_status.dart';
import 'package:mvp_one/providers/post_providers/square_posts_load/user_square_posts_load.dart';
import 'package:mvp_one/screens/share_with_friends_buttons/share_with_friends.dart';
import 'package:mvp_one/screens/square/post_handling/create_post.dart';
import 'package:mvp_one/screens/square/feeds/normal_feed.dart';
import 'package:mvp_one/screens/square/feeds/not_posted_feed.dart';
import 'package:mvp_one/screens/square/feeds/time_out_feed.dart';
import 'package:mvp_one/services/credential_storage.service.dart';
import 'package:mvp_one/utils/global.dart';
import 'package:mvp_one/utils/page_routes/static_page_route.dart';
import 'package:mvp_one/utils/payloads/response/post_res.dart' as payload;
import 'package:provider/provider.dart';
import 'package:mvp_one/screens/square/no_more_posts_placeholder.dart';

class Feed extends StatefulWidget {
  const Feed({Key? key}) : super(key: key);

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  // scroll controller to track the scroll position in device
  final ScrollController _scrollController;

  // user info
  String? _userId;
  String? _userName;

  // load state for lazy loading
  bool? _isLoading;

  // checks if user posted today
  bool? hasPostedToday;

  // checks if time is out
  bool? isTimeOut;

  // checks if partial posts have loaded yet or not
  bool? isOtherPostsLoaded;

  // checks if user posts have loaded yet or not
  bool? isUserPostsLoaded;

  // checks if there are more posts available in feed
  bool? hasMorePosts;

  // feed includes no posts placeholder
  final withNoMorePostsPlaceholder = 4;

  // feed doesn't include no posts placeholder
  final withOutNoMorePostsPlaceholder = 3;

  // listview index for share with friends buttons
  final shareWithFriendsButtonsIndex = 1;

  // available posts not created by current user
  late List<payload.SquarePost>? _otherPosts;

  // User's posts
  late List<payload.SquarePost>? _userPosts;

  _FeedState() : _scrollController = ScrollController() {
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    // Must use context.select instead of context.watch to avoid flickering
    _otherPosts = context.select((OtherSquarePostsLoad value) => value.posts);
    _userPosts = context.select((UserSquarePostsLoad value) => value.posts);
    hasPostedToday =
        context.select((UserPostStatus value) => value.hasUserPosted);
    isTimeOut = context.select((TimeOut value) => value.isTimeUp());
    isOtherPostsLoaded =
        context.select((OtherSquarePostsLoad value) => value.loaded);
    isUserPostsLoaded =
        context.select((UserSquarePostsLoad value) => value.loaded);
    hasMorePosts =
        context.select((OtherSquarePostsLoad value) => value.hasMorePosts) ??
            _otherPosts!.isNotEmpty;

    final isPosting = context
        .select((CreateSquarePost postsProvider) => postsProvider.isPosting);
    return ListView.builder(
      // adding for: progress bar, invite friends, user post, end of post box, and empty posts placeholder
      itemCount: _otherPosts!.length +
          (hasMorePosts!
              ? withOutNoMorePostsPlaceholder
              : withNoMorePostsPlaceholder),
      itemBuilder: (context, index) {
        // show invite friends and discover items
        if (index == shareWithFriendsButtonsIndex) {
          if (_otherPosts!.isEmpty && !isOtherPostsLoaded!) {
            return const SizedBox.shrink();
          }
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ShareWithFriendsSection(),
              Text(
                "Discover",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 15)
            ],
          );
        } else if (index ==
            _otherPosts!.length + withOutNoMorePostsPlaceholder - 1) {
          if (!isOtherPostsLoaded!) {
            return const SizedBox.shrink();
          } else {
            return hasMorePosts!
                ? _buildProgressIndicator()
                : const SizedBox.shrink();
          }
        } else if (index ==
            _otherPosts!.length + withNoMorePostsPlaceholder - 1) {
          // This checks the very last item after all posts
          if (!isOtherPostsLoaded!) {
            return const SizedBox.shrink();
          } else {
            return hasMorePosts! ? Container() : const NoMorePostsPlaceholder();
          }
        } else {
          final userPostedToday = hasPostedToday != null && hasPostedToday!;
          final isUserPost = index == 0;

          if (isUserPost) {
            if (_otherPosts!.isEmpty && isOtherPostsLoaded!) {
              if (isTimeOut!) {
                return _buildBlankTimeOutUserPost(context);
              } else {
                if (!userPostedToday) {
                  return isPosting
                      ? _buildIsPostingWidget(context)
                      : _buildBlankNotPostedUserPost(context);
                }
              }
            }

            if (!userPostedToday) {
              return isPosting
                  ? _buildIsPostingWidget(context)
                  : _buildBlankNotPostedUserPost(context);
            }
          }

          if (!isUserPostsLoaded!) {
            return const SizedBox.shrink();
          }

          final post = isUserPost
              ? _getTodayPost(userPosts: _userPosts!)
              : _otherPosts![index - 2];

          if (isTimeOut!) {
            return TimeOutFeed(post: post);
          } else {
            if (userPostedToday) {
              return NormalFeed(
                post: post,
                userId: _userId,
              );
            } else {
              return NotPostedFeed(post: post);
            }
          }
        }
      },
      controller: _scrollController,
    );
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

    getCurrentUserId().then((currUserId) async {
      _userId = currUserId;
      _userName = await CredentialStorageService().getUsername();

      Provider.of<OtherSquarePostsLoad>(context, listen: false)
          .loadPartialPosts(isFromScratch: true, userName: _userName!);
      // The following line should depend on the above line's loaded content
      //Provider.of<UserPostStatus>(context, listen: false).checkUserPostStatus();
      Provider.of<UserSquarePostsLoad>(context, listen: false)
          .loadUserSquarePosts(userId: _userId!);
    });

    _scrollController.addListener(() {
      if (_isLoading!) {
        return; // Prevent multiple simultaneous data fetches
      }

      // Will reload 10 more items when reach item 8, avoiding
      // waiting performance
      // don't get more data if we have gone through whole feed
      int threshold = 8;
      double triggerPosition = _scrollController.position.maxScrollExtent -
          (_scrollController.position.viewportDimension * threshold);
      if (_scrollController.position.pixels >= triggerPosition &&
          _otherPosts!.isNotEmpty &&
          hasMorePosts!) {
        // calling function to batch load more posts to the feed
        _getMoreData(isFromScratch: false);
      }
    });
  }

  // build loading indicator
  Widget _buildProgressIndicator() {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Opacity(
            opacity: _isLoading! ? 1.0 : 0,
            child: const CircularProgressIndicator(color: Colors.black),
          ),
        ));
  }

  Widget _buildBlankTimeOutUserPost(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 35),
      child: Stack(alignment: Alignment.center, children: [
        SizedBox(
          width: double.infinity,
          child: LayoutBuilder(builder: (context, constraints) {
            return AspectRatio(
                aspectRatio: 2 / 3, // Set the aspect ratio to 0.8:1
                child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(25)),
                    child: Container(
                        width: constraints
                            .maxWidth, // Set the width to match constraints
                        height: constraints.maxHeight,
                        color: const Color.fromRGBO(30, 30, 30, 0.15))));
          }),
        ),
        Positioned.fill(
            child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(25)),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black, // Set the border color here
                      width: 2.0, // Set the border width
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(25)),
                  ),
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
                                  child: const Text(
                                      "Next session starts at 12am",
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
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      )),
                                      side: MaterialStateProperty.all(
                                        const BorderSide(
                                          color: Colors
                                              .white, // Specify the border color
                                          width:
                                              1.0, // Specify the border width
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
                ))),
      ]),
    );
  }

  Widget _buildIsPostingWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 35),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: double.infinity,
            child: LayoutBuilder(builder: (context, constraints) {
              return AspectRatio(
                  aspectRatio: 2 / 3, // Set the aspect ratio to 0.8:1
                  child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(25)),
                      child: Container(
                          width: constraints
                              .maxWidth, // Set the width to match constraints
                          height: constraints.maxHeight,
                          color: const Color.fromRGBO(30, 30, 30, 0.15))));
            }),
          ),
          Positioned.fill(
              child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(25)),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black, // Set the border color here
                  width: 3.0, // Set the border width
                ),
                borderRadius: const BorderRadius.all(Radius.circular(25)),
              ),
              child: Column(
                children: [
                  Padding(
                      padding: const EdgeInsets.only(top: 160),
                      child: Container(
                          alignment: Alignment.center,
                          width: 288,
                          height: 90,
                          child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Saving Post",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 21,
                                      fontWeight: FontWeight.bold,
                                    )),
                                SizedBox(height: 7),
                                Text(
                                  "We are curently saving your post ...",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 19,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ]))),
                  Expanded(
                    child: Container(),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 29.0),
                    child: CircularProgressIndicator(
                      color: Color(0xFFF04914),
                    ),
                  ),
                ],
              ),
            ),
          ))
        ],
      ),
    );
  }

  Widget _buildBlankNotPostedUserPost(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 35),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: double.infinity,
            child: LayoutBuilder(builder: (context, constraints) {
              return AspectRatio(
                  aspectRatio: 2 / 3, // Set the aspect ratio to 0.8:1
                  child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(25)),
                      child: Container(
                          width: constraints
                              .maxWidth, // Set the width to match constraints
                          height: constraints.maxHeight,
                          color: const Color.fromRGBO(30, 30, 30, 0.15))));
            }),
          ),
          Positioned.fill(
              child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(25)),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black, // Set the border color here
                  width: 3.0, // Set the border width
                ),
                borderRadius: const BorderRadius.all(Radius.circular(25)),
              ),
              child: Column(
                children: [
                  Padding(
                      padding: const EdgeInsets.only(top: 160),
                      child: Container(
                          alignment: Alignment.center,
                          width: 288,
                          height: 90,
                          child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Enter the Square",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 21,
                                      fontWeight: FontWeight.bold,
                                    )),
                                SizedBox(height: 7),
                                Text(
                                  "Be first! See friends' photos as they join.",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 19,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ]))),
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
                              const BorderSide(color: Colors.black, width: 9),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(Global.getGlobalContext()).push(
                                StaticPageRoute(
                                    child: const CreatePost(
                                        isFromScratch: false)));
                          },
                          child: Container(),
                        )),
                  ),
                ],
              ),
            ),
          ))
        ],
      ),
    );
  }

  // function to lazy load more posts onto feed when user reaches the bottom
  Future<void> _getMoreData({required bool isFromScratch}) async {
    if (!_isLoading!) {
      // turn loading on
      setState(() {
        _isLoading = true;
      });

      // batch load 2 more posts to feed
      await Provider.of<OtherSquarePostsLoad>(context, listen: false)
          .loadPartialPosts(isFromScratch: isFromScratch, userName: _userName!);

      setState(() {
        _isLoading = false;
      });
    }
  }

  payload.SquarePost? _getTodayPost(
      {required List<payload.SquarePost> userPosts}) {
    payload.SquarePost? latestUserPost =
        userPosts.isEmpty ? null : userPosts.last;

    if (hasPostedToday!) {
      return latestUserPost;
    }

    return null;
  }
}
