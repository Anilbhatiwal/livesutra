import 'package:flutter/material.dart';
import 'admin_wallet_orders_screen.dart';


class AdminHomeScreen extends StatelessWidget {

  const AdminHomeScreen({
    super.key,
  });



  Widget adminCard(
      BuildContext context,
      IconData icon,
      String title,
  ){

    return Container(

      margin:
      const EdgeInsets.only(bottom:15),


      decoration:

      BoxDecoration(

        color:
        const Color(0xff1E1E1E),

        borderRadius:
        BorderRadius.circular(15),

      ),


      child:

      ListTile(

        leading:

        CircleAvatar(

          backgroundColor:
          Colors.red.withValues(alpha:0.2),


          child:

          Icon(

            icon,

            color:
            Colors.red,

          ),

        ),



        title:

        Text(

          title,

          style:

          const TextStyle(

            color:
            Colors.white,

            fontSize:18,

          ),

        ),



        trailing:

        const Icon(

          Icons.arrow_forward_ios,

          color:
          Colors.grey,

          size:16,

        ),



        onTap:(){
      
      Navigator.push(
 context,
 MaterialPageRoute(
  builder: (_) =>
   const AdminWalletOrdersScreen(),
 ),
);

        },


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
          "Admin Dashboard",
        ),


        centerTitle:true,

      ),




      body:

      Padding(

        padding:
        const EdgeInsets.all(16),


        child:

        Column(


          children:[



            adminCard(

              context,

              Icons.account_balance_wallet,

              "Wallet Orders",

            ),



            adminCard(

              context,

              Icons.people,

              "Users",

            ),



            adminCard(

              context,

              Icons.report,

              "Reports",

            ),



            adminCard(

              context,

              Icons.settings,

              "Settings",

            ),



          ],


        ),

      ),


    );


  }


}