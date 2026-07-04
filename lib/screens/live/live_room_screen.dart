import 'package:flutter/material.dart';

class LiveRoomScreen extends StatelessWidget {
  const LiveRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [

          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.grey.shade900,
            child: const Center(
              child: Icon(
                Icons.live_tv,
                size: 120,
                color: Colors.white54,
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [

                  const CircleAvatar(
                    radius: 22,
                    child: Icon(Icons.person),
                  ),

                  const SizedBox(width: 10),

                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Arjun",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "2.3K Watching",
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(15),
              color: Colors.black54,
              child: Row(
                children: [

                  Expanded(
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Say something...",
                        hintStyle:
                            const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.grey.shade800,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 30,
                    ),
                  ),

                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.card_giftcard,
                      color: Colors.amber,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}