import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// خريطة لربط نصوص أخطاء Supabase بالكلاسات المناسبة سنملؤها لاحقاً
// 1. الـ Map الخاصة بالأخطاء (مطابقة لأسلوب المحاضر ولكن لـ Supabase)
final Map<String, AuthError> authErrorMapping = {
  'user not found': const AuthErrorUserNotFound(),
  'invalid login credentials': AuthErrorInvalidCredentials(),
  'validation failed': const AuthErrorInvalidEmail(),
  'operation not allowed': const AuthErrorOperationNotAllowed(),
  'email already exists': const AuthErrorUserNotFound(),
  'password must be stronger': const AuthErrorWeakPassword(),
  'password is too weak': const AuthErrorWeakPassword(),
  'password too short': const AuthErrorWeakPassword(),
  'password too long': const AuthErrorWeakPassword(),
  'invalid email': const AuthErrorInvalidEmail(),
  'email must be valid': const AuthErrorInvalidEmail(),
  'email is already taken': const AuthErrorUserNotFound(),
  'user already exists': const AuthErrorUserNotFound(),
};

@immutable
abstract class AuthError {
  final String dialogTitle;
  final String dialogText;

  const AuthError({required this.dialogTitle, required this.dialogText});

  factory AuthError.from(AuthException exception) =>
      authErrorMapping[exception.message.toLowerCase().trim()] ??
      AuthErrorUnknown(exception);

}

// كلاس الخطأ غير المعروف . 1 //
@immutable
class AuthErrorUnknown extends AuthError {
  final AuthException innerException; // إضافة هذا المتغير لاستقبال الخطأ

  const AuthErrorUnknown(this.innerException) // تحديث الكونستركتور هنا
      : super(
          dialogTitle: 'Authentication Error',
          dialogText: 'An unknown authentication error occurred.',
        );
}

// 2. كلاس يطلب إعادة تسجيل الدخول للعمليات الحساسة
class AuthErrorRequiresRecentLogin extends AuthError {
  const AuthErrorRequiresRecentLogin()
    : super(
        dialogTitle: 'Requires recent login',
        dialogText:
            'You need to log out and log back in again in order to perform this operation.',
      );
}

// 3. كلاس يخبر المستخدم أن هذه العملية غير مسموحة حالياً
class AuthErrorOperationNotAllowed extends AuthError {
  const AuthErrorOperationNotAllowed()
    : super(
        dialogTitle: 'Operation not allowed',
        dialogText:
            'You cannot register using this method at this moment time!',
      );
}

// 4. كلاس الخطأ الجديد: المستخدم غير موجود على السيرفر
class AuthErrorUserNotFound extends AuthError {
  const AuthErrorUserNotFound()
    : super(
        dialogTitle: 'User not found',
        dialogText: 'The given user was not found on the server!',
      );
}

// 5. كلاس الخطأ الجديد: كلمة مرور ضعيفة
class AuthErrorWeakPassword extends AuthError {
  const AuthErrorWeakPassword()
    : super(
        dialogTitle: 'Weak password',
        dialogText:
            'Please choose a stronger password consisting of more characters!',
      );
}

// 6. كلاس الخطأ الجديد: صيغة البريد الإلكتروني غير صحيحة
class AuthErrorInvalidEmail extends AuthError {
  const AuthErrorInvalidEmail()
    : super(
        dialogTitle: 'Invalid email',
        dialogText: 'Please double check your email and try again!',
      );
}

@immutable
class AuthErrorInvalidCredentials extends AuthError {
  const AuthErrorInvalidCredentials()
      : super(
          dialogTitle: 'Wrong Credentials',
          dialogText: 'Invalid email or password. Please try again.',
        );
}
