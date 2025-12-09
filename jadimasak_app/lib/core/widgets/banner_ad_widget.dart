import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 1. Import Riverpod
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../features/auth/logic/auth_controller.dart'; // 2. Import Controller

class BannerAdWidget extends ConsumerStatefulWidget {
  const BannerAdWidget({super.key});

  @override
  ConsumerState<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends ConsumerState<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  final String _adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111' 
      : 'ca-app-pub-3940256099942544/2934735716';

  @override
  void initState() {
    super.initState();
    // Iklan akan di-load nanti di build jika user bukan PRO
  }

  void _loadAd() {
    // Cegah load ganda
    if (_bannerAd != null) return; 

    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          print('Gagal memuat iklan: $err');
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 3. CEK STATUS PRO
    final isProAsync = ref.watch(userSubscriptionProvider);

    return isProAsync.when(
      data: (isPro) {
        // JIKA PRO: Jangan tampilkan apa-apa (Widget hilang)
        if (isPro) {
          return const SizedBox.shrink(); 
        }

        // JIKA FREE: Load iklan (kalau belum) dan tampilkan
        if (_bannerAd == null) _loadAd();

        if (!_isLoaded || _bannerAd == null) {
          return const SizedBox(height: 50); // Placeholder tinggi iklan
        }

        return Container(
          alignment: Alignment.center,
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        );
      },
      // Saat loading status, sembunyikan dulu atau tampilkan placeholder
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}