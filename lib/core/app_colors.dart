import 'package:flutter/material.dart';

class AppColors {
static const Color lightBg = Color(0xFFFFFAFB); // putih dengan sentuhan pink tipis  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color techIndigo = Color(0xFF9F1239);   // burgundy utama
  static const Color techCobalt = Color(0xFF881337);   // burgundy tua
  static const Color techCyan = Color(0xFFFB7185);     // pink koral (aksen imut)
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color emerald = Color(0xFF10B981);
  static const Color amber = Color(0xFFF59E0B);
  static const Color rose = Color(0xFFE11D48);

  // Banner beranda
  static const Color bannerDark = Color(0xFF4C0519);
  static const Color bannerMid = Color(0xFF881337);
  static const Color bannerText = Color(0xFFFFE4E6);

  // Tema khusus admin (biru)
static const Color adminBg = Color(0xFFF1F6FA);
static const Color adminPrimary = Color(0xFF0369A1);
static const Color adminDark = Color(0xFF075985);
static const Color adminAccent = Color(0xFF06B6D4);

static const LinearGradient adminGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF0369A1), Color(0xFF06B6D4)],
);

static const LinearGradient adminBannerGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF082F49), Color(0xFF0C4A6E), Color(0xFF0369A1)],
);

}