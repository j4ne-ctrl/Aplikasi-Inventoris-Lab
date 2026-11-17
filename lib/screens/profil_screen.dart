import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/app_colors.dart';
import '../models/borrow_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../widgets/edit_profile_sheet.dart';
import 'auth_screen.dart';
import '../models/item_model.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  String _historyTab = 'Borrowed'; // 'Borrowed' | 'Returned'

  String _formatTimestamp(Timestamp? ts) {
    if (ts == null) return 'Baru saja';
    return DateFormat('dd MMM yyyy, HH:mm').format(ts.toDate().toLocal());
  }

  void _openEditProfile(UserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (_) => EditProfileSheet(user: user),
    );
  }

  Future<void> _handleLogout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Keluar dari akun?',
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        content: const Text(
          'Kamu harus login lagi untuk memakai aplikasi.',
          style: TextStyle(fontSize: 13, color: AppColors.slate500),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.rose,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (ok != true) return; // batal atau dialog ditutup

    await _authService.logout();
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const AuthScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final uid = _authService.currentUser?.uid ?? '';

    return StreamBuilder<UserModel>(
      stream: _firestoreService.streamUserProfile(uid),
      builder: (context, userSnap) {
        final user =
            userSnap.data ??
            UserModel(
              userId: uid,
              name: 'Siswa RPL',
              email: _authService.currentUser?.email ?? 'siswa@smk.sch.id',
              kelas: 'XI RPL 1',
              foto:
                  'https://ui-avatars.com/api/?name=Siswa+RPL&background=4F46E5&color=FFFFFF',
            );

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                border: const Border(
                  bottom: BorderSide(color: AppColors.slate200),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'profil',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate900,
                        ),
                      ),
                      Text(
                        'users/${user.userId}',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          color: AppColors.slate400,
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: _handleLogout,
                    icon: const Icon(Icons.logout_rounded, size: 15),
                    label: const Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFFFF1F2),
                      foregroundColor: AppColors.rose,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFFECDD3)),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.slate200),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: AppColors.techIndigo,
                                      width: 2,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network(
                                      user.foto,
                                      width: 64,
                                      height: 64,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: -4,
                                  right: -4,
                                  child: GestureDetector(
                                    onTap: () => _openEditProfile(user),
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: AppColors.techIndigo,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt_rounded,
                                        size: 13,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.techIndigo.withOpacity(
                                        0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      user.isAdmin ? 'ADMIN' : user.kelas,
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.techIndigo,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user.name,
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.slate900,
                                    ),
                                  ),
                                  Text(
                                    user.email,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.slate500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _openEditProfile(user),
                            icon: const Icon(
                              Icons.manage_accounts_rounded,
                              size: 16,
                            ),
                            label: const Text(
                              'Edit Username & Foto Profil',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: const Color(0xFFF8FAFC),
                              foregroundColor: AppColors.slate800,
                              side: const BorderSide(color: AppColors.slate200),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  user.isAdmin
                      ? _buildAdminBorrowedList()
                      : StreamBuilder<List<BorrowModel>>(
                          stream: _firestoreService.streamUserBorrowings(uid),
                          builder: (context, borrowSnap) {
                            final allBorrows = borrowSnap.data ?? [];
                            final activeBorrows = allBorrows
                                .where((b) => b.status == 'Borrowed')
                                .toList();
                            final returnedBorrows = allBorrows
                                .where((b) => b.status == 'Returned')
                                .toList();
                            final displayed = _historyTab == 'Borrowed'
                                ? activeBorrows
                                : returnedBorrows;

                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Riwayat Peminjaman',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.slate900,
                                      ),
                                    ),
                                    Text(
                                      'Total: ${allBorrows.length}',
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 10,
                                        color: AppColors.techIndigo,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppColors.slate200,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      _buildHistoryTabButton(
                                        label: 'Sedang Dipinjam',
                                        count: activeBorrows.length,
                                        isActive: _historyTab == 'Borrowed',
                                        activeColor: AppColors.amber,
                                        onTap: () => setState(
                                          () => _historyTab = 'Borrowed',
                                        ),
                                      ),
                                      _buildHistoryTabButton(
                                        label: 'Sudah Dikembalikan',
                                        count: returnedBorrows.length,
                                        isActive: _historyTab == 'Returned',
                                        activeColor: AppColors.emerald,
                                        onTap: () => setState(
                                          () => _historyTab = 'Returned',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),

                                if (displayed.isEmpty)
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: AppColors.slate200,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      _historyTab == 'Borrowed'
                                          ? 'Tidak ada alat yang sedang dipinjam.'
                                          : 'Belum ada riwayat alat yang dikembalikan.',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.slate400,
                                      ),
                                    ),
                                  )
                                else
                                  ...displayed.map((b) {
                                    final isBorrowed = b.status == 'Borrowed';
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isBorrowed
                                              ? const Color(0xFFFDE68A)
                                              : const Color(0xFFA7F3D0),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      b.borrowId.substring(
                                                        0,
                                                        b.borrowId.length > 8
                                                            ? 8
                                                            : b.borrowId.length,
                                                      ),
                                                      style:
                                                          GoogleFonts.jetBrainsMono(
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: AppColors
                                                                .techIndigo,
                                                          ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 6,
                                                            vertical: 2,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: isBorrowed
                                                            ? const Color(
                                                                0xFFFFFBEB,
                                                              )
                                                            : const Color(
                                                                0xFFECFDF5,
                                                              ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              4,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        isBorrowed
                                                            ? 'Borrowed'
                                                            : 'Returned',
                                                        style: TextStyle(
                                                          fontSize: 9,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: isBorrowed
                                                              ? const Color(
                                                                  0xFFB45309,
                                                                )
                                                              : const Color(
                                                                  0xFF047857,
                                                                ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 3),
                                                Text(
                                                  b.itemName,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.slate900,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.access_time_rounded,
                                                      size: 11,
                                                      color: AppColors.slate400,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      'Pinjam: ${_formatTimestamp(b.borrowDate)}',
                                                      style:
                                                          GoogleFonts.jetBrainsMono(
                                                            fontSize: 10,
                                                            color: AppColors
                                                                .slate500,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                                if (!isBorrowed &&
                                                    b.returnDate != null) ...[
                                                  const SizedBox(height: 2),
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons
                                                            .event_available_rounded,
                                                        size: 11,
                                                        color:
                                                            AppColors.emerald,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        'Kembali: ${_formatTimestamp(b.returnDate)}',
                                                        style:
                                                            GoogleFonts.jetBrainsMono(
                                                              fontSize: 10,
                                                              color: AppColors
                                                                  .emerald,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          if (isBorrowed)
                                            ElevatedButton(
                                              onPressed: () async {
                                                await _firestoreService
                                                    .returnBorrowedItem(
                                                      uid: uid,
                                                      borrowRecord: b,
                                                    );
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        '${b.itemName} dikembalikan.',
                                                      ),
                                                      backgroundColor:
                                                          AppColors.slate900,
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                      duration: const Duration(
                                                        seconds: 2,
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppColors.techIndigo,
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 8,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              child: const Text(
                                                'Kembalikan',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            )
                                          else
                                            Container(
                                              width: 28,
                                              height: 28,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFFECFDF5),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons
                                                    .check_circle_outline_rounded,
                                                size: 16,
                                                color: AppColors.emerald,
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  }),
                              ],
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // Khusus admin: alat yang sedang dipinjam + siapa peminjamnya
  Widget _buildAdminBorrowedList() {
    return StreamBuilder<List<ItemModel>>(
      stream: _firestoreService.streamItems(),
      builder: (context, snap) {
        final borrowed = (snap.data ?? [])
            .where((i) => i.status == 'Borrowed')
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Alat Sedang Dipinjam',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate900,
                  ),
                ),
                Text(
                  'Total: ${borrowed.length}',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    color: AppColors.techIndigo,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (borrowed.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.slate200),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Tidak ada alat yang sedang dipinjam.',
                  style: TextStyle(fontSize: 12, color: AppColors.slate400),
                ),
              )
            else
              ...borrowed.map(
                (i) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: Color(0xFFFFFBEB),
                        child: Icon(
                          Icons.person_rounded,
                          size: 18,
                          color: AppColors.amber,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              i.itemName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.slate900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              i.borrowedByName == null
                                  ? 'Peminjam belum tercatat'
                                  : '${i.borrowedByName} • ${i.borrowedByKelas ?? '-'}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.slate500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        i.code,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 9,
                          color: AppColors.slate400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildHistoryTabButton({
    required String label,
    required int count,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
            color: isActive ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.white : AppColors.slate500,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white.withOpacity(0.25)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.white : AppColors.slate600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
