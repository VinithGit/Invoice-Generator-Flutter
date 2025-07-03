import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
  apiKey: "AIzaSyAlCzAKag9OgAO2fQx0e-nou3ucgSsqZGs",
  authDomain: "invoice-generator-68680.firebaseapp.com",
  projectId: "invoice-generator-68680",
  storageBucket: "invoice-generator-68680.firebasestorage.app",
  messagingSenderId: "954289276283",
  appId: "1:954289276283:web:d48f06b8361bdc45a569de",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FirebaseAuth.instance.currentUser == null
          ? const LoginScreen()
          : const HomeScreen(),
    );
  }
}
