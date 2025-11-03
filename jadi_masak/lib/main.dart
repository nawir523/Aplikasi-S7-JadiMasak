import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:jadi_masak/presentation/core/auth_wrapper.dart';

// TODO: Nanti kita akan ganti ini ke 'app.dart' yang lebih rapi
// import 'app.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Untuk sementara, kita jalankan placeholder sederhana
  runApp(const MyApp()); 
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jadi Masak', // Judul aplikasi kita
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange), // Ganti tema ke oranye
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false, // Hilangkan banner "Debug"
      
      // Kita akan ganti 'home' ini nanti dengan 'AuthWrapper'
      home: const AuthWrapper(),
    );
  }
}