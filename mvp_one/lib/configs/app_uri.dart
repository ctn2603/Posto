import 'package:mvp_one/flavors.dart';

final String baseUri = F.baseUri;

/*
 * User APIs 
 */
final String signupUri = '$baseUri/signup';
final String signinUri = '$baseUri/signin';
final String getAllUsersUri = '$baseUri/users'; // get all users
final String getUsersWithPatternUri =
    '$baseUri/users/{pattern}'; // get all users matching a specific pattern
final String getUsersBySearchUri =
    '$baseUri/users/{userid}/{pattern}'; // get all users matching a specific pattern
final String getUserByEmailUri =
    '$baseUri/email/{email}'; // get a user info from a specific email
final String getUserIdByEmailUri =
    '$baseUri/userid/{email}'; // get the user id from a specific email
final String getNameWithEmailUri =
    '$baseUri/name/'; // get the name from a specific email
final String getUserByIdUri = '$baseUri/user/{userid}';
final String checkUsernameExistsUri = '$baseUri/username_exists/{username}';
final String getProfileImgWithEmailUri = '$baseUri/pf-image/';
final String checkOnboardUri =
    '$baseUri/onboard/{userid}'; // check if the user is onboard
final String setOnboardUri = '$baseUri/onboard'; // mark the user as onboarded
final String checkPostStatusUri =
    '$baseUri/post-status/{userid}'; // check if the user has posted today
final String postStatusUri = '$baseUri/post-status'; // update post status
final String checkAcknowledgedSquareUri =
    '$baseUri/acknowledged-square/{userid}'; // check if the user acknowledged the presence of the square tab
final String setAcknowledgedSquareUri =
    '$baseUri/acknowledge-square'; // mark the user as acknowledged the square
final String checkAcknowledgedCampusUri =
    '$baseUri/acknowledged-campus/{userid}'; // check if the user acknowledged the presence of the campus tab
final String setAcknowledgedCampusUri =
    '$baseUri/acknowledge-campus'; // mark the user as acknowledged the campus
final String checkAcknowledgedPlaygroundUri =
    '$baseUri/acknowledged-playground/{userid}'; // check if the user acknowledge the present of the playground
final String setAcknowledgedPlaygroundUri =
    '$baseUri/acknowledge-playground'; // mark the user as acknowledged the campus
final String checkAcknowledgedTermsAndConditionsUri =
    '$baseUri/acknowledged-terms-and-conditions/{userid}'; // check if the user has acknowledged the terms and conditions
final String setAcknowledgedTermsAndConditionsUri =
    '$baseUri/acknowledge-terms-and-conditions'; // mark the user as acknowledged the terms and conditions
final String profileImageUpdateUri =
    '$baseUri/profile-pic-update/'; // update profile image
final String nameUpdateUri = '$baseUri/name-update/'; // update name
final String userNameUpdateUri =
    '$baseUri/user-name-update/'; // update username
final String deleteUserAccountUri =
    '$baseUri/delete-user-account/{userid}'; // delete user account

/*
 * Connection APIs 
 */
final String sendFriendRequestUri =
    '$baseUri/friend/request-connection'; //send the friend request of the user
final String getConnectionRequestsUri =
    '$baseUri/friend/friend-requests-received/{userid}'; //fetch the connection rquests of the user
final String acceptConnectionRequestUri =
    '$baseUri/friend/accept-connection'; // accept connection request
final String deleteConnectionRequestUri =
    '$baseUri/friend/delete-connection'; // delete connection request
final String getConnectionsUri =
    '$baseUri/friend/connections/{userid}'; //fetch the connections of the user

/*
 * Square post APIs 
 */
final String getAllSquarePostsUri = '$baseUri/square/posts';
final String getPartialSquarePostsUri = '$baseUri/square/posts';
final String getPartialSquarePostsWithTimezoneUri =
    '$baseUri/square/posts/{timezone}';
final String getPartialSquarePostsWithTimezoneandIDUri =
    '$baseUri/square/posts/{timezone}/{last-post-id}';
final String getPartialSquarePostsWithIdUri =
    '$baseUri/square/posts/{last-post-id}';
final String getPartialSquarePostsNotByUserUri =
    '$baseUri/square/posts/not-by-user/{time}/{username}';
final String getPartialSquarePostsNotByUserWithLastPostIdUri =
    '$baseUri/square/posts/not-by-user/{time}/{username}/{last-post-id}';
final String getSquarePostsFromUserIdUri =
    '$baseUri/square/user-posts/{userid}';
final String createSquarePostUri = '$baseUri/square/add-post';
final String addSquareLikeUri = '$baseUri/square/add-like/{postid}';
final String removeSquareLikeUri = '$baseUri/square/remove-like/{postid}';
final String getSquareUsersLikedUri = '$baseUri/square/users-liked/{postid}';
final String addSquareCommentUri = '$baseUri/{postid}';

/*
 * Campus post APIs 
 */
final String getAllCampusPostsUri = '$baseUri/campus/posts';
final String getPartialCampusPostsUri = '$baseUri/campus/posts';
final String getPartialCampusPostsWithIdUri =
    '$baseUri/campus/posts/{last-post-id}';
final String getCampusPostsFromUsernameUri = '$baseUri/campus/posts/{username}';
final String createCampusPostUri = '$baseUri/campus/add-post';
final String addCampusLikeUri = '$baseUri/campus/add-like/{postid}';
final String removeCampusLikeUri = '$baseUri/campus/remove-like/{postid}';
final String addCampusCommentUri = '$baseUri/campus/{postid}';
final String getCampusUsersLikedUri = '$baseUri/campus/users-liked/{postid}';
final String getCampusPostArticleUri = '$baseUri/campus/article-url/{postid}';

/*
 * Playground post APIs 
 */
final String getAllPlaygroundPostsUri = '$baseUri/playground/posts';
final String getPartialPlaygroundPostsUri = '$baseUri/playground/posts';
final String getPartialPlaygroundPostsWithIdUri =
    '$baseUri/playground/posts/{last-post-id}';
final String getPlaygroundPostsFromUsernameUri =
    '$baseUri/playground/posts/{username}';
final String createPlaygroundPostUri = '$baseUri/playground/add-post';
final String addPlaygroundLikeUri = '$baseUri/playground/add-like/{postid}';
final String removePlaygroundLikeUri =
    '$baseUri/playground/remove-like/{postid}';
final String addPlaygroundCommentUri = '$baseUri/playground/{postid}';
final String getPlaygroundUsersLikedUri =
    '$baseUri/playground/users-liked/{postid}';
