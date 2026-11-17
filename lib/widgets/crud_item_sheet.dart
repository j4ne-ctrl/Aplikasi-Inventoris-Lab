import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../models/item_model.dart';
import '../services/firestore_service.dart';

class CrudItemSheet extends StatefulWidget {
  final ItemModel? existingItem;
  const CrudItemSheet({super.key, this.existingItem});

  @override
  State<CrudItemSheet> createState() => _CrudItemSheetState();
}

class _CrudItemSheetState extends State<CrudItemSheet> {
  final FirestoreService _firestoreService = FirestoreService();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _codeCtrl;
  late final TextEditingController _fotoCtrl;
  late final TextEditingController _specCtrl;
  late String _selectedCat;
  late String _selectedStatus;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existingItem;
    _nameCtrl = TextEditingController(text: e?.itemName ?? '');
    _codeCtrl = TextEditingController(
      text: e?.code ?? 'LAB-2026-${10 + Random().nextInt(89)}',
    );
    _fotoCtrl = TextEditingController(text: e?.image ?? '');
    _specCtrl = TextEditingController(text: e?.spesification ?? '');
    _selectedCat = e?.category ?? 'Jaringan';
    _selectedStatus = e?.status ?? 'Available';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _fotoCtrl.dispose();
    _specCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveData() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    setState(() => _isSaving = true);

    try {
      if (widget.existingItem != null) {
        await _firestoreService.updateItem(
          itemId: widget.existingItem!.itemId,
          itemName: _nameCtrl.text.trim(),
          code: _codeCtrl.text.trim(),
          category: _selectedCat,
          status: _selectedStatus,
          spesification: _specCtrl.text.trim(),
          image: _fotoCtrl.text.trim(),
        );
      } else {
        await _firestoreService.addItem(
          itemName: _nameCtrl.text.trim(),
          code: _codeCtrl.text.trim(),
          category: _selectedCat,
          status: _selectedStatus,
          spesification: _specCtrl.text.trim(),
          image: _fotoCtrl.text.trim(),
        );
      }

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.existingItem != null
                ? 'Perubahan disimpan ke Firestore!'
                : 'Alat baru berhasil ditambahkan!',
          ),
          backgroundColor: AppColors.slate900,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 11, color: AppColors.slate400),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.slate200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.techIndigo),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingItem != null;
    final previewUrl = _fotoCtrl.text.trim();

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.slate200,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEdit ? 'Edit Data Inventaris' : 'Tambah Alat Lab Baru',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate900,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.techIndigo.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'items/${isEdit ? widget.existingItem!.itemId.substring(0, 6) : "{autoId}"}',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      color: AppColors.techIndigo,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text('Nama Peralatan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            TextField(
              controller: _nameCtrl,
              style: const TextStyle(fontSize: 12),
              decoration: _inputDeco('Misal: Raspberry Pi 5 8GB RAM'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Kode Seri', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _codeCtrl,
                        style: GoogleFonts.jetBrainsMono(fontSize: 12),
                        decoration: _inputDeco('LAB-2026-01'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Kategori', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<String>(
                        value: _selectedCat,
                        decoration: _inputDeco(''),
                        style: const TextStyle(fontSize: 12, color: AppColors.slate900),
                        items: ['Jaringan', 'Hardware', 'IoT', 'Multimedia']
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (val) => setState(() => _selectedCat = val!),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text('Status', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: _inputDeco(''),
              style: const TextStyle(fontSize: 12, color: AppColors.slate900),
              items: ['Available', 'Borrowed']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedStatus = val!),
            ),
            const SizedBox(height: 10),
            const Text('URL Foto Barang', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            TextField(
              controller: _fotoCtrl,
              onChanged: (_) => setState(() {}),
              style: GoogleFonts.jetBrainsMono(fontSize: 11),
              decoration: _inputDeco('https://... (kosongkan untuk foto default)'),
            ),
            if (previewUrl.isNotEmpty) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  previewUrl,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 60,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'URL gambar tidak valid atau gagal dimuat',
                      style: TextStyle(fontSize: 10, color: AppColors.slate400),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
            const Text('Spesifikasi Alat', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            TextField(
              controller: _specCtrl,
              maxLines: 2,
              style: const TextStyle(fontSize: 12),
              decoration: _inputDeco('Detail teknis komponen...'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFF1F5F9),
                    foregroundColor: AppColors.slate600,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Batal', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.techIndigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      _isSaving ? 'Menyimpan...' : 'Simpan Data',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}