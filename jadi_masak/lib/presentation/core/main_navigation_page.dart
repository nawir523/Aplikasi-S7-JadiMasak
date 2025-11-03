import 'package:flutter/material.dart';
import 'package:jadi_masak/presentation/home/home_page.dart';
import 'package:jadi_masak/presentation/pantry/pantry_page.dart';
import 'package:jadi_masak/presentation/profile/profile_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  // 1. Variabel untuk melacak tab yang sedang aktif
  int _selectedIndex = 0; 

  // 2. Daftar halaman-halaman yang akan ditampilkan
  static const List<Widget> _pages = <Widget>[
    HomePage(),    // Indeks 0 (Beranda)
    PantryPage(),  // Indeks 1 (Kulkasku)
    ProfilePage(), // Indeks 2 (Profil)
  ];

  // 3. Fungsi untuk mengubah indeks saat tab diklik
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 4. Tampilkan halaman sesuai indeks yang aktif
      body: _pages.elementAt(_selectedIndex), 

      // 5. Buat Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.kitchen_outlined),
            activeIcon: Icon(Icons.kitchen),
            label: 'Kulkasku',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex, // Tandai tab yang aktif
        selectedItemColor: Colors.orange, // Warna tab yang aktif
        onTap: _onItemTapped, // Panggil fungsi saat tab diklik
      ),
    );
  }
}