import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class RechargeScreen extends StatelessWidget {

  const RechargeScreen({
    super.key,
  });



  final List<Map<String,dynamic>> packages = const [

    {
      "amount":99,
      "coins":500,
    },

    {
      "amount":499,
      "coins":3000,
    },

    {
      "amount":999,
      "coins":7000,
    },

    {
      "amount":4999,
      "coins":40000,
    },

  ];




  Future<void> createOrder(
      BuildContext context,
      Map<String,dynamic> pack,
      ) async {


    final user =
        FirebaseAuth.instance.currentUser;



    if(user == null){

      return;

    }



    await FirebaseFirestore.instance
        .collection("wallet_orders")
        .add({

      "userId":
      user.uid,


      "amount":
      pack["amount"],


      "coins":
      pack["coins"],


      "status":
      "pending",


      "createdAt":
      FieldValue.serverTimestamp(),


    });




    if(!context.mounted)
      return;



    ScaffoldMessenger.of(context)
        .showSnackBar(

      const SnackBar(

        content:
        Text(
            "Order Created Successfully"
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
          "Recharge",
        ),

        centerTitle:true,

      ),



      body:

      ListView.builder(


        padding:
        const EdgeInsets.all(16),


        itemCount:
        packages.length,


        itemBuilder:
            (context,index){



          final pack =
          packages[index];



          return Container(

            margin:
            const EdgeInsets.only(
                bottom:15),



            padding:
            const EdgeInsets.all(20),



            decoration:

            BoxDecoration(

              color:
              const Color(0xff1E1E1E),


              borderRadius:
              BorderRadius.circular(18),

            ),



            child:

            Row(

              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,


              children:[



                Column(

                  crossAxisAlignment:
                  CrossAxisAlignment.start,


                  children:[


                    Text(

                      "${pack["coins"]} Coins",

                      style:

                      const TextStyle(

                        color:
                        Colors.white,

                        fontSize:22,

                        fontWeight:
                        FontWeight.bold,

                      ),

                    ),



                    const SizedBox(
                        height:8),



                    Text(

                      "₹${pack["amount"]}",

                      style:

                      const TextStyle(

                        color:
                        Colors.orange,

                        fontSize:18,

                      ),

                    ),


                  ],

                ),




                ElevatedButton(

                  onPressed:(){


                    createOrder(
                        context,
                        pack
                    );


                  },


                  style:

                  ElevatedButton.styleFrom(

                    backgroundColor:
                    Colors.orange,

                  ),



                  child:

                  const Text(
                    "Buy",
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