import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

      final uploaded = await _uploadImageToCloudinary(_imageFile!);
      setState(() {
        _uploadedUrl = uploaded;
        if (_uploadedUrl != null) {
          print('Uploaded Image URL: $_uploadedUrl'); // Print the URL here
        }
      });
    }
  }

  Future<String?> _uploadImageToCloudinary(File image) async {
    const cloudName = 'dsospn8r7'; // 🔁 Thay bằng Cloud name của bạn
    const uploadPreset =
        'demo_unsigned'; // 🔁 Thay bằng upload preset (unsigned)

    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final request =
        http.MultipartRequest('POST', url)
          ..fields['upload_preset'] = uploadPreset
          ..files.add(await http.MultipartFile.fromPath('file', image.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseString = await response.stream.bytesToString();
      final decoded = json.decode(responseString);
      return decoded['secure_url'];
    } else {
      print('Upload failed: ${response.statusCode}');
      return null;
    }
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
          ],
        ),
      ),
    );
  }
}
