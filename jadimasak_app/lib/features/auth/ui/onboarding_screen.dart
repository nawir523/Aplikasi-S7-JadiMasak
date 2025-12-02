import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/primary_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Data Slide Onboarding
  final List<Map<String, String>> _onboardingData = [
    {
      "title": "Bingung Mau Masak Apa?",
      "desc": "Jangan pusing! Temukan ribuan inspirasi resep lezat dan praktis hanya dalam satu genggaman.",
      "icon": "assets/images/logo.png", // Bisa ganti gambar lain nanti
    },
    {
      "title": "Fitur Anti-Mubazir",
      "desc": "Punya sisa bahan di kulkas? Masukkan datanya, dan kami carikan resep yang pas buat kamu.",
      "icon": "assets/images/logo.png", 
    },
    {
      "title": "Simpan & Masak Nanti",
      "desc": "Simpan resep favoritmu dan buat daftar belanjaan dengan mudah. Yuk mulai masak!",
      "icon": "assets/images/logo.png",
    },
  ];

  // Fungsi saat tombol "Mulai" ditekan
  Future<void> _finishOnboarding() async {
    // 1. Simpan tanda bahwa user sudah pernah lihat onboarding
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);

    // 2. Pindah ke Login
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. TOMBOL SKIP (Pojok Kanan Atas)
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finishOnboarding,
                child: const Text("Lewati", style: TextStyle(color: Colors.grey)),
              ),
            ),

            // 2. PAGE VIEW (Slide Gambar & Teks)
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Gambar/Icon Besar (Ganti Image.asset jika punya gambar khusus)
                        Container(
                          height: 250,
                          width: 250,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          // Sementara pakai Logo, nanti bisa diganti ilustrasi vektor
                          child: Padding(
                            padding: const EdgeInsets.all(40.0),
                            child: Image.asset(
                              _onboardingData[index]['icon']!,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        
                        // Judul
                        Text(
                          _onboardingData[index]['title']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Deskripsi
                        Text(
                          _onboardingData[index]['desc']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // 3. INDIKATOR & TOMBOL
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Titik-titik Indikator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingData.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        height: 8,
                        width: _currentPage == index ? 24 : 8, // Titik aktif lebih panjang
                        decoration: BoxDecoration(
                          color: _currentPage == index 
                              ? AppColors.primary 
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Tombol Lanjut / Mulai
                  PrimaryButton(
                    text: _currentPage == _onboardingData.length - 1 
                        ? "Mulai Sekarang" 
                        : "Lanjut",
                    onPressed: () {
                      if (_currentPage == _onboardingData.length - 1) {
                        _finishOnboarding(); // Selesai
                      } else {
                        _pageController.nextPage( // Geser ke halaman berikut
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}