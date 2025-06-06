import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:developer' as developer; // Import để ghi log chi tiết

// Hàm trợ giúp chính để xây dựng widget ảnh sản phẩm
Widget buildProductImageWidget(String imageUrl) {
  // Định nghĩa kích thước ảnh và widget placeholder một lần
  const double imageHeight = 120;
  const double imageWidth = 160;
  final Widget placeholder = Image.asset(
    'assets/images/coffee_placeholder.png',
    height: imageHeight,
    width: imageWidth,
    fit: BoxFit.cover,
  );

  if (imageUrl.isEmpty) {
    return placeholder; // Nếu không có URL, hiển thị placeholder
  }

  // Hàm xử lý lỗi chung cho Image.network
  Widget imageNetworkErrorBuilder(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
    String logUrl,
  ) {
    print('Lỗi tải ảnh từ $logUrl: $error');
    developer.log(
      'Image Network Error: $error for URL: $logUrl',
      name: 'ProductImageWidget',
    ); // Log lỗi tải ảnh
    return placeholder; // Hiển thị placeholder khi có lỗi
  }

  if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
    // Trường hợp URL là một liên kết trực tiếp (ví dụ: từ Cloudinary)
    return Image.network(
      imageUrl,
      key: ValueKey(imageUrl), // Thêm key dựa trên URL
      height: imageHeight,
      width: imageWidth,
      fit: BoxFit.cover,
      errorBuilder:
          (context, error, stackTrace) => imageNetworkErrorBuilder(
            context,
            error,
            stackTrace,
            imageUrl,
          ), // Sử dụng hàm xử lý lỗi
    );
  } else if (imageUrl.startsWith('products/')) {
    // Trường hợp URL là đường dẫn tương đối trên Firebase Storage
    return FutureBuilder<String>(
      key: ValueKey(imageUrl), // Thêm key dựa trên đường dẫn Storage
      future: firebase_storage.FirebaseStorage.instance
          .ref(imageUrl)
          .getDownloadURL()
          .then((url) {
            developer.log(
              'Successfully fetched download URL for $imageUrl: $url',
              name: 'ProductImageWidget',
            ); // Log khi lấy URL thành công
            return url;
          })
          .catchError((error) {
            developer.log(
              'Error fetching download URL for $imageUrl: $error',
              name: 'ProductImageWidget',
            ); // Log lỗi khi lấy URL
            throw error; // Ném lại lỗi để FutureBuilder bắt
          }),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Đang lấy URL tải xuống
          return Container(
            height: imageHeight,
            width: imageWidth,
            color: Colors.grey[850], // Màu nền tạm thời khi tải
          );
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          print('Lỗi lấy URL tải xuống cho $imageUrl: ${snapshot.error}');
          developer.log(
            'FutureBuilder Error or No Data for $imageUrl: ${snapshot.error}',
            name: 'ProductImageWidget',
          ); // Log lỗi hoặc không có dữ liệu từ FutureBuilder
          return placeholder; // Hiển thị placeholder nếu có lỗi
        }
        // Khi đã có URL, sử dụng Image.network để hiển thị
        return Image.network(
          snapshot.data!,
          key: ValueKey(snapshot.data!), // Thêm key dựa trên URL tải xuống
          height: imageHeight,
          width: imageWidth,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) => imageNetworkErrorBuilder(
                context,
                error,
                stackTrace,
                snapshot.data!,
              ),
        );
      },
    );
  }
  // Trường hợp định dạng URL không nhận dạng được, dùng placeholder
  print(
    'Định dạng URL ảnh không được nhận dạng: $imageUrl. Sử dụng placeholder.',
  );
  return placeholder;
}
