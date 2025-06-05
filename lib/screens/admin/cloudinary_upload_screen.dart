import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:myapp/screens/admin/add_products.dart';
import 'package:myapp/services/cloudinary_service.dart';

class CloudinaryUploadScreen extends StatefulWidget {
  @override
  _CloudinaryUploadScreenState createState() => _CloudinaryUploadScreenState();
}

class _CloudinaryUploadScreenState extends State<CloudinaryUploadScreen> {
  File? _imageFile;
  String? _uploadedUrl;
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      final uploaded = await CloudinaryService.uploadImage(_imageFile!);
      setState(() {
        _uploadedUrl = uploaded;
        if (_uploadedUrl != null) {
          print('Uploaded Image URL: $_uploadedUrl'); // Print the URL here
        }
      });
    }
  }

  Future<void> _backtoAddProduct() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AddProductScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload ảnh lên Cloudinary')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Chọn ảnh & Upload'),
            ),
            SizedBox(height: 20), // Thêm khoảng cách

            SizedBox(height: 20),
            if (_uploadedUrl != null) ...[
              Text(
                'Ảnh đã upload:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Image.network(
                _uploadedUrl!,
                height: 200,
              ), // Giới hạn chiều cao ảnh cho dễ nhìn
              SizedBox(height: 10),
              Text('Link ảnh:', style: TextStyle(fontWeight: FontWeight.bold)),
              SelectableText(
                _uploadedUrl!,
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
            SizedBox(height: 20), // Thêm khoảng cách
            ElevatedButton(
              onPressed: _backtoAddProduct,
              child: Text('Quay lại Thêm Sản Phẩm'),
            ),
          ],
        ),
      ),
    );
  }
}
