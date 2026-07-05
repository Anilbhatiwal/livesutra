import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/cloudinary_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends State<EditProfileScreen> {

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController bioController =
      TextEditingController();

  final ImagePicker picker = ImagePicker();

  final CloudinaryService cloudinaryService =
      CloudinaryService();

  final user =
      FirebaseAuth.instance.currentUser;

  File? imageFile;

  String currentPhoto = "";

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get();

    if (!doc.exists) return;

    final data = doc.data()!;

    nameController.text =
        data["name"] ?? "";

    bioController.text =
        data["bio"] ?? "";

    currentPhoto =
        data["photoUrl"] ?? "";

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> pickImage() async {

    final XFile? picked =
        await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (picked != null) {

      setState(() {

        imageFile = File(
          picked.path,
        );

      });

    }

  }

  Future<void> saveProfile() async {

    setState(() {

      isLoading = true;

    });

    String photoUrl =
        currentPhoto;

    if (imageFile != null) {

      final uploaded =
          await cloudinaryService.uploadImage(
        imageFile!,
      );

      if (uploaded != null) {

        photoUrl = uploaded;

      }

    }
        await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .update({

      "name": nameController.text.trim(),

      "bio": bioController.text.trim(),

      "photoUrl": photoUrl,

    });

    setState(() {

      isLoading = false;

    });

    if (mounted) {

      Navigator.pop(context);

    }

  }

  @override
  void dispose() {

    nameController.dispose();

    bioController.dispose();

    super.dispose();

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.black,

      appBar: AppBar(

        backgroundColor: Colors.black,

        title: const Text(
          "Edit Profile",
        ),

      ),

      body: SafeArea(

        child: SingleChildScrollView(

          padding: const EdgeInsets.all(20),

          child: Column(

            children: [

              GestureDetector(

                onTap: pickImage,

                child: CircleAvatar(

                  radius: 55,

                  backgroundColor:
                      Colors.grey.shade800,

                  backgroundImage:

                      imageFile != null

                          ? FileImage(imageFile!)

                          : currentPhoto.isNotEmpty

                              ? NetworkImage(currentPhoto)

                              : null,

                  child:

                      imageFile == null &&
                              currentPhoto.isEmpty

                          ? const Icon(

                              Icons.camera_alt,

                              size: 40,

                            )

                          : null,

                ),

              ),

              const SizedBox(height: 25),

              TextField(

                controller: nameController,

                style: const TextStyle(
                  color: Colors.white,
                ),

                decoration: InputDecoration(

                  labelText: "Name",

                  labelStyle:
                      const TextStyle(
                    color: Colors.white70,
                  ),

                  filled: true,

                  fillColor:
                      Colors.grey.shade900,

                ),

              ),

              const SizedBox(height: 15),

              TextField(

                controller: bioController,

                maxLines: 3,

                style: const TextStyle(
                  color: Colors.white,
                ),

                decoration: InputDecoration(

                  labelText: "Bio",

                  labelStyle:
                      const TextStyle(
                    color: Colors.white70,
                  ),

                  filled: true,

                  fillColor:
                      Colors.grey.shade900,

                ),

              ),

              const SizedBox(height: 30),

              SizedBox(

                width: double.infinity,

                height: 50,

                child: ElevatedButton(

                  onPressed:
                      isLoading
                          ? null
                          : saveProfile,

                  child: isLoading
                                        ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Save Profile",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}