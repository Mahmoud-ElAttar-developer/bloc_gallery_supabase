import 'package:bloc_gallery_supabase/extionsions/if_debuging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // تأكد من استدعاء حزمة الـ Bloc
import 'package:flutter_hooks/flutter_hooks.dart';
import '../bloc/app_bloc.dart';
import '../bloc/app_event.dart';

class LoginView extends HookWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = useTextEditingController(
      text: 'vandad.np@gmail.com'.ifDebugging,
    );

    final passwordController = useTextEditingController(
      text: 'foobarbaz'.ifDebugging,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log in'),
        elevation: 0,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                hintText: 'Enter your email here...',
              ),
              keyboardType: TextInputType.emailAddress,
              keyboardAppearance: Brightness.dark,
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                hintText: 'Enter your password here...',
              ),
              keyboardAppearance: Brightness.dark,
              obscureText: true,
              obscuringCharacter: '•',
            ),
            const SizedBox(height: 10), // مسافة صغيرة للتنسيق الجمالي
            // 1. زر تسجيل الدخول وإرسال الحدث للـ Bloc
            TextButton(
              onPressed: () {
                final email = emailController.text;
                final password = passwordController.text;

                // إرسال حدث تسجيل الدخول للـ Bloc
                context.read<AppBloc>().add(
                  AppEventLogIn(email: email, password: password),
                );
              },
              child: const Text('Log in', style: TextStyle(color: Colors.blue)),
            ),

            // 2. زر الانتقال لشاشة إنشاء الحساب (Registration View)
            TextButton(
              onPressed: () {
                // إرسال حدث التوجيه لشاشة التسجيل
                context.read<AppBloc>().add(const AppEventGoToRegistration());
              },
              child: const Text(
                'Not registered yet? Register here!',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
