import 'package:bloc_gallery_supabase/views/main_popup_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_picker/image_picker.dart';
import '../bloc/app_bloc.dart';
import '../bloc/app_event.dart';
import '../bloc/app_state.dart';
import 'storage_image_view.dart';

class PhotoGalleryView extends HookWidget {
  const PhotoGalleryView({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. تثبيت كائن الـ ImagePicker في الذاكرة لتفادي التكرار عند إعادة البناء
    final picker = useMemoized(() => ImagePicker(), [key]);

    // 2. الاستماع لقائمة روابط الصور التابعة للمخدم من الـ State الحالية
    final images = context.watch<AppBloc>().state.images ?? const [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Gallery'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          // أ) زر اختيار ورفع صورة جديدة من الاستوديو
          IconButton(
            onPressed: () async {
              final image = await picker.pickImage(
                source: ImageSource.gallery,
              );
              if (image == null) return; // إذا ألغى المستخدم الاختيار

              // إرسال حدث رفع الملف مباشرة إلى الـ Bloc
              if (context.mounted) {
                context.read<AppBloc>().add(
                      AppEventUploadImage(
                        filePathToUpload: image.path,
                      ),
                    );
              }
            },
            icon: const Icon(Icons.upload),
          ),
          // ب) زر القائمة المنسدلة المخصص لتسجيل الخروج وحذف الحساب
          const MainPopupMenuButton(),
        ],
      ),
      // 3. شبكة عرض الصور المنسقة (عمودين متوازيين)
      body: GridView.count(
        crossAxisCount: 2, // عرض صورتين في كل سطر
        padding: const EdgeInsets.all(8.0),
        mainAxisSpacing: 20.0, // المسافة الرأسية بين الصور
        crossAxisSpacing: 20.0, // المسافة الأفقية بين الصور
        children: images
            .map(
              (imgUrl) => StorageImageView(
                imageUrl: imgUrl, // تمرير الرابط النصي مباشرة لكلاس العرض المخصص لنا
              ),
            )
            .toList(), // تحويل الـ Iterable إلى List لتناسب مصفوفة الأطفال
      ),
    );
  }
}
