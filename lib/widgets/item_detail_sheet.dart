import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../models/item_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class ItemDetailSheet extends StatefulWidget {
  final ItemModel item;
  const ItemDetailSheet({super.key, required this.item});

  @override
  State<ItemDetailSheet> createState() => _ItemDetailSheetState();
}

class _ItemDetailSheetState extends State<ItemDetailSheet> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  late final Stream<UserModel> _userStream;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _userStream = _firestoreService
        .streamUserProfile(_authService.currentUser?.uid ?? '-');
  }

  Future<void> _run(Future<void> Function() job, String okMsg) async {
    setState(() => _busy = true);
    try {
      await job();
      if (!mounted) return;
      Navigator.pop(context);
      _toast(okMsg);
    } catch (e) {
      if (mounted) _toast('Gagal: $e', error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _toast(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? AppColors.rose : AppColors.slate900,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _photo(String url) {
    final ph = Container(
      height: 160,
      width: double.infinity,
      color: AppColors.slate200,
      child: const Icon(Icons.biotech, color: AppColors.slate400, size: 40),
    );
    if (url.trim().isEmpty) return ph;
    return Image.network(url,
        height: 160,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => ph);
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isAvail = item.status == 'Available';
    final uid = _authService.currentUser?.uid;

    return StreamBuilder<UserModel>(
      stream: _userStream,
      builder: (context, snap) {
        final isAdmin = snap.data?.isAdmin ?? false;
        final mine = !isAvail && item.borrowedByUid == uid;

        // Tombol aksi sesuai peran dan kondisi alat
        Widget? action;
        if (!isAdmin) {
          if (isAvail) {
            action = _actionButton(
              'PINJAM ALAT SEKARANG',
              Icons.north_east_rounded,
              _busy
                  ? null
                  : () => _run(
                        () => _firestoreService.borrowItem(uid: uid!, item: item),
                        'Berhasil meminjam ${item.itemName}!',
                      ),
            );
          } else if (mine) {
            action = _actionButton(
              'KEMBALIKAN ALAT',
              Icons.assignment_return_rounded,
              _busy
                  ? null
                  : () => _run(
                        () => _firestoreService.returnItem(uid: uid!, item: item),
                        '${item.itemName} dikembalikan.',
                      ),
            );
          } else {
            action = _actionButton('SEDANG DIPINJAM', Icons.lock_rounded, null);
          }
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.slate200,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: _photo(item.image),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: _chip(item.code, AppColors.slate900.withOpacity(0.8), Colors.white, mono: true),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: _chip(item.status, isAvail ? AppColors.emerald : AppColors.amber, Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _chip(item.category.toUpperCase(), AppColors.techIndigo.withOpacity(0.1), AppColors.techIndigo, mono: true),
                    Text(
                      'ID: ${item.itemId.substring(0, item.itemId.length > 8 ? 8 : item.itemId.length)}',
                      style: GoogleFonts.jetBrainsMono(fontSize: 10, color: AppColors.slate400),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.itemName,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate900,
                  ),
                ),
                const SizedBox(height: 12),

                // Khusus admin: siapa yang sedang meminjam
                if (isAdmin && !isAvail) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFED7AA)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.person_pin_rounded, color: AppColors.amber),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('DIPINJAM OLEH',
                                  style: GoogleFonts.jetBrainsMono(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.slate500)),
                              const SizedBox(height: 2),
                              Text(
                                item.borrowedByName == null
                                    ? 'Data peminjam belum tercatat'
                                    : '${item.borrowedByName} • ${item.borrowedByKelas ?? '-'}',
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.slate900),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.slate200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SPESIFIKASI TEKNIS',
                          style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.slate400)),
                      const SizedBox(height: 4),
                      Text(item.spesification,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.slate600, height: 1.5)),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFF1F5F9),
                        foregroundColor: AppColors.slate600,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Tutup', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    if (action != null) ...[
                      const SizedBox(width: 10),
                      Expanded(child: action),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _chip(String text, Color bg, Color fg, {bool mono = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(
        text,
        style: mono
            ? GoogleFonts.jetBrainsMono(fontSize: 10, color: fg, fontWeight: FontWeight.bold)
            : TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }

  Widget _actionButton(String label, IconData icon, VoidCallback? onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(
        _busy ? 'MEMPROSES...' : label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.techIndigo,
        foregroundColor: Colors.white,
        disabledBackgroundColor: const Color(0xFFF1F5F9),
        disabledForegroundColor: AppColors.slate400,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
