import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'beranda_screen.dart';
import 'inventaris_screen.dart';
import 'profil_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _activeIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      BerandaScreen(
        onNavigateToInventaris: () => setState(() => _activeIndex = 1),
      ),
      const InventarisScreen(),
      const ProfilScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: pages[_activeIndex],
          ),

          // Floating Pill Bottom Navigation Bar
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.slate200),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.slate900.withOpacity(0.1),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _buildNavItem(0, Icons.home_rounded, 'Beranda'),
                  _buildNavItem(1, Icons.inventory_2_rounded, 'Inventaris'),
                  _buildNavItem(2, Icons.person_rounded, 'Profil'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _activeIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.techIndigo : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : AppColors.slate500,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : AppColors.slate500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}