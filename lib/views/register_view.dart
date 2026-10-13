import 'package:bloc_gallery_supabase/extionsions/if_debuging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../bloc/app_bloc.dart';
import '../bloc/app_event.dart';

class RegisterView extends HookWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. إضافة متحكم نصوص خاص بالاسم
    final nameController = useTextEditingController(
      text: 'John Doe'.ifDebugging,
    );

    final emailController = useTextEditingController(
      text: 'newuser@gmail.com'.ifDebugging,
    );

    final passwordController = useTextEditingController(
      text: 'foobarbaz'.ifDebugging,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        elevation: 0,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            // 2. حقل إدخال الاسم الجديد 👈
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: 'Enter your full name here...',
              ),
              keyboardType: TextInputType.name,
              keyboardAppearance: Brightness.dark,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                hintText: 'Enter your email here...',
              ),
              keyboardType: TextInputType.emailAddress,
              keyboardAppearance: Brightness.dark,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                hintText: 'Enter your password here...',
              ),
              keyboardAppearance: Brightness.dark,
              obscureText: true,
              obscuringCharacter: '•',
            ),
            const SizedBox(height: 10),

            // 3. زر إرسال الحساب مع الاسم المضاف
            TextButton(
              onPressed: () {
                final name = nameController.text; // 👈 سحب الاسم
                final email = emailController.text;
                final password = passwordController.text;

                context.read<AppBloc>().add(
                      AppEventRegister(
                        name: name, // 👈 تمرير الاسم للـ Bloc
                        email: email,
                        password: password,
                      ),
                    );
              },
              child: const Text('Register',style: TextStyle(color: Colors.blue),),
            ),

            TextButton(
              onPressed: () {
                context.read<AppBloc>().add(
                      const AppEventGoToLogin(),
                    );
              },
              child: const Text('Already registered? Log in here!',style: TextStyle(color: Colors.blue),),
            ),
          ],
        ),
      ),
    );
  }
}
