import 'dart:io';
import 'package:bloc_gallery_supabase/auth/auth_error.dart';
import 'package:bloc_gallery_supabase/utilis/upload_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // الاعتماد الكامل على سوبابيز
import 'app_event.dart';
import 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  
  // دالة مخصصة لجلب الصور التابعة للمستخدم من Supabase Storage
  Future<Iterable<String>> _getImages(String userId) async {
    try {
      final List<FileObject> files = await Supabase.instance.client.storage
          .from('images')
          .list(path: userId);

      return files.map((file) {
        return Supabase.instance.client.storage
            .from('images')
            .getPublicUrl('$userId/${file.name}');
      });
    } catch (_) {
      return const [];
    }
  }

  AppBloc()
      : super(const AppStateLoggedOut(
          isLoading: false,
        )) {

    // 1. حدث تهيئة التطبيق وفحص الجلسة (AppEventInitialize)
    on<AppEventInitialize>((event, emit) async {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        emit(const AppStateLoggedOut(
          isLoading: false,
        ));
      } else {
        final images = await _getImages(user.id);
        emit(AppStateLoggedIn(
          user: user,
          images: images,
          isLoading: false,
        ));
      }
    });

    // 2. حدث التوجيه المباشر لشاشة تسجيل الدخول (AppEventGoToLogin)
    on<AppEventGoToLogin>((event, emit) {
      emit(const AppStateLoggedOut(
        isLoading: false,
      ));
    });

    // 3. حدث التوجيه المباشر لشاشة إنشاء حساب (AppEventGoToRegistration)
    on<AppEventGoToRegistration>((event, emit) {
      emit(const AppStateIsInRegistrationView(
        isLoading: false,
      ));
    });

    // 4. حدث تسجيل الدخول الفعلي (AppEventLogIn)
    on<AppEventLogIn>((event, emit) async {
      emit(const AppStateLoggedOut(
        isLoading: true,
      ));
      
      try {
        // تسجيل الدخول بـ Supabase باستخدام البريد الإلكتروني وكلمة المرور
        final AuthResponse res = await Supabase.instance.client.auth.signInWithPassword(
          email: event.email,
          password: event.password,
        );
        
        final user = res.user;
        
        if (user != null) {
          // جلب الصور الخاصة به فور إتمام تسجيل الدخول بنجاح
          final images = await _getImages(user.id);
          emit(AppStateLoggedIn(
            user: user,
            images: images,
            isLoading: false,
          ));
        } else {
          emit(const AppStateLoggedOut(
            isLoading: false,
          ));
        }
      } on AuthException catch (e) {
        emit(AppStateLoggedOut(
          isLoading: false,
          authError: AuthError.from(e),
        ));
      } catch (_) {
        emit(const AppStateLoggedOut(
          isLoading: false,
        ));
      }
    });

    // 5. حدث تسجيل الخروج (AppEventLogOut)
    on<AppEventLogOut>((event, emit) async {
      emit(const AppStateLoggedOut(
        isLoading: true,
      ));
      try {
        await Supabase.instance.client.auth.signOut();
        emit(const AppStateLoggedOut(
          isLoading: false,
        ));
      } catch (_) {
        emit(const AppStateLoggedOut(
          isLoading: false,
        ));
      }
    });

    // 6. حدث إنشاء حساب جديد (AppEventRegister)
   // ابحث عن هذا الجزء داخل ملف app_bloc.dart وحدثه:
on<AppEventRegister>((event, emit) async {
  emit(const AppStateIsInRegistrationView(
    isLoading: true,
  ));
  
  try {
    // إنشاء الحساب في سوبابيز مع تخزين الاسم داخل الـ userMetadata 👈
    final AuthResponse res = await Supabase.instance.client.auth.signUp(
      email: event.email,
      password: event.password,
      data: {
        'name': event.name, // 👈 حفظ الاسم بنجاح في السيرفر
      },
    );
    
    final user = res.user;
    if (user != null) {
      emit(AppStateLoggedIn(
        user: user,
        images: const [],
        isLoading: false,
      ));
    } else {
      emit(const AppStateLoggedOut(
        isLoading: false,
      ));
    }
  } on AuthException catch (e) {
    emit(AppStateIsInRegistrationView(
      isLoading: false,
      authError: AuthError.from(e),
    ));
  } catch (_) {
    emit(const AppStateIsInRegistrationView(
      isLoading: false,
    ));
  }
});


    // 7. حدث حذف الحساب (AppEventDeleteAccount)
    on<AppEventDeleteAccount>((event, emit) async {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        emit(const AppStateLoggedOut(
          isLoading: false,
        ));
        return;
      }

      emit(AppStateLoggedIn(
        user: user,
        images: state.images ?? const [],
        isLoading: true,
      ));

      try {
        final List<FileObject> files = await Supabase.instance.client.storage
            .from('images')
            .list(path: user.id);

        if (files.isNotEmpty) {
          final List<String> pathsToDelete = files
              .map((file) => '${user.id}/${file.name}')
              .toList();

          await Supabase.instance.client.storage
              .from('images')
              .remove(pathsToDelete);
        }

        await Supabase.instance.client.auth.signOut();
        emit(const AppStateLoggedOut(
          isLoading: false,
        ));
      } on AuthException catch (e) {
        emit(AppStateLoggedIn(
          user: user,
          images: state.images ?? const [],
          isLoading: false,
          authError: AuthError.from(e),
        ));
      } catch (_) {
        emit(AppStateLoggedIn(
          user: user,
          images: state.images ?? const [],
          isLoading: false,
        ));
      }
    });

    // 8. حدث رفع الصور (AppEventUploadImage)
    on<AppEventUploadImage>((event, emit) async {
      final user = state.user;
      if (user == null) {
        emit(const AppStateLoggedOut(
          isLoading: false,
        ));
        return;
      }

      emit(AppStateLoggedIn(
        user: user,
        images: state.images ?? const [],
        isLoading: true,
      ));

      final file = File(event.filePathToUpload);
      final uploadResult = await uploadImage(
        file: file,
        userId: user.id,
      );

      if (uploadResult) {
        final newImages = await _getImages(user.id);
        emit(AppStateLoggedIn(
          user: user,
          images: newImages,
          isLoading: false,
        ));
      } else {
        emit(AppStateLoggedIn(
          user: user,
          images: state.images ?? const [],
          isLoading: false,
        ));
      }
    });
  }
}






// import 'dart:io';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'app_event.dart';
// import 'app_state.dart';

// class AppBloc extends Bloc<AppEvent, AppState> {
//   // جلب نسخة الـ Supabase Client الأساسية المتصلة بمشروعك
//   final SupabaseClient _supabase = Supabase.instance.client;

//   AppBloc() : super(const AppStateLoggedOut(isLoading: true)) {
    
//     // 1. حدث البداية والتحقق من حالة المستخدم (هل هو مسجل دخول أم لا)
//     on<AppEventInitialize>((event, emit) async {
//       final session = _supabase.auth.currentSession;
//       if (session == null) {
//         emit(const AppStateLoggedOut(isLoading: false));
//         return;
//       }

//       // إذا كان مسجل دخول، نقوم بجلب الصور الخاصة به من الـ Storage
//       emit(AppStateLoggedIn(
//         user: session.user,
//         images: const [],
//         isLoading: true,
//       ));
      
//       try {
//         final imagesUrls = await _fetchUserImagesUrls();
//         emit(AppStateLoggedIn(
//           user: session.user,
//           images: imagesUrls,
//           isLoading: false,
//         ));
//       } catch (e) {
//         emit(AppStateLoggedIn(
//           user: session.user,
//           images: const [],
//           isLoading: false,
//         ));
//       }
//     });

//     // 2. حدث الانتقال لشاشة إنشاء حساب جديد (Registration View)
//     on<AppEventGoToRegistration>((event, emit) {
//       emit(const AppStateIsInRegistrationView(isLoading: false));
//     });

//     // 3. حدث العودة لشاشة تسجيل الدخول (Login View)
//     on<AppEventGoToLogin>((event, emit) {
//       emit(const AppStateLoggedOut(isLoading: false));
//     });

//     // 4. حدث إنشاء حساب جديد (Register)
//     on<AppEventRegister>((event, emit) async {
//       emit(const AppStateIsInRegistrationView(isLoading: true));
//       try {
//         final response = await _supabase.auth.signUp(
//           email: event.email,
//           password: event.password,
//         );
//         emit(AppStateLoggedIn(
//           user: response.user!,
//           images: const [],
//           isLoading: false,
//         ));
//       } catch (e) {
//         emit(const AppStateIsInRegistrationView(
//           isLoading: false,
//           // هنا يمكنك تمرير كلاس الـ AuthError الخاص بك إذا أردت معالجة تفاصيل الخطأ
//         ));
//       }
//     });

//     // 5. حدث تسجيل الدخول (Log In)
//     on<AppEventLogIn>((event, emit) async {
//       emit(const AppStateLoggedOut(isLoading: true));
//       try {
//         final response = await _supabase.auth.signInWithPassword(
//           email: event.email,
//           password: event.password,
//         );
        
//         final imagesUrls = await _fetchUserImagesUrls();
//         emit(AppStateLoggedIn(
//           user: response.user!,
//           images: imagesUrls,
//           isLoading: false,
//         ));
//       } catch (e) {
//         emit(const AppStateLoggedOut(
//           isLoading: false,
//           // هنا يمكنك تمرير كلاس الـ AuthError الخاص بك إذا أردت معالجة تفاصيل الخطأ
//         ));
//       }
//     });

//     // 6. حدث تسجيل الخروج (Log Out)
//     on<AppEventLogOut>((event, emit) async {
//       emit(const AppStateLoggedOut(isLoading: true));
//       try {
//         await _supabase.auth.signOut();
//         emit(const AppStateLoggedOut(isLoading: false));
//       } catch (e) {
//         emit(const AppStateLoggedOut(isLoading: false));
//       }
//     });

//     // 7. حدث رفع الصورة (Upload Image)
//     on<AppEventUploadImage>((event, emit) async {
//       final currentState = state;
//       if (currentState is AppStateLoggedIn) {
//         emit(AppStateLoggedIn(
//           user: currentState.user,
//           images: currentState.images,
//           isLoading: true,
//         ));

//         try {
//           final file = File(event.filePath);
//           // تسمية ملف فريد باستخدام الـ User ID والوقت الحالي لمنع التداخل بين المستخدمين
//           final fileName = '${currentState.user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';

//           // رفع الصورة إلى الـ bucket المسمى 'gallery' في Supabase Storage
//           await _supabase.storage.from('gallery').upload(fileName, file);

//           // إعادة جلب القائمة المحدثة للروابط بعد الرفع الناجح لإظهارها فوراً
//           final updatedImagesUrls = await _fetchUserImagesUrls();
//           emit(AppStateLoggedIn(
//             user: currentState.user,
//             images: updatedImagesUrls,
//             isLoading: false,
//           ));
//         } catch (e) {
//           emit(AppStateLoggedIn(
//             user: currentState.user,
//             images: currentState.images,
//             isLoading: false,
//           ));
//         }
//       }
//     });
//   }

//   // دالة مساعدة (Helper Function) لجلب روابط الصور العامة من الـ Storage للمستخدم الحالي
//   Future<Iterable<String>> _fetchUserImagesUrls() async {
//     final currentUser = _supabase.auth.currentUser;
//     if (currentUser == null) return const [];

//     // جلب قائمة الملفات من الفولدر الخاص بالـ user id داخل الـ bucket المسمى 'gallery'
//     final List<FileObject> files = await _supabase.storage
//         .from('gallery')
//         .list(path: currentUser.id);

//     final List<String> urls = [];
//     for (var file in files) {
//       // استخراج الرابط العام المباشر لكل صورة موجودة
//       final url = _supabase.storage
//           .from('gallery')
//           .getPublicUrl('${currentUser.id}/${file.name}');
//       urls.add(url);
//     }
//     return urls;
//   }
// }
