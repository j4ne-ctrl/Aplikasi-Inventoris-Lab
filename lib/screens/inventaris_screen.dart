import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../models/item_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../widgets/crud_item_sheet.dart';

class InventarisScreen extends StatelessWidget {
  const InventarisScreen({super.key});

  void _openCrudForm(BuildContext context, {ItemModel? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (_) => CrudItemSheet(existingItem: existing),
    );
  }

  // Pesan saat tombol yang terkunci diketuk
  void _showLocked(BuildContext context, String aksi) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Alat sedang dipinjam, tidak bisa $aksi.'),
        backgroundColor: AppColors.slate900,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Dialog konfirmasi sebelum menghapus data
  Future<void> _confirmDelete(
    BuildContext context,
    FirestoreService service,
    ItemModel item,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Hapus alat?',
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.bold,
            color: AppColors.slate900,
          ),
        ),
        content: Text(
          '"${item.itemName}" akan dihapus permanen dari inventaris dan tidak bisa dikembalikan.',
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.slate600,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.rose,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (ok != true) return; // dibatalkan atau dialog ditutup

    try {
      await service.deleteItem(item.itemId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${item.itemName}" dihapus.'),
            backgroundColor: AppColors.slate900,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus: $e'),
            backgroundColor: AppColors.rose,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = AuthService().currentUser?.uid ?? '-';
    return StreamBuilder<UserModel>(
      stream: FirestoreService().streamUserProfile(uid),
      builder: (context, userSnap) =>
          _buildBody(context, userSnap.data?.isAdmin ?? false),
    );
  }

  Widget _buildBody(BuildContext context, bool isAdmin) {
    final firestoreService = FirestoreService();

    return StreamBuilder<List<ItemModel>>(
      stream: firestoreService.streamItems(),
      builder: (context, snapshot) {
        final items = snapshot.data ?? [];
        final total = items.length;
        final availCount = items.where((i) => i.status == 'Available').length;
        final borrowCount = items.where((i) => i.status == 'Borrowed').length;

        return Column(
          children: [
            // Header dengan teks wajib "inventaris" + Bento Statistik
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                border: const Border(bottom: BorderSide(color: AppColors.slate200)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'inventaris',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.slate900,
                            ),
                          ),
                          Text(
                            isAdmin ? 'MODE ADMIN' : 'DAFTAR ALAT LAB',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.techIndigo,
                            ),
                          ),
                        ],
                      ),
                      if (isAdmin)
                      ElevatedButton.icon(
                        onPressed: () => _openCrudForm(context),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text(
                          'Tambah',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.techIndigo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildStatBox('$total', 'TOTAL ALAT', const Color(0xFFF8FAFC), AppColors.slate200, AppColors.slate900, AppColors.slate500),
                      const SizedBox(width: 8),
                      _buildStatBox('$availCount', 'AVAILABLE', const Color(0xFFECFDF5), const Color(0xFFA7F3D0), const Color(0xFF047857), AppColors.emerald),
                      const SizedBox(width: 8),
                      _buildStatBox('$borrowCount', 'BORROWED', const Color(0xFFFFFBEB), const Color(0xFFFDE68A), const Color(0xFFB45309), AppColors.amber),
                    ],
                  ),
                ],
              ),
            ),

            // Daftar CRUD Real-time
            Expanded(
              child: snapshot.hasError
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Gagal memuat data:\n${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12, color: AppColors.rose),
                        ),
                      ),
                    )
                  : snapshot.connectionState == ConnectionState.waiting &&
                          !snapshot.hasData
                      ? const Center(child: CircularProgressIndicator())
                      : items.isEmpty
                          ? const Center(
                              child: Text(
                                'Koleksi inventaris kosong.\nKlik tombol + Tambah untuk membuat data.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12, color: AppColors.slate400),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                              itemCount: items.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 10),
                              itemBuilder: (_, idx) {
                                final item = items[idx];
                                final isAvail = item.status == 'Available';
                                final locked = !isAvail; // alat yang dipinjam dikunci

                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: AppColors.slate200),
                                  ),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: item.image.trim().isEmpty
                                            ? Container(
                                                width: 56,
                                                height: 56,
                                                color: AppColors.slate200,
                                                child: const Icon(Icons.biotech, color: AppColors.slate400),
                                              )
                                            : Image.network(
                                                item.image,
                                                width: 56,
                                                height: 56,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) => Container(
                                                  width: 56,
                                                  height: 56,
                                                  color: AppColors.slate200,
                                                  child: const Icon(Icons.biotech, color: AppColors.slate400),
                                                ),
                                              ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  item.code,
                                                  style: GoogleFonts.jetBrainsMono(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.techIndigo,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: isAvail ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    item.status,
                                                    style: TextStyle(
                                                      fontSize: 9,
                                                      fontWeight: FontWeight.bold,
                                                      color: isAvail ? const Color(0xFF047857) : const Color(0xFFB45309),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              item.itemName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.slate900,
                                              ),
                                            ),
                                            Text(
                                              item.category,
                                              style: const TextStyle(fontSize: 10, color: AppColors.slate500),

                                            ),

                                            if (isAdmin && !isAvail && item.borrowedByName != null)

                                              Padding(

                                                padding: const EdgeInsets.only(top: 3),

                                                child: Text(

                                                  'Dipinjam: ${item.borrowedByName} • ${item.borrowedByKelas ?? '-'}',

                                                  maxLines: 1,

                                                  overflow: TextOverflow.ellipsis,

                                                  style: const TextStyle(

                                                      fontSize: 10,

                                                      fontWeight: FontWeight.bold,

                                                      color: AppColors.amber),

                                                ),

                                              ),
                                          ],
                                        ),
                                      ),
                                      if (isAdmin)
                                      Column(
                                        children: [
                                          // TOMBOL EDIT
                                          InkWell(
                                            onTap: locked
                                                ? () => _showLocked(context, 'diedit')
                                                : () => _openCrudForm(context, existing: item),
                                            borderRadius: BorderRadius.circular(8),
                                            child: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: locked
                                                    ? AppColors.slate200.withOpacity(0.6)
                                                    : AppColors.techIndigo.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Icon(
                                                Icons.edit_rounded,
                                                size: 15,
                                                color: locked ? AppColors.slate400 : AppColors.techIndigo,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          // TOMBOL HAPUS (dengan dialog konfirmasi)
                                          InkWell(
                                            onTap: locked
                                                ? () => _showLocked(context, 'dihapus')
                                                : () => _confirmDelete(context, firestoreService, item),
                                            borderRadius: BorderRadius.circular(8),
                                            child: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: locked
                                                    ? AppColors.slate200.withOpacity(0.6)
                                                    : AppColors.rose.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Icon(
                                                locked
                                                    ? Icons.lock_outline_rounded
                                                    : Icons.delete_outline_rounded,
                                                size: 15,
                                                color: locked ? AppColors.slate400 : AppColors.rose,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatBox(String val, String label, Color bg, Color border, Color valColor, Color lblColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Column(
          children: [
            Text(
              val,
              style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.bold, color: valColor),
            ),
            Text(
              label,
              style: GoogleFonts.jetBrainsMono(fontSize: 9, fontWeight: FontWeight.bold, color: lblColor),
            ),
          ],
        ),
      ),
    );
  }
}
