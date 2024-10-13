import 'package:firebase_auth/firebase_auth.dart';
import 'package:mvp_one/models/user_model.dart';
import 'package:mvp_one/services/authentication/base_auth.service.dart';
import 'package:mvp_one/services/rest/user_services/user.service.dart';

class AuthenticationService {
  static BaseAuthService? authService;

  static Future<UserModel?> signIn(BaseAuthService authService) {
    AuthenticationService.authService = authService;
    return authService.signIn();
  }

  static Future<void> signOut() async {
    if (authService != null) {
      authService!.signOut();
    } else {
      // Force sign out
      await FirebaseAuth.instance.signOut();
      await UserService.deleteUserInfo();
    }
  }

  static bool isUserSignedIn() {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    return user != null;
  }
}
