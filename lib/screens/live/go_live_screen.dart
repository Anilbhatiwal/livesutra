import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/live_model.dart';
import '../../services/live_service.dart';
import 'live_room_screen.dart';

class GoLiveScreen extends StatefulWidget {
  const GoLiveScreen({super.key});

  @override
  State<GoLiveScreen> createState() => _GoLiveScreenState();
}

class _GoLiveScreenState extends State<GoLiveScreen> {

  final titleController = TextEditingController();

  final FirebaseAuth auth =
      FirebaseAuth.instance;

  bool loading = false;

  String selectedCategory = "Chat";

  final List<String> categories = [

    "Chat",

    "Music",

    "Gaming",

    "Dance",

    "Education",

    "Travel",

    "Lifestyle",

  ];

  String generateLiveID() {

    final random = Random();

    return DateTime.now()
            .millisecondsSinceEpoch
            .toString() +
        random.nextInt(99999).toString();

  }

  Future<void> startLive() async {

    if(titleController.text.trim().isEmpty){

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(

          content: Text("Enter Live Title"),

        ),

      );

      return;

    }

    setState(() {

      loading = true;

    });

    final user = auth.currentUser!;
    final userDoc = await FirebaseFirestore.instance
    .collection("users")
    .doc(user.uid)
    .get();

final userData = userDoc.data() ?? {};

    final liveID = generateLiveID();

    final live = LiveModel(

      liveId: liveID,

      hostId: user.uid,

      hostName: userData["name"] ?? "Host",

hostImage: userData["photoUrl"] ?? "",

      viewers: 0,

      isLive: true,

      startedAt: DateTime.now(),

    );

    try {
  debugPrint("Creating Live Room...");

  await LiveService.createLive(live);

  debugPrint("Live Room Created Successfully");

  setState(() {
    loading = false;
  });

  if (!mounted) return;

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => LiveRoomScreen(
        isHost: true,
        liveID: liveID,
        hostID: user.uid,
        hostName: user.displayName ?? user.email ?? "Host",
        hostImage: user.photoURL ?? "",
      ),
    ),
  );
} catch (e) {
  debugPrint("Live Create Error: $e");

  if (!mounted) return;

  setState(() {
    loading = false;
  });

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(e.toString()),
    ),
  );
}
  }

  @override
  Widget build(BuildContext context) {

    final user = auth.currentUser;

    return Scaffold(

      backgroundColor: Colors.black,

      appBar: AppBar(
        title: const Text("Go Live"),
        backgroundColor: Colors.black,
        elevation: 0,
      ),

      body: SafeArea(

        child: SingleChildScrollView(

          padding: const EdgeInsets.all(20),

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              const SizedBox(height: 20),

              Center(

                child: CircleAvatar(

                  radius: 55,

                  backgroundImage: user?.photoURL != null &&
                          user!.photoURL!.isNotEmpty
                      ? NetworkImage(user.photoURL!)
                      : null,

                  child: user?.photoURL == null ||
                          user!.photoURL!.isEmpty
                      ? const Icon(
                          Icons.person,
                          size: 55,
                        )
                      : null,

                ),

              ),

              const SizedBox(height: 20),

              Center(
                child: Text(
                  user?.displayName ??
                      user?.email ??
                      "Host",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 35),

              const Text(
                "Live Title",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 10),

              TextField(

                controller: titleController,

                style: const TextStyle(
                  color: Colors.white,
                ),

                decoration: InputDecoration(

                  hintText: "Enter Live Title",

                  hintStyle: const TextStyle(
                    color: Colors.white54,
                  ),

                  filled: true,

                  fillColor: Colors.grey.shade900,

                  border: OutlineInputBorder(

                    borderRadius:
                        BorderRadius.circular(15),

                    borderSide: BorderSide.none,

                  ),

                ),

              ),

              const SizedBox(height: 25),

              const Text(
                "Category",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 10),

              DropdownButtonFormField<String>(

                dropdownColor: Colors.grey.shade900,

                initialValue: selectedCategory,

                decoration: InputDecoration(

                  filled: true,

                  fillColor: Colors.grey.shade900,

                  border: OutlineInputBorder(

                    borderRadius:
                        BorderRadius.circular(15),

                  ),

                ),

                items: categories.map((e) {

                  return DropdownMenuItem(

                    value: e,

                    child: Text(
                      e,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),

                  );

                }).toList(),

                onChanged: (value) {

                  if (value == null) return;

                  setState(() {

                    selectedCategory = value;

                  });

                },

              ),
                            const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(

                  onPressed: loading ? null : startLive,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(15),
                    ),
                  ),

                  child: loading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "GO LIVE",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 25),

              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius:
                      BorderRadius.circular(15),
                ),
                child: const Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    Text(
                      "Live Tips",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    SizedBox(height: 10),

                    Text(
                      "• Keep good lighting\n"
                      "• Use a stable internet connection\n"
                      "• Interact with viewers\n"
                      "• Follow community guidelines",
                      style: TextStyle(
                        color: Colors.white70,
                        height: 1.6,
                      ),
                    ),

                  ],
                ),
              ),

              const SizedBox(height: 30),

            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }
}