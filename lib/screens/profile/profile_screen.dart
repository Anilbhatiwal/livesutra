import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../auth/welcome_screen.dart';
import 'edit_profile_screen.dart';


class ProfileScreen extends StatefulWidget {

  const ProfileScreen({
    super.key,
  });


  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();

}



class _ProfileScreenState
    extends State<ProfileScreen> {


  final User? user =
      FirebaseAuth.instance.currentUser;



  Stream<DocumentSnapshot> getUserData() {


    if(user == null){

      return const Stream.empty();

    }


    return FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .snapshots();

  }



  Widget statBox(
      String title,
      dynamic value,
  ){

    return Column(

      children: [

        Text(

          value.toString(),

          style: const TextStyle(

            color: Colors.white,

            fontSize: 18,

            fontWeight:
                FontWeight.bold,

          ),

        ),


        const SizedBox(height:5),


        Text(

          title,

          style: const TextStyle(

            color: Colors.grey,

          ),

        ),

      ],

    );

  }



  Widget menuTile(
      IconData icon,
      String title,
  ){

    return Container(

      margin:
          const EdgeInsets.symmetric(
              vertical: 6),

      decoration: BoxDecoration(

        color:
            Colors.grey.shade900,

        borderRadius:
            BorderRadius.circular(12),

      ),


      child: ListTile(

        leading: Icon(

          icon,

          color: Colors.white,

        ),


        title: Text(

          title,

          style:
              const TextStyle(

            color: Colors.white,

          ),

        ),


        trailing:

            const Icon(

              Icons.arrow_forward_ios,

              size:15,

              color: Colors.grey,

            ),

      ),

    );

  }





  @override
  Widget build(BuildContext context) {


    return Scaffold(

      backgroundColor:
          Colors.black,


      appBar: AppBar(

        backgroundColor:
            Colors.black,


        title:
            const Text(
              "Profile",
            ),


        actions: [

          IconButton(

            icon:
                const Icon(
                  Icons.edit,
                ),


            onPressed: (){


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



      body:

      StreamBuilder<DocumentSnapshot>(


        stream:
            getUserData(),


        builder:
            (context,snapshot){



          if(snapshot.connectionState ==
              ConnectionState.waiting){


            return const Center(

              child:
                  CircularProgressIndicator(),

            );


          }




          if(!snapshot.hasData ||
              !snapshot.data!.exists){


            return const Center(

              child:

              Text(

                "No Profile Data",

                style:
                    TextStyle(
                      color:
                      Colors.white,
                    ),

              ),

            );


          }




          final data =
          snapshot.data!.data()
          as Map<String,dynamic>;



          String photoUrl =
              data["photoUrl"] ?? "";



          return SingleChildScrollView(

            padding:
                const EdgeInsets.all(20),


            child: Column(

              children: [



                CircleAvatar(

                  radius:60,

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

                    size:60,

                    color:Colors.white,

                  )

                      : null,

                ),




                const SizedBox(height:15),




                Row(

                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  children: [


                    Text(

                      data["name"] ??
                          "User",

                      style:
                      const TextStyle(

                        color:
                        Colors.white,

                        fontSize:22,

                        fontWeight:
                        FontWeight.bold,

                      ),

                    ),



                    const SizedBox(width:8),



                    Container(

                      padding:
                      const EdgeInsets.symmetric(
                        horizontal:8,
                        vertical:3,
                      ),

                      decoration:
                      BoxDecoration(

                        color:
                        Colors.orange,

                        borderRadius:
                        BorderRadius.circular(10),

                      ),

                      child:
                      Text(

                        "VIP ${data["vipLevel"] ?? 0}",

                        style:
                        const TextStyle(

                          color:
                          Colors.black,

                          fontSize:12,

                          fontWeight:
                          FontWeight.bold,

                        ),

                      ),

                    )


                  ],

                ),



                const SizedBox(height:8),



                Text(

                  "Level ${data["level"] ?? 1}",

                  style:
                  const TextStyle(

                    color:
                    Colors.amber,

                  ),

                ),




                const SizedBox(height:20),




                Container(

                  padding:
                  const EdgeInsets.all(18),


                  decoration:
                  BoxDecoration(

                    color:
                    Colors.grey.shade900,

                    borderRadius:
                    BorderRadius.circular(15),

                  ),


                  child: Row(

                    mainAxisAlignment:
                    MainAxisAlignment.spaceAround,


                    children: [


                      statBox(
                        "Coins",
                        data["coins"] ?? 0,
                      ),


                      statBox(
                        "Diamonds",
                        data["diamonds"] ?? 0,
                      ),


                    ],

                  ),

                ),




                const SizedBox(height:20),




                Row(

                  mainAxisAlignment:
                  MainAxisAlignment.spaceAround,


                  children: [


                    statBox(
                      "Followers",
                      data["followers"] ?? 0,
                    ),


                    statBox(
                      "Following",
                      data["following"] ?? 0,
                    ),


                    statBox(
                      "Likes",
                      data["likes"] ?? 0,
                    ),


                  ],

                ),




                const SizedBox(height:30),




                menuTile(
                    Icons.account_balance_wallet,
                    "Wallet"
                ),


                menuTile(
                    Icons.card_giftcard,
                    "My Gifts"
                ),


                menuTile(
                    Icons.video_library,
                    "Live History"
                ),


                menuTile(
                    Icons.settings,
                    "Settings"
                ),





                const SizedBox(height:20),




                SizedBox(

                  width:
                  double.infinity,


                  child:
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



                      if(!context.mounted)
                        return;



                      Navigator.pushAndRemoveUntil(

                        context,

                        MaterialPageRoute(

                          builder: (_) =>
                          const WelcomeScreen(),

                        ),

                            (route)=>false,

                      );


                    },


                    child:
                    const Text(
                      "Logout",
                    ),

                  ),

                )



              ],

            ),

          );



        },

      ),

    );

  }

}