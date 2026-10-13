import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart'; // استيراد Supabase بدلاً من Firebase
import 'package:uuid/uuid.dart';

Future<bool> uploadImage({
  required File file,
  required String userId,
}) async {
  try {
    // توليد اسم فريد وعشوائي للصورة باستخدام Uuid
    final fileName = const Uuid().v4();
    
    // رفع الصورة إلى مجلد يحمل اسم الـ userId داخل bucket اسمه 'images'
    await Supabase.instance.client.storage
        .from('images') // تأكد من إنشاء Bucket بهذا الاسم في لوحة تحكم سوبابيز جعلها Public
        .upload('$userId/$fileName', file);
        
    return true; // في حال نجاح الرفع
  } catch (_) {
    return false; // في حال حدوث أي خطأ
  }
}
