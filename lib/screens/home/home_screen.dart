import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("LiveSutra Feed"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("posts")
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {

  if (snapshot.hasError) {
    return Center(
      child: Text(
        snapshot.error.toString(),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  if (snapshot.connectionState == ConnectionState.waiting) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  if (!snapshot.hasData) {
    return const Center(
      child: Text(
        "No Data",
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var data = docs[index];

              return Card(
                color: Colors.grey.shade900,
                margin: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.person),
                      ),
                      title: Text(
                        data['userName'] ?? '',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),

                    Image.network(data['imageUrl']),

                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        data['caption'] ?? '',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}