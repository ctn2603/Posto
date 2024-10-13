import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mvp_one/configs/app_config.dart';
import 'package:mvp_one/models/user_model.dart';
import 'package:mvp_one/screens/home/home.dart';
import 'package:mvp_one/services/credential_storage.service.dart';
import 'package:mvp_one/services/rest/user_services/user.service.dart';
import 'package:mvp_one/utils/dialogs/error_dialog.dart';
import 'package:mvp_one/utils/page_routes/static_page_route.dart';
import 'package:mvp_one/utils/payloads/response/sign_up_res.dart';
import 'terms_and_conditions.dart';
import 'create_profile_pic.dart';

class CreateUserName extends StatefulWidget {
  final UserModel _user;

  const CreateUserName({
    Key? key,
    required UserModel user,
  })  : _user = user,
        super(key: key);

  @override
  State<CreateUserName> createState() => _CreateUserNameState();
}

class _CreateUserNameState extends State<CreateUserName> {
  late UserModel _user;
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late String? _name = _user.name;
  late String _username = '';
  late final String _email = _user.email ?? "example@gmail.com";
  late final String? _phone = _user.phone;
  late final String _profileImg = _user.profileImage ?? defaultProfileUri;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 55),
          alignment: Alignment.topLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 145),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: IconButton(
                    padding: EdgeInsets.zero, // Set padding to zero
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Image.asset("assets/icons/sign_in_back.png"),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "What's your name?",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
              ),
              const SizedBox(height: 5),
              const Text(
                "Use your real name, it'll help others recognize you!",
                style: TextStyle(
                    color: Color.fromRGBO(0, 0, 0, 0.50), fontSize: 12),
              ),
              const SizedBox(height: 20),
              const Text('Name', style: TextStyle(fontSize: 18)),
              const SizedBox(
                height: 6,
              ),
              TextField(
                controller: _nameController,
                onChanged: (value) {
                  setState(() {
                    _name = value;
                  });
                },
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: Color.fromRGBO(255, 58, 11, 1.0),
                      width: 4.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: Color.fromRGBO(255, 58, 11, 1.0),
                      width: 4.0,
                    ),
                  ),
                  contentPadding:
                      const EdgeInsets.only(top: 13, bottom: 13, left: 10),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Username', style: TextStyle(fontSize: 18)),
              const SizedBox(
                height: 6,
              ),
              TextField(
                controller: _usernameController,
                onChanged: (value) {
                  setState(() {
                    _username = value;
                  });
                },
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: Color.fromRGBO(255, 58, 11, 1.0),
                      width: 4.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: Color.fromRGBO(255, 58, 11, 1.0),
                      width: 4.0,
                    ),
                  ),
                  contentPadding:
                      const EdgeInsets.only(top: 13, bottom: 13, left: 10),
                ),
              ),
              const SizedBox(height: 40),
              Center(
                  child: SizedBox(
                      width: 190,
                      height: 40,
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        color: const Color(0xFFF04914),
                        borderRadius: BorderRadius.circular(20),
                        onPressed: _name != "" && _username != ""
                            ? () async {
                                if (await UserService.usernameExists(
                                        _username) ==
                                    false) {
                                  if (mounted) {
                                    Navigator.of(context).push(StaticPageRoute(
                                      child: CreateProfilePic(
                                        signUpCallback: signUpUser,
                                        signUp: true,     
                                      ),
                                    ));
                                  }
                                } else {
                                  await showErrorDialog(
                                      "Another account with a similar username already exists. Please try a different username",
                                      title:
                                          "Could not create the given username",
                                      action: "OK");
                                }
                              }
                            : null,
                        child: const Text(
                          'NEXT',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ))),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> signUpUser() async {
    await CredentialStorageService().setUserProfileImage(_profileImg);
    SignUpRes? res = await UserService.signup(
      _name!,
      _username,
      null,
      _phone,
      _email,
      _profileImg,
      _user.uid,
    );

    if (res != null && mounted) {
      // Navigate to the desired screen after successful sign-up.

      Navigator.of(context).push(
        StaticPageRoute(
          child: const TermsAndConditions(),
        ),
      );

    }
  }

  @override
  void initState() {
    super.initState();
    _user = widget._user;
    _nameController = TextEditingController(text: _user.name);
    _usernameController = TextEditingController();
  }
}
