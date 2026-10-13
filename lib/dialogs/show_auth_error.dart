import 'package:flutter/material.dart' show BuildContext;
import '../auth/auth_error.dart'; // تأكد من كتابة المسار الصحيح لملف auth_error الخاص بك
import 'generic_dialog.dart';

Future<void> showAuthError({
  required AuthError authError,
  required BuildContext context,
}) {
  return showGenericDialog<void>(
    context: context,
    title: authError.dialogTitle, // قراءة العنوان ديناميكياً من كلاس الخطأ
    content: authError.dialogText, // قراءة نص الرسالة ديناميكياً من كلاس الخطأ
    optionsBuilder: () => {
      'OK': null, // زر واحد فقط لإغلاق الحوار
    },
  );
}
