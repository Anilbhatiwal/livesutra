import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/cloudinary_service.dart';

class UploadPostScreen extends StatefulWidget {
  const UploadPostScreen({super.key});

  @override
  State<UploadPostScreen> createState() =>
      _UploadPostScreenState();
}

class _UploadPostScreenState
    extends State<UploadPostScreen> {
  final TextEditingController captionController =
      TextEditingController();

  final ImagePicker picker = ImagePicker();

  final CloudinaryService cloudinaryService =
      CloudinaryService();

  File? selectedImage;

  bool isLoading = false;

  Future<void> pickImage() async {
    final XFile? image =
        await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  Future<void> uploadPost() async {

    if (selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please Select Image",
          ),
        ),
      );
      return;
    }

    if (captionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please Enter Caption",
          ),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {

      String? imageUrl =
          await cloudinaryService.uploadImage(
        selectedImage!,
      );

      if (imageUrl == null) {
        throw Exception(
          "Image Upload Failed",
        );
      }

      await FirebaseFirestore.instance
          .collection("posts")
          .add({

        "userId":"demoUser",

        "userName":"Arjun",

        "imageUrl":imageUrl,

        "caption":
            captionController.text.trim(),

        "likes":0,

        "createdAt":
            FieldValue.serverTimestamp(),

      });

      captionController.clear();

      selectedImage = null;

      if (mounted) {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(

            content: Text(
              "Post Uploaded Successfully",
            ),
          ),
        );
              }

    } catch (e) {

      if (mounted) {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          SnackBar(

            content: Text(
              e.toString(),
            ),
          ),
        );
      }

    }

    setState(() {

      isLoading = false;

    });

  }

  @override
  void dispose() {

    captionController.dispose();

    super.dispose();

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      resizeToAvoidBottomInset: true,

      backgroundColor: Colors.black,

      appBar: AppBar(

        backgroundColor: Colors.black,

        title: const Text(
          "Create Post",
        ),

      ),

      body: SafeArea(

        child: SingleChildScrollView(

          padding: const EdgeInsets.all(20),

          child: Column(

            children: [

              GestureDetector(

                onTap: pickImage,

                child: Container(

                  height: 220,

                  width: double.infinity,

                  decoration: BoxDecoration(

                    color: Colors.grey.shade900,

                    borderRadius:
                        BorderRadius.circular(15),

                  ),

                  child: selectedImage == null

                      ? const Center(

                          child: Icon(

                            Icons.add_a_photo,

                            size: 60,

                            color: Colors.white,

                          ),

                        )

                      : ClipRRect(

                          borderRadius:
                              BorderRadius.circular(
                                  15),

                          child: Image.file(

                            selectedImage!,

                            fit: BoxFit.cover,

                          ),

                        ),

                ),

              ),

              const SizedBox(height: 20),

              TextField(

                controller:
                    captionController,

                maxLines: 3,

                style: const TextStyle(

                  color: Colors.white,

                ),

                decoration: InputDecoration(

                  hintText:
                      "Write Caption...",

                  hintStyle:
                      const TextStyle(

                    color:
                        Colors.white54,

                  ),

                  filled: true,

                  fillColor:
                      Colors.grey.shade900,

                  border:
                      OutlineInputBorder(

                    borderRadius:
                        BorderRadius.circular(
                            12),

                  ),

                ),

              ),

              const SizedBox(height: 30),

              SizedBox(

                width: double.infinity,

                height: 55,

                child: ElevatedButton(

                  onPressed: isLoading
                      ? null
                      : uploadPost,

                  child: isLoading
                                        ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Upload Post",
                          style: TextStyle(
                            fontSize: 16,
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