import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // استدعاء حزمة الـ Bloc لإخفاء خطأ context.read
import '../bloc/app_bloc.dart';
import '../bloc/app_event.dart';
import '../dialogs/delete_account_dialog.dart';
import '../dialogs/logout_dialog.dart';

// 1. تعريف الـ enum لتحديد الخيارات المتاحة في القائمة
enum MenuAction { logout, deleteAccount }

class MainPopupMenuButton extends StatelessWidget {
  const MainPopupMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<MenuAction>(
      // أ) معالجة الضغط على أحد عناصر القائمة
      onSelected: (value) async {
        switch (value) {
          case MenuAction.logout:
            // عرض حوار تسجيل الخروج وانتظار قرار المستخدم
            final shouldLogOut = await showLogOutDialog(context);
            // حماية الـ context وفحص الـ mounted لضمان السلامة البرمجية
            if (shouldLogOut && context.mounted) {
              context.read<AppBloc>().add(const AppEventLogOut());
            }
            break;

          case MenuAction.deleteAccount:
            // عرض حوار حذف الحساب وانتظار قرار المستخدم
            final shouldDelete = await showDeleteAccountDialog(context);
            if (shouldDelete && context.mounted) {
              context.read<AppBloc>().add(const AppEventDeleteAccount());
            }
            break;
        }
      },
      // ب) بناء العناصر الرسومية داخل القائمة المنسدلة
      itemBuilder: (context) {
        return [
          const PopupMenuItem<MenuAction>(
            value: MenuAction.logout,
            child: Text('Log out'),
          ),
          const PopupMenuItem<MenuAction>(
            value: MenuAction.deleteAccount,
            child: Text('Delete account'),
          ),
        ];
      },
    );
  }
}
