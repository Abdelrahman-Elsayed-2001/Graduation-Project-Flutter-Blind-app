import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';


class UserImg extends StatelessWidget {
  final String? image;
  final double? size;

  UserImg({
    required this.image,
    this.size,
  });

  bool incorrectImagePath = true;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius : size ?? 19,
      backgroundColor: Colors.blue.withOpacity(0.3), // Adjust the opacity here
      backgroundImage: image != null && image!.isNotEmpty
          ? imgType(image!)
          : null,
      child: image == null || image!.isEmpty || incorrectImagePath
          ? const Icon(Icons.person, color: Colors.blue) //
          : null,
    );
  }

  imgType(String image){
    File imageFile = File(image);
    bool fileExists = imageFile.existsSync();

    if(fileExists){
      incorrectImagePath = false;
      return AssetImage(image);
    }else if (image.startsWith('http') && ! image.startsWith('http://localhost')){
      incorrectImagePath = false;
      return NetworkImage(image);
    }else{
      incorrectImagePath = true;
      return null;
    }
  }

}
