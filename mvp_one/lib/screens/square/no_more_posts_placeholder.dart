import 'package:flutter/material.dart';

class NoMorePostsPlaceholder extends StatelessWidget {
  const NoMorePostsPlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
              width: 80,
              height: 80,
              child: Image.asset('assets/icons/feed_end_icon.png',
                  color: Colors.black)),
          const SizedBox(height: 15),
          const Text("That's all for now!",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 3),
          const Column(
            crossAxisAlignment: CrossAxisAlignment
                .center, // To ensure the text remains centered
            children: [
              Text("Take a look around and come",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  )),
              Text("back later.",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  )),
            ],
          ),
          const SizedBox(height: 15)
        ],
      ),
    );
  }
}
