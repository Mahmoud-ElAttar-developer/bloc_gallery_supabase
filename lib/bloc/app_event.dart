import 'package:flutter/foundation.dart' show immutable;

@immutable
abstract class AppEvent {
  const AppEvent();
}

// 1. حدث تهيئة التطبيق عند فتح الشاشة
@immutable
class AppEventInitialize implements AppEvent {
  const AppEventInitialize();
}

// 2. حدث تسجيل الدخول (يتطلب البريد الإلكتروني وكلمة المرور)
@immutable
class AppEventLogIn implements AppEvent {
  final String email;
  final String password;

  const AppEventLogIn({required this.email, required this.password});
}

// 3. حدث تسجيل الخروج
@immutable
class AppEventLogOut implements AppEvent {
  const AppEventLogOut();
}

// 4. حدث حذف الحساب بالكامل
@immutable
class AppEventDeleteAccount implements AppEvent {
  const AppEventDeleteAccount();
}

// 5. حدث رفع صورة (يتطلب مسار الملف في الهاتف)
@immutable
class AppEventUploadImage implements AppEvent {
  final String filePathToUpload;

  const AppEventUploadImage({required this.filePathToUpload});
}

// 6. حدث تسجيل حساب جديد (يتطلب البريد الإلكتروني وكلمة المرور)
@immutable
class AppEventRegister implements AppEvent {
  final String name;
  final String email;
  final String password;

  const AppEventRegister({
    required this.name,
    required this.email,
    required this.password,
  });
}

// حدث الانتقال المباشر لواجهة تسجيل الدخول
@immutable
class AppEventGoToLogin implements AppEvent {
  const AppEventGoToLogin();
}

// حدث الانتقال المباشر لواجهة إنشاء حساب جديد
@immutable
class AppEventGoToRegistration implements AppEvent {
  const AppEventGoToRegistration();
}
