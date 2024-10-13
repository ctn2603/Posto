import 'package:mvp_one/models/user_model.dart';

abstract class BaseAuthService {
  Future<UserModel?> signIn();
  Future<void> signOut();
}
