import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'go_live_screen.dart';
import '../../models/live_model.dart';
import 'live_room_screen.dart';

class LiveScreen extends StatefulWidget {
  const LiveScreen({super.key});

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {

  final TextEditingController searchController =
      TextEditingController();

  String searchText = "";

  Future<void> refreshLives() async {
    setState(() {});
    await Future.delayed(
      const Duration(milliseconds: 500),
    );
  }

  Stream<QuerySnapshot> get liveStream {

    return FirebaseFirestore.instance
        .collection("liveRooms")
        .where("isLive", isEqualTo: true)
        .orderBy(
          "startedAt",
          descending: true,
        )
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.black,

      appBar: AppBar(

        backgroundColor: Colors.black,

        elevation: 0,

        centerTitle: true,

        title: const Text(
          "LiveSutra",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [

          IconButton(
  icon: const Icon(Icons.videocam),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const GoLiveScreen(),
      ),
    );
  },
),

        ],

      ),

      body: RefreshIndicator(

        onRefresh: refreshLives,

        child: Column(

          children: [

            const SizedBox(height: 10),

            Padding(

              padding: const EdgeInsets.symmetric(
                horizontal: 15,
              ),

              child: TextField(

                controller: searchController,

                style: const TextStyle(
                  color: Colors.white,
                ),

                decoration: InputDecoration(

                  hintText: "Search Host",

                  hintStyle: const TextStyle(
                    color: Colors.white54,
                  ),

                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.white70,
                  ),

                  filled: true,

                  fillColor: Colors.grey.shade900,

                  border: OutlineInputBorder(

                    borderRadius:
                        BorderRadius.circular(30),

                    borderSide: BorderSide.none,

                  ),

                ),

                onChanged: (value) {

                  setState(() {

                    searchText =
                        value.trim().toLowerCase();

                  });

                },

              ),

            ),

            const SizedBox(height: 15),

            Expanded(

              child: StreamBuilder<QuerySnapshot>(

                stream: liveStream,

                builder: (context, snapshot) {

                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {

                    return const Center(
                      child: CircularProgressIndicator(),
                    );

                  }

                  if (!snapshot.hasData ||
                      snapshot.data!.docs.isEmpty) {

                    return const Center(

                      child: Text(

                        "No Live Available",

                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                        ),

                      ),

                    );

                  }

                  final docs = snapshot.data!.docs;
                                    List<QueryDocumentSnapshot> filtered = docs.where((doc) {

                    final data =
                        doc.data() as Map<String, dynamic>;

                    final hostName =
                        (data["hostName"] ?? "")
                            .toString()
                            .toLowerCase();

                    return hostName.contains(searchText);

                  }).toList();

                  if (filtered.isEmpty) {

                    return const Center(

                      child: Text(

                        "No Result Found",

                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                        ),

                      ),

                    );

                  }

                  return GridView.builder(

                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),

                    itemCount: filtered.length,

                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(

                      crossAxisCount: 2,

                      crossAxisSpacing: 12,

                      mainAxisSpacing: 12,

                      childAspectRatio: .68,

                    ),

                    itemBuilder: (context, index) {
  final data = filtered[index].data() as Map<String, dynamic>;
  final live = LiveModel.fromMap(data);
  
  // 1. Ise yahan bilkul top par likhein (Widget return hone se pehle)
  final user = FirebaseAuth.instance.currentUser;

  return InkWell(
    borderRadius: BorderRadius.circular(18),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LiveRoomScreen(
            isHost: false,
            live: live,
            userId: user?.uid ?? "",          // 2. Ab yeh sahi kaam karega
            userName: user?.displayName ?? "Guest",
            userImage: user?.photoURL ?? "",
          ),
        ),
      );
    },

                        child: Container(

                          decoration: BoxDecoration(

                            color: Colors.grey.shade900,

                            borderRadius:
                                BorderRadius.circular(18),

                          ),

                          child: Stack(

                            children: [

                              Positioned.fill(

                                child: ClipRRect(

                                  borderRadius:
                                      BorderRadius.circular(
                                          18),

                                  child: Image.network(

                                    live.hostImage,

                                    fit: BoxFit.cover,

                                    errorBuilder: (context, error, stackTrace) {

                                      return Container(
                                        color: Colors.grey,
                                      );

                                    },

                                  ),

                                ),

                              ),

                              Positioned.fill(

                                child: Container(

                                  decoration: BoxDecoration(

                                    borderRadius:
                                        BorderRadius.circular(
                                            18),

                                    gradient:
                                        LinearGradient(

                                      begin:
                                          Alignment.topCenter,

                                      end: Alignment.bottomCenter,

                                      colors: [

                                        Colors.transparent,

                                        Colors.black.withValues(alpha: 0.75),

                                      ],

                                    ),

                                  ),

                                ),

                              ),
                                                            /// LIVE BADGE
                              Positioned(
                                top: 12,
                                left: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius:
                                        BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.circle,
                                        color: Colors.white,
                                        size: 8,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        "LIVE",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              /// VIEWERS
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius:
                                        BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.remove_red_eye,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "${live.viewers}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              /// HOST INFO
                              Positioned(
                                left: 12,
                                right: 12,
                                bottom: 12,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [

                                    Row(
                                      children: [

                                        const CircleAvatar(
                                          radius: 16,
                                          backgroundColor:
                                              Colors.white24,
                                          child: Icon(
                                            Icons.person,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),

                                        const SizedBox(width: 8),

                                        Expanded(
                                          child: Text(
                                            live.hostName,
                                            maxLines: 1,
                                            overflow:
                                                TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight:
                                                  FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),

                                        const Icon(
                                          Icons.verified,
                                          color: Colors.blue,
                                          size: 18,
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 10),

                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        /// ElevatedButton ke andar ka code
onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => LiveRoomScreen(
        isHost: false,
        live: live,
        userId: user?.uid ?? "",          // Ab yahan bhi error nahi aayega
        userName: user?.displayName ?? "Guest",
        userImage: user?.photoURL ?? "",
      ),
    ),
  );
},
                                        icon: const Icon(
                                          Icons.play_arrow,
                                          color: Colors.white,
                                        ),
                                        label: const Text(
                                          "Join Live",
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          shape:
                                              RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(
                                                    25),
                                          ),
                                        ),
                                      ),
                                    ),

                                  ],
                                ),
                              ),

                            ],
                          ),
                        ),
                      );
                    },
                  );
                                  },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}