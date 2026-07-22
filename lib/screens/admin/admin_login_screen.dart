import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'admin_home_screen.dart';


class AdminLoginScreen extends StatefulWidget {

  const AdminLoginScreen({
    super.key,
  });


  @override
  State<AdminLoginScreen> createState() =>
      _AdminLoginScreenState();

}



class _AdminLoginScreenState
    extends State<AdminLoginScreen> {


  final emailController =
      TextEditingController();


  final passwordController =
      TextEditingController();



  bool loading = false;



  Future<void> adminLogin() async {


    try {


      setState(() {

        loading = true;

      });



      UserCredential credential =
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(

        email:
        emailController.text.trim(),

        password:
        passwordController.text.trim(),

      );



      final uid =
          credential.user!.uid;



      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .get();




      if(!userDoc.exists){

        throw Exception(
            "User data not found"
        );

      }




      final data =
      userDoc.data()
      as Map<String,dynamic>;



      if(data["role"] != "admin"){


        await FirebaseAuth.instance
            .signOut();


        throw Exception(
            "Access denied"
        );


      }





      if(!mounted)
        return;



      Navigator.pushReplacement(

        context,

        MaterialPageRoute(

          builder: (_)=>
          const AdminHomeScreen(),

        ),

      );



    }

    catch(e){


      if(!mounted)
        return;



      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          content:
          Text(
              e.toString()
          ),

        ),

      );


    }


    finally{


      setState(() {

        loading = false;

      });


    }


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
          "Admin Login",
        ),

        centerTitle:true,

      ),



      body:

      Padding(

        padding:
        const EdgeInsets.all(20),


        child:

        Column(

          mainAxisAlignment:
          MainAxisAlignment.center,


          children:[



            TextField(

              controller:
              emailController,


              style:
              const TextStyle(
                color: Colors.white,
              ),


              decoration:

              const InputDecoration(

                labelText:
                "Email",

                labelStyle:
                TextStyle(
                  color: Colors.grey,
                ),

              ),

            ),



            const SizedBox(
                height:20),




            TextField(

              controller:
              passwordController,


              obscureText:true,


              style:
              const TextStyle(
                color: Colors.white,
              ),



              decoration:

              const InputDecoration(

                labelText:
                "Password",

                labelStyle:
                TextStyle(
                  color: Colors.grey,
                ),

              ),


            ),




            const SizedBox(
                height:30),





            SizedBox(

              width:
              double.infinity,


              child:

              ElevatedButton(

                onPressed:
                loading
                    ? null
                    : adminLogin,


                style:

                ElevatedButton.styleFrom(

                  backgroundColor:
                  Colors.red,

                ),


                child:

                loading

                    ?

                const CircularProgressIndicator()

                    :

                const Text(
                  "Login",
                ),

              ),

            )



          ],

        ),

      ),

    );


  }


}