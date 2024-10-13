import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mvp_one/utils/page_routes/static_page_route.dart';
import 'package:mvp_one/screens/home/home.dart';
import 'package:mvp_one/services/credential_storage.service.dart';
import 'package:mvp_one/services/rest/user_services/user.service.dart';
import 'package:provider/provider.dart';
import 'package:mvp_one/providers/load_profile_picture.dart';
import 'package:mvp_one/utils/global.dart';

class TermsAndConditions extends StatefulWidget {
  const TermsAndConditions({super.key});

  @override
  State<TermsAndConditions> createState() => _TermsAndConditionsstate();
}

class _TermsAndConditionsstate extends State<TermsAndConditions> {
  bool? isChecked = false;

  void toggleCheckbox(bool? value) {
    setState(() {
      isChecked = value;
    });
  }

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
                    icon: Image.asset("assets/icons/sign_in_back.png")),
              ),
            ),
            const SizedBox(height: 4),
            const Center(
              child: Text(
                "Terms and conditions",
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 29,
                    fontFamily: "IBM Plex Sans"),
              ),
            ),
            const SizedBox(height: 5),
            const Center(
              child: Text(
                "Please review our terms for a smooth experience.",
                style: TextStyle(
                    color: Color.fromRGBO(0, 0, 0, 0.50),
                    fontSize: 12,
                    fontFamily: "IBM Plex Sans",
                    fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Container(
                width: 304,
                height: 376,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    border: Border.all(
                        color: const Color.fromRGBO(255, 58, 11, 1.0),
                        width: 4.0)),
                child: Scrollbar(
                  interactive: true,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 16.0, right: 16.0, top: 0),
                    child: ListView(
                      padding: const EdgeInsets.only(top: 10),
                      children: const [
                        Text(
                          'Welcome to the awesome world of POSTO SOCIAL INC.! We\'ve got some fun terms and conditions for you to follow. But don\'t worry, we\'ll keep it friendly and straightforward! By using our Service, you\'re agreeing to these terms, so let\'s dive in.\n'
                          '1. Use of Our Service:',
                          style: TextStyle(
                              color: Color.fromRGBO(0, 0, 0, 1),
                              fontSize: 11,
                              fontFamily: "IBM Plex Sans",
                              fontWeight: FontWeight.w600),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 32.0),
                          child: Text(
                            'A. Eligibility: You must be eligible to party with us! That means being able to legally enter into a contract with POSTO SOCIAL INC. and following all the rules, local, national, and international. Sorry, superheroes under 13, you can\'t join the fun, and if we\'ve banned you before, no second chances.\n'
                            'B. POSTO SOCIAL INC. Service: Once you\'re in, we grant you a special license to use our Service with its cool features. Just remember, we still own everything except what you explicitly share with us ("POSTO SOCIAL INC. Content").',
                            style: TextStyle(
                                color: Color.fromRGBO(0, 0, 0, 1),
                                fontSize: 11,
                                fontFamily: "IBM Plex Sans",
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          '2. Accounts: Get ready to join the club! Your POSTO SOCIAL INC. account gives you access to awesome features. But remember, if you\'re creating an account for someone else or a fancy organization.',
                          style: TextStyle(
                              color: Color.fromRGBO(0, 0, 0, 1),
                              fontSize: 11,
                              fontFamily: "IBM Plex Sans",
                              fontWeight: FontWeight.w600),
                        ),
                        Text(
                          "Learn more.",
                          style: TextStyle(
                              color: Color.fromRGBO(29, 161, 243, 1),
                              fontSize: 11,
                              fontFamily: "IBM Plex Sans",
                              fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Checkbox(
                value: isChecked,
                onChanged: toggleCheckbox,
                activeColor: Color.fromRGBO(255, 58, 11, 1.0),
              ),
              const SizedBox(
                width: 196,
                height: 30,
                child: Text(
                    "I've read and agree to the terms of Posto-Social Inc.",
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                        fontFamily: "IBM Plex Sans")),
              ),
            ]),
            const SizedBox(height: 20),
            Center(
                child: SizedBox(
                    width: 190,
                    height: 40,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      color: const Color(0xFFF04914),
                      borderRadius: BorderRadius.circular(40),
                      onPressed: isChecked == true
                          ? () async {
                              String userId =
                                  await CredentialStorageService().getUserId();
                              UserService.acknowledgedTermsAndConditions(
                                  userId);

                              await Navigator.of(context)
                                  .push(StaticPageRoute(child: const Home()));
                              Provider.of<ProfilePicLoad>(
                                      Global.getSCPTabContext(),
                                      listen: false)
                                  .loadProfilePic();
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
      )),
    );
  }
}
