import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/logic/auth_controller.dart';

class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({super.key});

  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends ConsumerState<PremiumScreen> {
  bool _isLoading = false; // State untuk loading

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Stack(
          children: [
            // Tombol Close
            Positioned(
              top: 10, left: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => context.pop(),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.workspace_premium, size: 100, color: Colors.yellow),
                  const SizedBox(height: 20),
                  const Text(
                    "Jadi Masak PRO",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Masak lebih fokus tanpa gangguan iklan.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 50),
                  
                  // Kartu Keuntungan
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.block, color: Colors.red),
                          title: Text("Bebas Iklan", style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("Tidak ada lagi banner yang mengganggu."),
                        ),
                        Divider(),
                        ListTile(
                          leading: Icon(Icons.verified, color: Colors.blue),
                          title: Text("Support Developer", style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("Bantu kami mengembangkan fitur baru."),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Tombol Beli (Dengan Loading)
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () { 
                        setState(() => _isLoading = true);

                        ref.read(upgradeProProvider)(
                          () { // On Success
                            if (mounted) {
                              setState(() => _isLoading = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Selamat! Anda sekarang PRO Member! 🎉"), backgroundColor: Colors.green),
                              );
                              context.pop(); // Keluar halaman
                            }
                          },
                          (errorMsg) { // On Error
                            if (mounted) {
                              setState(() => _isLoading = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
                              );
                            }
                          }
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: _isLoading 
                        ? const CircularProgressIndicator(color: AppColors.primary) // Loading Indicator
                        : const Text(
                            "Upgrade Sekarang - Rp 0 (Simulasi)",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Sekali bayar untuk selamanya.",
                    style: TextStyle(color: Colors.white54, fontSize: 12),
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