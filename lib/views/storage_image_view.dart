import 'package:flutter/material.dart';

class StorageImageView extends StatelessWidget {
  // استقبال رابط الصورة مباشرة كـ String بدلاً من Reference المعقد لفايربيز
  final String imageUrl;

  const StorageImageView({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    // عرض الصورة مباشرة عبر الإنترنت مع توفير مؤشر تحميل أثناء نزولها
    return Image.network(
      imageUrl,
      fit: BoxFit.cover, // لتغطية المساحة المتاحة بالكامل مثل تصميم المحاضر
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        
        // عرض مؤشر تحميل دائري في المنتصف لحين اكتمال ظهور الصورة
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        // في حال حدوث خطأ في الرابط أو انقطاع الإنترنت، يتم عرض أيقونة خطأ بديلة
        return const Center(
          child: Icon(
            Icons.broken_image,
            color: Colors.grey,
            size: 40,
          ),
        );
      },
    );
  }
}
