import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jadi_masak/presentation/auth/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 1. Buat controller untuk mengambil teks dari form
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 2. Jangan lupa dispose controller saat widget tidak digunakan
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // TODO: Nanti kita buat fungsi login di sini
// Fungsi untuk login pengguna
  void _loginUser() async {
    // 1. Ambil data dari controller
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    // 2. Validasi sederhana
    if (email.isEmpty || password.isEmpty) {
      print('Email dan password harus diisi');
      // TODO: Tampilkan dialog error ke pengguna
      return;
    }

    // 3. Tampilkan loading spinner
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // 4. Mulai proses login ke Firebase
    try {
      // Perintah inti untuk login
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 5. Tutup loading spinner
      Navigator.of(context).pop();

      // Anda TIDAK PERLU navigasi manual di sini.
      // AuthWrapper akan otomatis mendeteksi login
      // dan mengarahkan ke MainNavigationPage.

    } on FirebaseAuthException catch (e) {
      // 5. (Gagal) Tutup loading spinner
      Navigator.of(context).pop();

      // 6. (Gagal) Tangani error
      print('Error Login: ${e.code}');
      // Contoh: 'user-not-found', 'wrong-password', 'invalid-credential'
      // TODO: Tampilkan dialog error yang lebih jelas ke pengguna
      
    } catch (e) {
      // Handle error lainnya
      print('Error tidak diketahui: $e');
      Navigator.of(context).pop(); // Tutup loading
    }
  }

  @override
  Widget build(BuildContext context) {
    // Gunakan SingleChildScrollView agar layar bisa di-scroll
    // saat keyboard muncul (menghindari error overflow)
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0), // Beri jarak di semua sisi
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Pusatkan secara vertikal
            crossAxisAlignment: CrossAxisAlignment.stretch, // Ratakan widget
            children: [
              // Jarak dari atas layar
              const SizedBox(height: 80), 
              
              // 3. Menampilkan Logo
              Image.asset(
                'assets/images/logo.png',
                height: 120, // Atur tinggi logo
              ),
              const SizedBox(height: 40),

              // 4. Judul Halaman
              const Text(
                'Masuk ke akun Anda',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              // 5. Form Email
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

              // 6. Form Password
              TextField(
                controller: _passwordController,
                obscureText: true, // Sembunyikan teks password
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Masukkan password anda',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 10),

              // 7. Tombol Lupa Password (Sesuai review desain kita)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // TODO: Buat alur lupa password
                  },
                  child: const Text(
                    'Lupa Password?',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 8. Tombol MASUK
              ElevatedButton(
                onPressed: _loginUser, // Panggil fungsi login
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, // Warna oranye
                  foregroundColor: Colors.white, // Teks warna putih
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Masuk',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 30),

              // 9. Link ke Halaman Daftar
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Belum punya akun?'),
                  TextButton(
                    onPressed: () {
                     Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const RegisterPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Daftar di sini',
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