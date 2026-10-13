import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/app_bloc.dart';
import '../bloc/app_event.dart';
import '../bloc/app_state.dart';
import '../dialogs/show_auth_error.dart';
import '../loading/loading_screen.dart';
import 'login_view.dart';
import 'photo_gallery_view.dart';
import 'register_view.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppBloc>(
      create: (context) => AppBloc()..add(const AppEventInitialize()),
      child: MaterialApp(
        title: 'photo_gallery',
        theme: ThemeData(primarySwatch: Colors.blue),
        debugShowCheckedModeBanner: false,
        home: const HomePage(),
      ), // MaterialApp
    ); // BlocProvider
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppBloc, AppState>(
      listener: (context, state) {
        if (state.isLoading) {
          LoadingScreen.instance().show(
            context: context,
            text: 'Please wait a moment...',
          );
        } else {
         LoadingScreen.instance().hide();
        }

        final authError = state.authError;
        if (authError != null) {
          showAuthError(authError: authError, context: context);
        }
      },
      builder: (context, state) {
        if (state is AppStateLoggedOut) {
          return const LoginView();
        } else if (state is AppStateIsInRegistrationView) {
          return const RegisterView();
        } else if (state is AppStateLoggedIn) {
          return const PhotoGalleryView();
        } else {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    ); // BlocConsumer
  }
}
