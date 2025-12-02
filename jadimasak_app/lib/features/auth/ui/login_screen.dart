import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../logic/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- Fungsi Lupa Password (Tampilan Baru: Modal Bottom Sheet) ---
  // Update: Menerima parameter 'initialEmail' untuk auto-fill
  void _showForgotPasswordDialog(BuildContext context, String initialEmail) {
    // Isi otomatis controller dengan email dari form login
    final resetEmailController = TextEditingController(text: initialEmail);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock_reset, color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Konfirmasi Reset",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Kirim link reset ke email ini?",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Input Email (Otomatis Terisi)
              CustomTextField(
                label: "Email Tujuan",
                hint: "nama@email.com",
                controller: resetEmailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
              ),
              const SizedBox(height: 32),

              // Tombol Kirim
              PrimaryButton(
                text: "Kirim Link",
                onPressed: () async {
                  final email = resetEmailController.text.trim();
                  
                  // Validasi tetap ada (jaga-jaga user menghapus teksnya)
                  if (email.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Email tidak boleh kosong")),
                    );
                    return;
                  }

                  FocusScope.of(context).unfocus();

                  try {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (c) => const Center(child: CircularProgressIndicator()),
                    );

                    await AuthService().sendPasswordReset(email);
                    
                    if (mounted) {
                      Navigator.pop(context); // Tutup Loading
                      Navigator.pop(context); // Tutup Bottom Sheet
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.white),
                              SizedBox(width: 10),
                              Expanded(child: Text("Link reset terkirim! Cek emailmu.")),
                            ],
                          ),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      Navigator.pop(context); 
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 100,
                    width: 100,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Selamat Datang!",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Masuk untuk mulai masak tanpa ribet.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 32),

                  // Form Input
                  CustomTextField(
                    label: "Email",
                    hint: "masukkan email kamu",
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: "Password",
                    hint: "masukkan password kamu",
                    isPassword: true,
                    controller: _passwordController,
                    prefixIcon: Icons.lock_outline,
                  ),
                  
                  // LOGIKA BARU TOMBOL LUPA PASSWORD
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // 1. Ambil teks dari controller email utama
                        final emailInput = _emailController.text.trim();

                        // 2. Cek apakah kosong
                        if (emailInput.isEmpty) {
                          // 3a. Jika kosong, marahi (dengan lembut)
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.warning_amber_rounded, color: Colors.white),
                                  SizedBox(width: 10),
                                  Expanded(child: Text("Isi kolom Email di atas dulu ya!")),
                                ],
                              ),
                              backgroundColor: Colors.orange,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } else {
                          // 3b. Jika ada, buka dialog dengan membawa email tersebut
                          _showForgotPasswordDialog(context, emailInput);
                        }
                      },
                      child: const Text(
                        "Lupa Password?",
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tombol Login
                  PrimaryButton(
                    text: "Masuk Sekarang",
                    isLoading: isLoading,
                    onPressed: () {
                      if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Email dan Password harus diisi")),
                        );
                        return;
                      }

                      ref.read(authControllerProvider).login(
                        email: _emailController.text.trim(),
                        password: _passwordController.text.trim(),
                        onSuccess: () {
                          if (mounted) {
                            context.go('/home');
                          }
                        },
                        onError: (message) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(message), backgroundColor: Colors.red),
                            );
                          }
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Belum punya akun?"),
                      TextButton(
                        onPressed: () {
                          context.push('/register');
                        },
                        child: const Text(
                          "Daftar Dulu",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}