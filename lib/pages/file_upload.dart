import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class UploadFile extends StatefulWidget {
  const UploadFile({super.key});

  @override
  State<UploadFile> createState() => _UploadFileState();
}

class _UploadFileState extends State<UploadFile> {
  File? image;
  final _picker = ImagePicker();
  bool isLoading = false;

  Future getImage() async {
    final pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (pickedFile != null) {
      image = File(pickedFile.path);
      setState(() {});
    } else {
      print("No Image Selected");
    }
  }

  Future<void> uploadImage() async {
    setState(() {
      isLoading = true;
    });

    var stream = new http.ByteStream(image!.openRead());
    stream.cast();
    var length = await image!.length();

    var uri = Uri.parse("https://fakestoreapi.com/products");
    var request = new http.MultipartRequest('POST', uri);
    request.fields['title'] = "Title Fields";
    var multipart = new http.MultipartFile('image', stream, length);

    request.files.add(multipart);
    var response = await request.send();

    if (response.statusCode == 200) {
      setState(() {
        isLoading = false;
      });
      print("Image Uploaded");
      image = null;
    } else {
      print("Failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent.withOpacity(0.6),
          title: Text("File Upload"),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                onTap: getImage,
                child: Container(
                  width: 350,
                  child: image == null
                      ? const Center(
                          child: Text(
                            "No Image Selected!",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : Center(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50.0),
                              child: Image.file(
                                File(image!.path).absolute,
                                height: 300,
                                width: 300,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              image != null
                  ? InkWell(
                      onTap: uploadImage,
                      child: Container(
                        width: 120,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Center(
                          child: Text(
                            "UPLOAD",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                              fontSize: 22.0,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(""),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
