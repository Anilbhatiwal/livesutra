import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../auth/welcome_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends State<ProfileScreen> {

  final user =
      FirebaseAuth.instance.currentUser;

  Stream<DocumentSnapshot> getUserData() {

    return FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .snapshots();

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.black,

      appBar: AppBar(

        backgroundColor: Colors.black,

        title: const Text("Profile"),

        actions: [

          IconButton(

            icon: const Icon(Icons.edit),

            onPressed: () {

              Navigator.push(

                context,

                MaterialPageRoute(

                  builder: (_) =>
                      const EditProfileScreen(),

                ),

              );

            },

          )

        ],

      ),

      body: StreamBuilder<DocumentSnapshot>(

        stream: getUserData(),

        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {

            return const Center(

              child: CircularProgressIndicator(),

            );

          }

          if (!snapshot.hasData ||
              !snapshot.data!.exists) {

            return const Center(

              child: Text(

                "No Profile Data",

                style: TextStyle(
                  color: Colors.white,
                ),

              ),

            );

          }

          final data =
              snapshot.data!.data()
                  as Map<String, dynamic>;

          String photoUrl =
              data["photoUrl"] ?? "";

          return Center(

            child: Column(

              mainAxisAlignment:
                  MainAxisAlignment.center,

              children: [

                CircleAvatar(

                  radius: 55,

                  backgroundColor:
                      Colors.grey.shade800,

                  backgroundImage:

                      photoUrl.isNotEmpty

                          ? NetworkImage(photoUrl)

                          : null,

                  child:

                      photoUrl.isEmpty

                          ? const Icon(

                              Icons.person,

                              size: 50,

                            )

                          : null,

                ),

                const SizedBox(height: 20),

                Text(

                  data["name"] ??
                      "No Name",

                  style:
                      const TextStyle(

                    color: Colors.white,

                    fontSize: 22,

                    fontWeight:
                        FontWeight.bold,

                  ),

                ),

                const SizedBox(height: 8),

                Text(

                  data["email"] ??
                      "",

                  style:
                      const TextStyle(

                    color: Colors.grey,

                  ),

                ),

                const SizedBox(height: 12),

                Text(

                  data["bio"] ??
                      "",

                  textAlign:
                      TextAlign.center,

                  style:
                      const TextStyle(

                    color:
                        Colors.white70,

                    fontSize: 15,

                  ),

                ),

                const SizedBox(height: 35),

                ElevatedButton(

                  style:
                      ElevatedButton.styleFrom(

                    backgroundColor:
                        Colors.red,

                  ),

                  onPressed: () async {

                    await FirebaseAuth
                        .instance
                        .signOut();

                    if (!context.mounted) {
                      return;
                    }

                    Navigator.pushAndRemoveUntil(

                      context,

                      MaterialPageRoute(

                        builder: (_) =>
                            const WelcomeScreen(),

                      ),

                      (route) => false,

                    );

                  },

                  child:
                      const Text("Logout"),

                ),

              ],

            ),

          );

        },

      ),

    );

  }

}