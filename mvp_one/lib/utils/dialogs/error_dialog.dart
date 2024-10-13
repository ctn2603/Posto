import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mvp_one/utils/global.dart';

class ErrorDialog extends StatelessWidget {
  final String? title;
  final String? message;
  final String? action;

  const ErrorDialog(
      {super.key,
      required this.title,
      required this.message,
      required this.action});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0))),
      contentPadding: const EdgeInsets.only(top: 10.0),
      content: SizedBox(
        width: 200.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              title!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 7, bottom: 15, left: 15, right: 15),
              child: Text(
                message!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13),
              ),
            ),
            const Divider(
              color: Colors.grey,
              height: 1.0,
            ),
            InkWell(
              onTap: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
              customBorder: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15)),
              ),
              child: Container(
                padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(15.0),
                      bottomRight: Radius.circular(15.0)),
                ),
                child: Text(
                  action!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showErrorDialog(String message,
    {String title = "Error", String action = "OK"}) async {
  return showDialog(
      context: Global.getGlobalContext(),
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(action),
            ),
          ],
        );
      });
}
