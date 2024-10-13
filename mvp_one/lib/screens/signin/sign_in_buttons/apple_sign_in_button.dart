import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mvp_one/screens/home/home.dart';
import 'package:mvp_one/screens/signin/create_username.dart';
import 'package:mvp_one/services/authentication/authentication.service.dart';
import 'package:mvp_one/services/rest/user_services/user.service.dart';
import 'package:mvp_one/services/authentication/apple_auth.service.dart';
import 'package:mvp_one/utils/page_routes/static_page_route.dart';
import 'package:mvp_one/screens/signin/terms_and_conditions.dart';
import 'package:mvp_one/services/credential_storage.service.dart';
import 'package:mvp_one/utils/payloads/response/sign_up_res.dart' as payload;

class AppleSignInButton extends StatefulWidget {
  const AppleSignInButton({super.key});

  @override
  State<AppleSignInButton> createState() => _AppleSignInButtonState();
}

class _AppleSignInButtonState extends State<AppleSignInButton> {
  bool _isSigningIn = false;
  bool _ackTerms = true;


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: _isSigningIn
          ? const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
            )
          : OutlinedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.black),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              onPressed: _appleUserSignIn,
              child: const Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Row(
                  // mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image(
                      image: AssetImage("assets/images/apple_logo.png"),
                      height: 25.0,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        'Sign in with Apple   ', // fix spacing later
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  void _appleUserSignIn() async {
    setState(() {
      _isSigningIn = true;
    });

    final user = await AuthenticationService.signIn(AppleAuthService());
    if (user != null) {
      bool? userExists = await UserService.userExists(user.uid);
      if (!userExists!) {
        if (mounted) {
          Navigator.of(context).push(StaticPageRoute(
            child: CreateUserName(
              user: user,
            ),
          ));
        }
      } else {
        payload.SignUpRes? signUpPayload =
            await UserService.getUserByIdLogin(user.uid!);

        String? username = signUpPayload!.username;
        String? name = signUpPayload.name;
        String? userId = signUpPayload.userId;
        String? profileImage = signUpPayload.profileImage;
        String? email = signUpPayload.email;

        if (username != null && userId != null) {
          await UserService.saveUserInfo(
            username,
            name!,
            userId,
            email!,
            profileImage!,
          );
          if (mounted) {

            checkTerms();
            if (!_ackTerms){
              Navigator.of(context).push(StaticPageRoute(child: const TermsAndConditions()));
            }else{
              Navigator.of(context).push(StaticPageRoute(child: const Home()));
            }
            

          }
        }
      }
    }

    setState(() {
      _isSigningIn = false;
    });
  }
  void checkTerms() {
    _hasAcknowledgedTermsAndConditions().then((value) {
      setState(() {
        _ackTerms = (value == null) ? false : value;
      });
    });
  }

  Future<bool?> _hasAcknowledgedTermsAndConditions() async {
    String userId = await CredentialStorageService().getUserId();
    return UserService.hasAcknowledgedTermsAndConditions(userId);
  }
}
