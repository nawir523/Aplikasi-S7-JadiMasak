import 'package:flutter/material.dart';

class PantryScreen extends StatelessWidget {
  const PantryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kulkasku")),
      body: const Center(child: Text("Daftar bahan akan muncul di sini")),
    );
  }
}