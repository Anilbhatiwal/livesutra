import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AdminWalletOrdersScreen extends StatelessWidget {

  const AdminWalletOrdersScreen({
    super.key,
  });



  Future<void> approveOrder(
      BuildContext context,
      DocumentSnapshot order,
      ) async {


    final data =
    order.data()
    as Map<String,dynamic>;



    String userId =
        data["userId"];



    int coins =
        data["coins"] ?? 0;



    FirebaseFirestore firestore =
        FirebaseFirestore.instance;



    await firestore
        .runTransaction((transaction) async {


      DocumentReference userRef =
      firestore
          .collection("users")
          .doc(userId);



      DocumentSnapshot userDoc =
      await transaction.get(userRef);



      int oldCoins =
          userDoc["coins"] ?? 0;



      transaction.update(

        userRef,

        {

          "coins":
          oldCoins + coins,

        },

      );




      transaction.update(

          order.reference,

          {

            "status":
            "approved",

            "approvedAt":
            FieldValue.serverTimestamp(),

          }

      );



      DocumentReference transactionRef =
      firestore
          .collection("wallet_transactions")
          .doc();



      transaction.set(

        transactionRef,

        {

          "userId":
          userId,


          "title":
          "Recharge",


          "amount":
          "+$coins Coins",


          "type":
          "recharge",


          "createdAt":
          FieldValue.serverTimestamp(),

        },

      );



    });




    if(!context.mounted)
      return;



    ScaffoldMessenger.of(context)
        .showSnackBar(

      const SnackBar(

        content:
        Text(
            "Order Approved"
        ),

      ),

    );


  }





  Future<void> rejectOrder(
      BuildContext context,
      DocumentSnapshot order,
      ) async {



    await order.reference.update({

      "status":
      "rejected",


      "rejectedAt":
      FieldValue.serverTimestamp(),

    });



    if(!context.mounted)
      return;



    ScaffoldMessenger.of(context)
        .showSnackBar(

      const SnackBar(

        content:
        Text(
            "Order Rejected"
        ),

      ),

    );


  }





  @override
  Widget build(BuildContext context) {


    return Scaffold(


      backgroundColor:
      Colors.black,



      appBar:

      AppBar(

        backgroundColor:
        Colors.black,


        title:

        const Text(
          "Wallet Orders",
        ),


        centerTitle:true,

      ),




      body:

      StreamBuilder<QuerySnapshot>(


        stream:

        FirebaseFirestore.instance

            .collection("wallet_orders")

            .where(
            "status",
            isEqualTo:"pending")

            .snapshots(),



        builder:
            (context,snapshot){



          if(!snapshot.hasData){


            return const Center(

              child:
              CircularProgressIndicator(),

            );


          }




          if(snapshot.data!.docs.isEmpty){


            return const Center(

              child:

              Text(

                "No Pending Orders",

                style:

                TextStyle(

                  color:
                  Colors.white,

                ),

              ),

            );


          }





          return ListView.builder(


            padding:
            const EdgeInsets.all(16),



            itemCount:
            snapshot.data!.docs.length,



            itemBuilder:
                (context,index){



              final order =
              snapshot.data!.docs[index];



              final data =
              order.data()
              as Map<String,dynamic>;



              return Container(


                margin:

                const EdgeInsets.only(
                    bottom:15),



                padding:
                const EdgeInsets.all(16),



                decoration:

                BoxDecoration(

                  color:
                  const Color(0xff1E1E1E),


                  borderRadius:
                  BorderRadius.circular(15),

                ),




                child:

                Column(

                  crossAxisAlignment:
                  CrossAxisAlignment.start,


                  children:[



                    Text(

                      "Coins: ${data["coins"]}",

                      style:

                      const TextStyle(

                        color:
                        Colors.white,

                        fontSize:18,

                        fontWeight:
                        FontWeight.bold,

                      ),

                    ),



                    const SizedBox(
                        height:8),




                    Text(

                      "Amount: ₹${data["amount"]}",

                      style:

                      const TextStyle(

                        color:
                        Colors.orange,

                      ),

                    ),



                    const SizedBox(
                        height:8),




                    Text(

                      "User: ${data["userId"]}",

                      style:

                      const TextStyle(

                        color:
                        Colors.grey,

                      ),

                    ),




                    const SizedBox(
                        height:15),




                    Row(

                      children:[



                        Expanded(

                          child:

                          ElevatedButton(

                            onPressed:(){

                              approveOrder(

                                  context,
                                  order

                              );

                            },


                            style:

                            ElevatedButton.styleFrom(

                              backgroundColor:
                              Colors.green,

                            ),


                            child:

                            const Text(
                              "Approve",
                            ),

                          ),

                        ),




                        const SizedBox(
                            width:10),




                        Expanded(

                          child:

                          ElevatedButton(

                            onPressed:(){

                              rejectOrder(

                                  context,
                                  order

                              );

                            },


                            style:

                            ElevatedButton.styleFrom(

                              backgroundColor:
                              Colors.red,

                            ),


                            child:

                            const Text(
                              "Reject",
                            ),

                          ),

                        ),



                      ],

                    )


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