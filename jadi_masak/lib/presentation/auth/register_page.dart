import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controller untuk form
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // TODO: Nanti kita buat fungsi registrasi di sini
// Fungsi untuk mendaftarkan pengguna
  void _registerUser() async {
    // 1. Ambil semua data dari controller
    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();

    // 2. Validasi sederhana
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      print('Semua field harus diisi');
      // TODO: Tampilkan dialog error ke pengguna
      return;
    }
    
    if (password != confirmPassword) {
      print('Password dan Konfirmasi Password tidak cocok');
      // TODO: Tampilkan dialog error ke pengguna
      return;
    }

    // 3. Tampilkan loading spinner (Opsional tapi bagus)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // 4. Mulai proses registrasi ke Firebase
    try {
      // Buat pengguna baru dengan email & password
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 5. Jika sukses, update nama pengguna (DisplayName)
      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(name);
        // Penting: Refresh data pengguna agar 'displayName' terbaca
        await userCredential.user!.reload(); 
      }

      // 6. Tutup loading spinner
      Navigator.of(context).pop();

      // 7. Tutup halaman Register (kembali ke AuthWrapper)
      // AuthWrapper akan otomatis mendeteksi login baru dan pindah ke HomePage
      if (mounted) { // Pastikan widget masih ada
         Navigator.of(context).pop();
      }

    } on FirebaseAuthException catch (e) {
      // 6. (Gagal) Tutup loading spinner
      Navigator.of(context).pop();

      // 7. (Gagal) Tangani error
      print('Error Registrasi: ${e.code}');
      // Contoh: 'weak-password', 'email-already-in-use'
      // TODO: Tampilkan dialog error yang lebih jelas ke pengguna
      
    } catch (e) {
      // Handle error lainnya
      print('Error tidak diketahui: $e');
      Navigator.of(context).pop(); // Tutup loading
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              
              // Logo
              Image.asset(
                'assets/images/logo.png', // Pastikan nama file sama
                height: 100,
              ),
              const SizedBox(height: 30),

              // Judul
              const Text(
                'Daftar akun baru',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              // Form Nama
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nama',
                  hintText: 'Masukkan nama anda',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 20),

              // Form Email
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Masukkan email anda',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 20),

              // Form Password
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Minimal 6 karakter',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 20),

              // Form Konfirmasi Password
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Konfirmasi Password',
                  hintText: 'Masukkan password lagi',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 30),

              // Tombol DAFTAR
              ElevatedButton(
                onPressed: _registerUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Daftar',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 30),

              // Link ke Halaman Masuk
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Sudah punya akun?'),
                  TextButton(
                    onPressed: () {
                      // Ini akan menutup halaman Daftar dan kembali ke Login
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Masuk di sini',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}