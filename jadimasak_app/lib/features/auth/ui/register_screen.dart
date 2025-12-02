import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../logic/auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController(); // <-- 1. Controller Baru

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Buat Akun Baru",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Mulai perjalanan memasakmu hari ini!",
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 32),

                  // Input Nama
                  CustomTextField(
                    label: "Nama Lengkap",
                    hint: "masukkan nama lengkap kamu",
                    controller: _nameController,
                    prefixIcon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),

                  // Input Email
                  CustomTextField(
                    label: "Email",
                    hint: "masukkan email kamu",
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 16),

                  // Input Password
                  CustomTextField(
                    label: "Password",
                    hint: "Minimal 6 karakter",
                    isPassword: true, // Icon mata otomatis muncul
                    controller: _passwordController,
                    prefixIcon: Icons.lock_outline,
                  ),
                  const SizedBox(height: 16),

                  // --- 2. Input Konfirmasi Password ---
                  CustomTextField(
                    label: "Konfirmasi Password",
                    hint: "Ulangi password",
                    isPassword: true,
                    controller: _confirmPasswordController,
                    prefixIcon: Icons.lock_outline,
                  ),
                  const SizedBox(height: 32),

                  // Tombol Daftar
                  PrimaryButton(
                    text: "Daftar Sekarang",
                    isLoading: isLoading,
                    onPressed: () {
                      // --- 3. Validasi Lengkap ---
                      if (_nameController.text.isEmpty ||
                          _emailController.text.isEmpty ||
                          _passwordController.text.isEmpty ||
                          _confirmPasswordController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Semua kolom harus diisi!")),
                        );
                        return;
                      }

                      // Cek Password Sama
                      if (_passwordController.text != _confirmPasswordController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Konfirmasi password tidak cocok!"),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      // Panggil Logic
                      ref.read(authControllerProvider).register(
                            name: _nameController.text.trim(),
                            email: _emailController.text.trim(),
                            password: _passwordController.text.trim(),
                            onSuccess: () {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Registrasi Berhasil! Silakan Login."),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                context.pop(); 
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}