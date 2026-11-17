import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../models/item_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../widgets/item_cards.dart';
import '../widgets/item_detail_sheet.dart';

class BannerItem {
  final String tag;
  final String title;
  final String subtitle;
  final String image;

  const BannerItem({
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.image,
  });
}

class BerandaScreen extends StatefulWidget {
  final VoidCallback onNavigateToInventaris;
  const BerandaScreen({super.key, required this.onNavigateToInventaris});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  final _searchCtrl = TextEditingController();
  final _pageCtrl = PageController(viewportFraction: 0.85);
  Timer? _carouselTimer;
  int _currentBanner = 0;

  late final Stream<UserModel> _userStream;
  late final Stream<List<ItemModel>> _itemsStream;

  String _searchQuery = '';
  String _selectedCategory = 'Jaringan';
  String _selectedCategoryStatus = 'Semua';
  String _selectedStatus = 'Available';

  final List<BannerItem> _banners = const [
    BannerItem(
      tag: 'INFRASTRUCTURE LAB',
      title: 'Perangkat Jaringan & Server',
      subtitle:
          'Router MikroTik, Managed Switch Cisco & Crimping Kit siap praktikum',
      image:
          'https://images.unsplash.com/photo-1558494949-ef010cbdcc31?auto=format&fit=crop&w=800&q=80',
    ),
    BannerItem(
      tag: 'EMBEDDED & IOT',
      title: 'Mikrokontroler & Sensor Cerdas',
      subtitle: 'Eksplorasi proyek ESP32, Arduino R4 WiFi, dan modul aktuator',
      image:
          'https://images.unsplash.com/photo-1518770660439-4636190af475?auto=format&fit=crop&w=800&q=80',
    ),
    BannerItem(
      tag: 'REAL-TIME SYNC',
      title: 'Peminjaman Digital Tanpa Antre',
      subtitle: 'Pinjam alat langsung tercatat ke database Firestore siswa',
      image:
          'https://images.unsplash.com/photo-1581092921461-eab62e97a780?auto=format&fit=crop&w=800&q=80',
    ),
  ];

  @override
  void initState() {
    super.initState();
    final uid = _authService.currentUser?.uid ?? '';
    _userStream = _firestoreService.streamUserProfile(uid);
    _itemsStream = _firestoreService.streamItems();

    _carouselTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || !_pageCtrl.hasClients) return;
      _pageCtrl.animateToPage(
        (_currentBanner + 1) % _banners.length,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openItemDetail(ItemModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (_) => ItemDetailSheet(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            children: [
              StreamBuilder<UserModel>(
                stream: _userStream,
                builder: (context, snapshot) {
                  final user = snapshot.data;
                  final firstName = (user?.name ?? 'Siswa').split(' ').first;
                  final kelas = user?.kelas ?? 'XI RPL';
                  final foto =
                      user?.foto ??
                      'https://ui-avatars.com/api/?name=Siswa&background=4F46E5&color=FFFFFF';

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              foto,
                              width: 38,
                              height: 38,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Halo, $firstName',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.slate900,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.techIndigo.withOpacity(
                                        0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      kelas,
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.techIndigo,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Text(
                                    _authService.currentUser?.email ?? '',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.slate500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: widget.onNavigateToInventaris,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.slate200),
                          ),
                          child: const Icon(
                            Icons.tune_rounded,
                            size: 18,
                            color: AppColors.techIndigo,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _searchCtrl,
                onChanged: (val) => setState(() => _searchQuery = val),
                style: const TextStyle(fontSize: 12, color: AppColors.slate800),
                decoration: InputDecoration(
                  hintText: 'Cari alat lab atau kode seri...',
                  hintStyle: const TextStyle(
                    fontSize: 12,
                    color: AppColors.slate400,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    size: 18,
                    color: AppColors.techIndigo,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.close,
                            size: 16,
                            color: AppColors.slate400,
                          ),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.slate200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.techIndigo),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<ItemModel>>(
            stream: _itemsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final allItems = snapshot.data ?? [];
              final searched = allItems
                  .where(
                    (i) =>
                        i.itemName.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ) ||
                        i.code.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ),
                  )
                  .toList();

              final byCategory = allItems.where((i) {
                final matchCat = i.category == _selectedCategory;
                final matchSub =
                    _selectedCategoryStatus == 'Semua' ||
                    i.status == _selectedCategoryStatus;
                return matchCat && matchSub;
              }).toList();

              final byStatus = allItems
                  .where((i) => i.status == _selectedStatus)
                  .toList();

              return ListView(
                padding: const EdgeInsets.only(bottom: 96),
                children: [
                  _buildCarouselBanner(),
                  const SizedBox(height: 20),
                  _buildSectionHeader(
                    'Semua Data (${searched.length})',
                    AppColors.techIndigo,
                    trailing: 'SHOWCASE',
                  ),
                  const SizedBox(height: 8),
                  if (searched.isEmpty)
                    _buildEmptyBox('Tidak ada peralatan yang cocok.')
                  else
                    SizedBox(
                      height: 165,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: searched.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (_, idx) => ShowcaseItemCard(
                          item: searched[idx],
                          onTap: () => _openItemDetail(searched[idx]),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  _buildSectionHeader(
                    'Kategori Peralatan',
                    AppColors.techCyan,
                    trailing: '${byCategory.length} ITEM',
                    trailingColor: AppColors.techIndigo,
                  ),
                  const SizedBox(height: 8),
                  _buildCategoryPills(),
                  const SizedBox(height: 8),
                  _buildCategorySubStatusFilter(),
                  const SizedBox(height: 10),
                  if (byCategory.isEmpty)
                    _buildEmptyBox(
                      'Tidak ada alat $_selectedCategory berstatus $_selectedCategoryStatus.',
                    )
                  else
                    SizedBox(
                      height: 186,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: byCategory.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (_, idx) => BentoCategoryCard(
                          item: byCategory[idx],
                          onTap: () => _openItemDetail(byCategory[idx]),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  _buildStatusHeader(),
                  const SizedBox(height: 8),
                  if (byStatus.isEmpty)
                    _buildEmptyBox('Tidak ada alat berstatus $_selectedStatus.')
                  else
                    SizedBox(
                      height: 88,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: byStatus.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (_, idx) => StatusTicketCard(
                          item: byStatus[idx],
                          onTap: () => _openItemDetail(byStatus[idx]),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCarouselBanner() {
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: PageView.builder(
            controller: _pageCtrl,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (idx) => setState(() => _currentBanner = idx),
            itemCount: _banners.length,
            itemBuilder: (_, idx) => _bannerCard(_banners[idx]),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (i) {
            final active = i == _currentBanner;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active ? AppColors.techIndigo : AppColors.slate200,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _bannerCard(BannerItem b) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              b.image,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: const Color(0xFF1E1B4B)),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1E1B4B).withOpacity(0.92),
                    const Color(0xFF312E81).withOpacity(0.72),
                    Colors.transparent,
                  ],
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      b.tag,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFA5F3FC),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 200,
                    child: Text(
                      b.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 190,
                    child: Text(
                      b.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFFE0E7FF),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPills() {
    return SizedBox(
      height: 30,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: ['Jaringan', 'Hardware', 'IoT', 'Multimedia'].map((cat) {
          final active = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: active ? AppColors.techIndigo : Colors.white,
                  borderRadius: BorderRadius.circular(99),
                  border: active ? null : Border.all(color: AppColors.slate200),
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: active ? Colors.white : AppColors.slate600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategorySubStatusFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            'Filter:',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              color: AppColors.slate400,
            ),
          ),
          const SizedBox(width: 6),
          ...['Semua', 'Available', 'Borrowed'].map((subSt) {
            final active = _selectedCategoryStatus == subSt;
            Color activeBg = AppColors.slate800;
            if (active && subSt == 'Available') activeBg = AppColors.emerald;
            if (active && subSt == 'Borrowed') activeBg = AppColors.amber;

            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: GestureDetector(
                onTap: () => setState(() => _selectedCategoryStatus = subSt),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: active ? activeBg : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: active
                        ? null
                        : Border.all(color: AppColors.slate200),
                  ),
                  child: Text(
                    subSt,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: active ? Colors.white : AppColors.slate500,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatusHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 14,
                decoration: BoxDecoration(
                  color: AppColors.emerald,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Status Ketersediaan',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate900,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.slate200),
            ),
            child: Row(
              children: ['Available', 'Borrowed'].map((st) {
                final active = _selectedStatus == st;
                return GestureDetector(
                  onTap: () => setState(() => _selectedStatus = st),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: active
                          ? (st == 'Available'
                                ? AppColors.emerald
                                : AppColors.amber)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      st,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: active ? Colors.white : AppColors.slate500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    Color dotColor, {
    String? trailing,
    Color? trailingColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 14,
                decoration: BoxDecoration(
                  color: dotColor,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate900,
                ),
              ),
            ],
          ),
          if (trailing != null)
            Text(
              trailing,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: trailingColor ?? AppColors.slate400,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyBox(String msg) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
      ),
      alignment: Alignment.center,
      child: Text(
        msg,
        style: const TextStyle(fontSize: 12, color: AppColors.slate400),
      ),
    );
  }
}