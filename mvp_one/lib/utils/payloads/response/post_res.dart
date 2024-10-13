// class Comment {
//   String? username;
//   String? profileImage;
//   String? comment;
//   String? sound;

//   Comment({this.username, this.profileImage, this.comment, this.sound});

//   factory Comment.fromJson(Map<String, dynamic> commentInJson) {
//     return Comment(
//         username: commentInJson['username'],
//         profileImage: commentInJson['profileImage'],
//         comment: commentInJson['comment'],
//         sound: commentInJson['sound']);
//   }
// }

class SquarePost {
  String? username;
  String? name;
  String? profileImageUrl;
  String? imageUrl;
  String? caption;
  int? likes;
  List<dynamic>? usersLiked;
  String? postId;
  DateTime? createdAt;

  SquarePost(
      {this.username,
      this.name,
      this.profileImageUrl,
      this.imageUrl,
      this.caption,
      this.likes,
      this.usersLiked,
      this.postId,
      this.createdAt});

  factory SquarePost.fromJson(dynamic post) {
    return SquarePost(
        username: post["username"],
        name: post["name"],
        profileImageUrl: post["profileImageUrl"],
        imageUrl: post["imageUrl"],
        caption: post["caption"],
        likes: post["likes"],
        usersLiked: post["usersLiked"],
        postId: post["postId"],
        createdAt: DateTime.parse(post["createdAt"]));
  }
}

class SquarePostsRes {
  List<SquarePost>? posts;
  String? lastPostId;

  SquarePostsRes({this.posts, this.lastPostId});

  factory SquarePostsRes.fromJson(dynamic data) {
    List<SquarePost> posts = [];
    if (data['posts'] != null) {
      for (dynamic post in data['posts']) {
        posts.add(SquarePost.fromJson(post));
      }
    }

    return SquarePostsRes(posts: posts, lastPostId: data["lastPostId"]);
  }
}

class SquarePostsNotByUserRes {
  List<SquarePost>? posts;
  String? lastPostId;
  String? userName;
  bool? hasMorePosts;

  SquarePostsNotByUserRes(
      {this.posts, this.lastPostId, this.userName, this.hasMorePosts});

  factory SquarePostsNotByUserRes.fromJson(dynamic data) {
    List<SquarePost> posts = [];
    if (data['posts'] != null) {
      for (dynamic post in data['posts']) {
        posts.add(SquarePost.fromJson(post));
      }
    }

    return SquarePostsNotByUserRes(
        posts: posts,
        lastPostId: data["lastPostId"],
        userName: data["userName"],
        hasMorePosts: data["hasMorePosts"]);
  }
}

class CampusPost {
  String? username;
  String? name;
  String? profileImageUrl;
  String? articleUrl;
  String? thumbnailUrl;
  String? caption;
  int? likes;
  List<dynamic>? usersLiked;
  String? postId;
  DateTime? createdAt;

  CampusPost(
      {this.username,
      this.name,
      this.profileImageUrl,
      this.articleUrl,
      this.thumbnailUrl,
      this.caption,
      this.likes,
      this.usersLiked,
      this.postId,
      this.createdAt});

  factory CampusPost.fromJson(dynamic post) {
    return CampusPost(
        username: post["username"],
        name: post["name"],
        profileImageUrl: post["profileImageUrl"],
        articleUrl: post["articleUrl"],
        thumbnailUrl: post["thumbnailUrl"],
        caption: post["caption"],
        likes: post["likes"],
        usersLiked: post["usersLiked"],
        postId: post["postId"],
        createdAt: DateTime.parse(post["createdAt"]));
  }
}

class CampusPostsRes {
  List<CampusPost>? posts;
  String? lastPostId;

  CampusPostsRes({this.posts, this.lastPostId});

  factory CampusPostsRes.fromJson(dynamic data) {
    List<CampusPost> posts = [];
    if (data['posts'] != null) {
      for (dynamic post in data['posts']) {
        posts.add(CampusPost.fromJson(post));
      }
    }

    return CampusPostsRes(posts: posts, lastPostId: data["lastPostId"]);
  }
}

class PlaygroundPost {
  String? username;
  String? name;
  String? profileImageUrl;
  String? imageUrl;
  String? caption;
  int? likes;
  List<dynamic>? usersLiked;
  String? postId;
  DateTime? createdAt;

  PlaygroundPost(
      {this.username,
      this.name,
      this.profileImageUrl,
      this.imageUrl,
      this.caption,
      this.likes,
      this.usersLiked,
      this.postId,
      this.createdAt});

  factory PlaygroundPost.fromJson(dynamic post) {
    return PlaygroundPost(
        username: post["username"],
        name: post["name"],
        profileImageUrl: post["profileImageUrl"],
        imageUrl: post["imageUrl"],
        caption: post["caption"],
        likes: post["likes"],
        usersLiked: post["usersLiked"],
        postId: post["postId"],
        createdAt: DateTime.parse(post["createdAt"]));
  }
}

class PlaygroundPostsRes {
  List<PlaygroundPost>? posts;
  String? lastPostId;

  PlaygroundPostsRes({this.posts, this.lastPostId});

  factory PlaygroundPostsRes.fromJson(dynamic data) {
    List<PlaygroundPost> posts = [];
    if (data['posts'] != null) {
      for (dynamic post in data['posts']) {
        posts.add(PlaygroundPost.fromJson(post));
      }
    }

    return PlaygroundPostsRes(posts: posts, lastPostId: data["lastPostId"]);
  }
}
