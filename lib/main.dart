import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'views/app.dart'; // استدعاء ملف الـ App النظيف

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة مشروع سوبابيز بالبيانات والمفاتيح الخاصة بك
  await Supabase.initialize(
    url: 'https://abvzdefxzaiwzwetmsuw.supabase.co',  // رابط الـ URL الخاص بمشروعك 👈
    publishableKey: 'sb_publishable_djvbfr_zrkFnFuquq8bZMHA_y3wt', // مفتاح الـ Anon Key الخاص بك
  );

  runApp(const App()); // تشغيل التطبيق من جذوره
}
