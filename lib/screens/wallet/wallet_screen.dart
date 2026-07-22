import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class WalletScreen extends StatelessWidget {

  const WalletScreen({
    super.key,
  });



  final Color bg =
      const Color(0xff121212);



  @override
  Widget build(BuildContext context) {


    final user =
        FirebaseAuth.instance.currentUser;



    return Scaffold(

      backgroundColor: bg,


      appBar: AppBar(

        backgroundColor: Colors.black,

        centerTitle: true,

        title:

        const Text(

          "Wallet",

          style:

          TextStyle(

            fontWeight:
            FontWeight.bold,

          ),

        ),

      ),



      body:

      StreamBuilder<DocumentSnapshot>(


        stream:

        FirebaseFirestore.instance

            .collection("users")

            .doc(user!.uid)

            .snapshots(),



        builder:(context,snapshot){



          if(!snapshot.hasData){

            return const Center(

              child:
              CircularProgressIndicator(),

            );

          }



          final data =
          snapshot.data!.data()
          as Map<String,dynamic>?;



          int coins =
              data?["coins"] ?? 0;



          int diamonds =
              data?["diamonds"] ?? 0;



          return ListView(

            padding:
            const EdgeInsets.all(16),


            children: [



              Container(

                padding:
                const EdgeInsets.all(20),


                decoration:

                BoxDecoration(

                  borderRadius:
                  BorderRadius.circular(20),


                  gradient:

                  const LinearGradient(

                    colors:[

                      Color(0xff6A5AE0),

                      Color(0xff8F7CFF),

                    ],

                  ),

                ),



                child:

                Column(

                  crossAxisAlignment:
                  CrossAxisAlignment.start,


                  children:[



                    const Text(

                      "Total Balance",

                      style:

                      TextStyle(

                        color:
                        Colors.white70,

                      ),

                    ),



                    const SizedBox(
                        height:10),



                    Text(

                      "₹${coins ~/ 10}",

                      style:

                      const TextStyle(

                        color:
                        Colors.white,

                        fontSize:34,

                        fontWeight:
                        FontWeight.bold,

                      ),

                    ),




                    const SizedBox(
                        height:20),



                    Row(

                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,


                      children:[


                        balanceItem(
                            "Coins",
                            coins
                        ),


                        balanceItem(
                            "Diamonds",
                            diamonds
                        ),


                      ],

                    )

                  ],

                ),

              ),




              const SizedBox(
                  height:25),




              Row(

                children:[



                  Expanded(

                    child:
                    ElevatedButton.icon(

                      onPressed:(){

                        // recharge later

                      },


                      icon:

                      const Icon(
                          Icons.add_circle_outline),


                      label:

                      const Text(
                          "Recharge"),



                      style:

                      ElevatedButton.styleFrom(

                        backgroundColor:
                        Colors.orange,

                      ),

                    ),

                  ),



                  const SizedBox(
                      width:15),




                  Expanded(

                    child:
                    ElevatedButton.icon(

                      onPressed:(){


                        // withdraw later


                      },


                      icon:

                      const Icon(
                          Icons.account_balance_wallet),


                      label:

                      const Text(
                          "Withdraw"),



                      style:

                      ElevatedButton.styleFrom(

                        backgroundColor:
                        Colors.green,

                      ),

                    ),

                  )



                ],

              ),





              const SizedBox(
                  height:30),





              const Text(

                "Recent Transactions",

                style:

                TextStyle(

                  color:
                  Colors.white,

                  fontSize:18,

                  fontWeight:
                  FontWeight.bold,

                ),

              ),




              const SizedBox(
                  height:15),





              StreamBuilder<QuerySnapshot>(


                stream:

                FirebaseFirestore.instance

                    .collection(
                    "wallet_transactions")

                    .where(
                    "userId",
                    isEqualTo:user.uid)

                    .orderBy(
                    "createdAt",
                    descending:true)

                    .snapshots(),



                builder:(context,snapshot){



                  if(!snapshot.hasData){

                    return const Center(

                      child:
                      CircularProgressIndicator(),

                    );

                  }




                  if(snapshot.data!.docs.isEmpty){


                    return const Text(

                      "No Transactions",

                      style:

                      TextStyle(

                        color:
                        Colors.grey,

                      ),

                    );


                  }





                  return Column(


                    children:

                    snapshot.data!.docs.map((doc){


                      final item =
                      doc.data()
                      as Map<String,dynamic>;



                      return transactionTile(

                        icon:
                        Icons.card_giftcard,


                        title:
                        item["title"] ?? "",


                        amount:
                        item["amount"] ?? "",


                        color:
                        Colors.pink,

                      );


                    }).toList(),


                  );

                },

              )



            ],

          );


        },

      ),

    );

  }





  Widget balanceItem(
      String title,
      int value,
      ){

    return Column(

      crossAxisAlignment:
      CrossAxisAlignment.start,

      children:[


        Text(

          title,

          style:

          const TextStyle(

            color:
            Colors.white70,

          ),

        ),


        const SizedBox(height:5),


        Text(

          value.toString(),

          style:

          const TextStyle(

            color:
            Colors.white,

            fontSize:22,

            fontWeight:
            FontWeight.bold,

          ),

        )


      ],

    );

  }






  Widget transactionTile({

    required IconData icon,

    required String title,

    required String amount,

    required Color color,

  }){


    return Card(

      color:
      const Color(0xff1E1E1E),


      child:

      ListTile(

        leading:

        CircleAvatar(

          backgroundColor:
          color.withValues(alpha:0.2),


          child:

          Icon(

            icon,

            color:
            color,

          ),

        ),



        title:

        Text(

          title,

          style:

          const TextStyle(

            color:
            Colors.white,

          ),

        ),



        trailing:

        Text(

          amount,

          style:

          TextStyle(

            color:
            color,

            fontWeight:
            FontWeight.bold,

          ),

        ),


      ),

    );


  }


}