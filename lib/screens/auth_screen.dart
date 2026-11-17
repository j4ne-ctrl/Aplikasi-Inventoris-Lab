import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../services/auth_service.dart';
import 'main_navigation_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  bool _isAdmin = false; // false = siswa, true = admin
  bool _isLogin = true;
  bool _isLoading = false;
  bool _hidePass = true;

  final _nameCtrl = TextEditingController();
  final _kelasCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _kelasCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  String? _validateName(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'Nama lengkap wajib diisi';
    if (value.length < 3) return 'Nama minimal 3 karakter';
    if (!RegExp(r"^[a-zA-Z .'-]+$").hasMatch(value)) {
      return 'Nama hanya boleh berisi huruf';
    }
    return null;
  }

  String? _validateKelas(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'Kelas wajib diisi';
    if (value.length < 2) return 'Kelas terlalu pendek';
    return null;
  }

  String? _validateEmail(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'Email wajib diisi';
    if (!RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$').hasMatch(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? _validatePassword(String? v) {
    final value = v ?? '';
    if (value.isEmpty) return 'Password wajib diisi';
    if (value.length < 6) return 'Password minimal 6 karakter';
    if (!_isLogin) {
      if (!RegExp(r'[A-Za-z]').hasMatch(value) ||
          !RegExp(r'[0-9]').hasMatch(value)) {
        return 'Password harus mengandung huruf dan angka';
      }
    }
    return null;
  }

  String _firebaseMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'not-admin':
        return 'Akun ini bukan admin. Pilih "Siswa" untuk masuk.';
      case 'wrong-password':
        return 'Email atau password salah';
      case 'user-not-found':
      case 'invalid-credential':
        return _isAdmin
            ? 'Email atau password admin salah'
            : 'Email atau password salah, atau belum terdaftar';
      case 'email-already-in-use':
        return 'Email sudah terdaftar, silakan login';
      case 'invalid-email':
        return 'Format email tidak valid';
      case 'weak-password':
        return 'Password terlalu lemah';
      case 'network-request-failed':
        return 'Tidak ada koneksi internet';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan, coba lagi nanti';
      default:
        return e.message ?? 'Gagal autentikasi Firebase';
    }
  }

  void _showToast(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        backgroundColor: isError ? AppColors.rose : AppColors.slate900,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;

    setState(() => _isLoading = true);

    try {
      if (_isAdmin) {
        await _authService.loginAdmin(email: email, password: pass);
        _showToast('Login admin berhasil!');
      } else if (_isLogin) {
        await _authService.login(email: email, password: pass);
        _showToast('Login berhasil!');
        
      } else {
        await _authService.register(
          name: _nameCtrl.text.trim(),
          kelas: _kelasCtrl.text.trim(),
          email: email,
          password: pass,
        );
        _showToast('Registrasi berhasil!');
      }

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    } on FirebaseAuthException catch (e) {
      _showToast(_firebaseMessage(e), isError: true);
    } catch (e) {
      _showToast('Terjadi kesalahan: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _switchTab(bool login) {
    setState(() => _isLogin = login);
    _formKey.currentState?.reset();
  }

  void _switchRole(bool admin) {
    setState(() {
      _isAdmin = admin;
      _isLogin = true; // admin hanya login
    });
    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    final title = _isAdmin
        ? 'Masuk sebagai Admin'
        : (_isLogin ? 'Masuk ke Lab-Inventory' : 'Daftar Akun Siswa');
    final subtitle = _isAdmin
        ? 'Akun admin dibuat oleh pengelola lab'
        : (_isLogin
            ? 'Gunakan akun sekolah Anda'
            : 'Identitas tersimpan otomatis ke Firestore users/{uid}');

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.techIndigo,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.techIndigo.withOpacity(0.25),
                        blurRadius: 14,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isAdmin
                        ? Icons.admin_panel_settings_rounded
                        : Icons.verified_user_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 13, color: AppColors.slate500),
                ),
                const SizedBox(height: 18),

                // Pilihan peran: Siswa / Admin
                Row(
                  children: [
                    _buildRoleCard('Siswa', Icons.school_rounded, !_isAdmin,
                        () => _switchRole(false)),
                    const SizedBox(width: 10),
                    _buildRoleCard('Admin', Icons.admin_panel_settings_rounded,
                        _isAdmin, () => _switchRole(true)),
                  ],
                ),
                const SizedBox(height: 14),

                // Tab Login / Register (hanya untuk siswa)
                if (!_isAdmin) ...[
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.slate200),
                    ),
                    child: Row(
                      children: [
                        _buildTabBtn('Login', _isLogin, () => _switchTab(true)),
                        _buildTabBtn('Register', !_isLogin, () => _switchTab(false)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.slate200),
                  ),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!_isAdmin && !_isLogin) ...[
                          _buildLabel('NAMA LENGKAP'),
                          _buildInput(_nameCtrl, 'Raka Mahendra',
                              validator: _validateName),
                          const SizedBox(height: 14),
                          _buildLabel('KELAS'),
                          _buildInput(_kelasCtrl, 'XI RPL 1',
                              validator: _validateKelas),
                          const SizedBox(height: 14),
                        ],
                        _buildLabel('EMAIL'),
                        _buildInput(
                          _emailCtrl,
                          _isAdmin ? 'admin@smk.sch.id' : 'siswa@smk.sch.id',
                          validator: _validateEmail,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 14),
                        _buildLabel('PASSWORD'),
                        _buildInput(
                          _passCtrl,
                          'Minimal 6 karakter',
                          validator: _validatePassword,
                          obscure: _hidePass,
                          suffix: IconButton(
                            icon: Icon(
                              _hidePass
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              size: 18,
                              color: AppColors.slate400,
                            ),
                            onPressed: () =>
                                setState(() => _hidePass = !_hidePass),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.techIndigo,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    _isAdmin
                                        ? 'MASUK SEBAGAI ADMIN'
                                        : (_isLogin
                                            ? 'MASUK SEKARANG'
                                            : 'DAFTAR & SIMPAN AKUN'),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
      String label, IconData icon, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? AppColors.techIndigo.withOpacity(0.08) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: active ? AppColors.techIndigo : AppColors.slate200,
              width: active ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 18,
                  color: active ? AppColors.techIndigo : AppColors.slate400),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: active ? AppColors.techIndigo : AppColors.slate500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBtn(String text, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? AppColors.techIndigo : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: active ? Colors.white : AppColors.slate500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppColors.slate500,
        ),
      ),
    );
  }

  Widget _buildInput(
    TextEditingController ctrl,
    String hint, {
    required String? Function(String?) validator,
    bool obscure = false,
    TextInputType? keyboardType,
    Widget? suffix,
  }) {
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c, width: w),
        );

    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: AppColors.slate900),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: AppColors.slate400),
        errorStyle: const TextStyle(fontSize: 11, color: AppColors.rose),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: border(AppColors.slate200),
        focusedBorder: border(AppColors.techIndigo, 1.5),
        errorBorder: border(AppColors.rose),
        focusedErrorBorder: border(AppColors.rose, 1.5),
      ),
    );
  }
}
