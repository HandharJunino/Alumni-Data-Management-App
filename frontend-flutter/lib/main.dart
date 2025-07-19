import 'package:flutter/material.dart';
import 'package:alumni_app/pages/home.dart';
import 'package:alumni_app/apptheme.dart';
import 'package:alumni_app/pages/profile.dart';
import 'package:alumni_app/pages/edit_profile.dart';
import 'package:alumni_app/pages/auth.dart';
import 'package:provider/provider.dart';
import 'package:alumni_app/theme_notifier.dart';

const String base_url = "http://127.0.0.1:8000/api/";

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
  };
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      title: 'Alumni App',
      theme: AppThemes.lightTheme, // Light theme
      darkTheme: AppThemes.darkTheme, // Dark theme
      themeMode:
          themeNotifier.themeMode, // Auto-switch based on system settings
      home: const AuthPageWidget(), //AuthPageWidget(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/auth': (context) => const AuthPageWidget(),
        '/home': (context) => const HomePageWidget(),
        '/edit_profile': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return EditProfileWidget(userId: args['userId']);
        },
        '/user_profile': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return UserProfileWidget(userId: args['userId']);
        },
      },
    );
  }
}
