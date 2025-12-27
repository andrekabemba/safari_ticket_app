import 'package:achat_ticketbus/core/theme.dart';
import 'package:achat_ticketbus/features/auth/presentation/pages/login_page.dart';
import 'package:achat_ticketbus/features/reservation/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: 'https://dcvecsyjohlztitjtifr.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRjdmVjc3lqb2hsenRpdGp0aWZyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY0Njg1ODcsImV4cCI6MjA4MjA0NDU4N30.ouKe-yBpQhjJSf3DCS3a_TD7TWO_VMLIfUBE-40MRKY',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Safari Bus',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: StreamBuilder<AuthState>(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          final session = snapshot.data?.session;
          if (session != null) {
            return const HomePage();
          } else {
            return const LoginPage();
          }
        },
      ),
    );
  }
}
