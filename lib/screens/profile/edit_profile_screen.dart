import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final nameController = TextEditingController();
  final bioController = TextEditingController();

  final user = FirebaseAuth.instance.currentUser;

  File? imageFile;
  bool isLoading = false;

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    var doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get();

    var data = doc.data();

    if (data != null) {
      nameController.text = data["name"] ?? "";
      bioController.text = data["bio"] ?? "";
    }
  }

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  }

  Future<String?> uploadImage(File file) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child("profile/${user!.uid}.jpg");

      await ref.putFile(file);

      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  Future<void> saveProfile() async {
    setState(() {
      isLoading = true;
    });

    String? imageUrl;

    if (imageFile != null) {
      imageUrl = await uploadImage(imageFile!);
    }

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .update({
      "name": nameController.text.trim(),
      "bio": bioController.text.trim(),
      if (imageUrl != null) "image": imageUrl,
    });

    setState(() {
      isLoading = false;
    });

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Edit Profile"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Colors.grey.shade800,
                backgroundImage:
                    imageFile != null ? FileImage(imageFile!) : null,
                child: imageFile == null
                    ? const Icon(Icons.camera_alt, size: 40)
                    : null,
              ),
            ),

            const SizedBox(height: 25),

            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Name",
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.grey.shade900,
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: bioController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Bio",
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.grey.shade900,
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : saveProfile,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}