import 'package:bloc_gallery_supabase/auth/auth_error.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:supabase_flutter/supabase_flutter.dart'; // استخدام Supabase بدلاً من Firebase

@immutable
abstract class AppState {
  final bool isLoading;
  final AuthError? authError;

  const AppState({
    required this.isLoading,
    this.authError,
  });
}

// 1. حالة شاشة تسجيل حساب جديد (Registration View)
@immutable
class AppStateIsInRegistrationView extends AppState {
  const AppStateIsInRegistrationView({
    required super.isLoading,
    super.authError,
  });
}

// 2. حالة المستخدم المسجل دخوله (LoggedIn)
@immutable
class AppStateLoggedIn extends AppState {
  final User user; // كلاس المستخدم الخاص بـ Supabase
  final Iterable<String> images; // مسارات أو روابط الصور في Supabase Storage كـ String

  const AppStateLoggedIn({
    required this.user,
    required this.images,
    required super.isLoading,
    super.authError,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    if (other is AppStateLoggedIn) {
      return isLoading == other.isLoading &&
          user.id == other.user.id && // مواءمة سوبابيز لـ id المستخدم
          images.length == other.images.length;
    } else {
      return false;
    }
  }

  @override
  int get hashCode => Object.hash(
        user.id,
        images,
      );

  @override
  String toString() => 'AppStateLoggedIn, images.length = ${images.length}';
}

// 3. حالة المستخدم غير المسجل أو المسجل خروجه (LoggedOut)
@immutable
class AppStateLoggedOut extends AppState {
  const AppStateLoggedOut({
    required super.isLoading,
    super.authError,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is AppStateLoggedOut) {
      return isLoading == other.isLoading && authError == other.authError;
    } else {
      return false;
    }
  }

  @override
  int get hashCode => Object.hash(
        isLoading,
        authError,
      );

  @override
  String toString() =>
      'AppStateLoggedOut, isLoading = $isLoading, authError = $authError';
}

// 4. الـ Extensions لتسهيل استخراج البيانات من الـ State داخل الـ UI
extension GetUser on AppState {
  User? get user {
    final cls = this;
    if (cls is AppStateLoggedIn) {
      return cls.user;
    } else {
      return null;
    }
  }
}

extension GetImages on AppState {
  Iterable<String>? get images {
    final cls = this;
    if (cls is AppStateLoggedIn) {
      return cls.images;
    } else {
      return null;
    }
  }
}
