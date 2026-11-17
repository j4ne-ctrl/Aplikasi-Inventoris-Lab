import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/item_model.dart';
import '../models/borrow_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // =========================================================================
  // 1. KOLEKSI USERS (users/{uid})
  // =========================================================================
  Stream<UserModel> streamUserProfile(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return UserModel(
        userId: uid,
        name: 'Siswa RPL',
        email: 'siswa@smk.sch.id',
        kelas: 'XI RPL 1',
        foto: 'https://ui-avatars.com/api/?name=Siswa+RPL&background=4F46E5&color=FFFFFF&bold=true&size=128',
      );
    });
  }

  Future<void> updateUserProfile({
    required String uid,
    required String name,
    required String foto,
  }) async {
    await _db.collection('users').doc(uid).update({
      'name': name,
      'foto': foto,
    });
  }

  // =========================================================================
  // 2. KOLEKSI INVENTARIS (items/{itemId}) - REAL-TIME CRUD
  // =========================================================================
  Stream<List<ItemModel>> streamItems() {
    return _db
        .collection('items')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ItemModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> seedDummyItemsIfEmpty() async {
    final snapshot = await _db.collection('items').get();
    final existingCodes = snapshot.docs.map((d) => d.data()['code']).toSet();

    const imgNet = 'https://images.unsplash.com/photo-1544197150-b99a580bb7a8?auto=format&fit=crop&w=700&q=80';
    const imgNet2 = 'https://images.unsplash.com/photo-1558494949-ef010cbdcc31?auto=format&fit=crop&w=700&q=80';
    const imgIot = 'https://images.unsplash.com/photo-1553406830-ef2513450d76?auto=format&fit=crop&w=700&q=80';
    const imgIot2 = 'https://images.unsplash.com/photo-1518770660439-4636190af475?auto=format&fit=crop&w=700&q=80';
    const imgHw = 'https://images.unsplash.com/photo-1581092160562-40aa08e78837?auto=format&fit=crop&w=700&q=80';
    const imgMul = 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?auto=format&fit=crop&w=700&q=80';

    final dummyItems = [
      // ===================== JARINGAN =====================
      {
        'item_name': 'MikroTik RB951Ui-2HnD Router',
        'category': 'Jaringan',
        'code': 'NET-2026-01',
        'status': 'Available',
        'image': imgNet,
        'spesification': '5x Ethernet 10/100 Mbps, PoE Out Port 5, Wireless 2.4GHz AP, RouterOS Level 4.',
      },
      {
        'item_name': 'Cisco Catalyst 2960 24-Port Switch',
        'category': 'Jaringan',
        'code': 'NET-2026-07',
        'status': 'Borrowed',
        'image': imgNet2,
        'spesification': '24x Fast Ethernet + 2x SFP Gigabit Uplink, Managed Layer-2 VLAN & Trunking.',
      },
      {
        'item_name': 'TP-Link Archer C6 Wireless Router',
        'category': 'Jaringan',
        'code': 'NET-2026-12',
        'status': 'Available',
        'image': imgNet,
        'spesification': 'Dual-band AC1200, 4 antena, 4x Gigabit LAN, MU-MIMO.',
      },
      {
        'item_name': 'Ubiquiti UniFi AP AC Lite',
        'category': 'Jaringan',
        'code': 'NET-2026-13',
        'status': 'Available',
        'image': imgNet2,
        'spesification': 'Access Point dual-band, PoE 802.3af, jangkauan 122 m.',
      },
      {
        'item_name': 'Crimping Tool RJ45 + LAN Tester',
        'category': 'Jaringan',
        'code': 'NET-2026-14',
        'status': 'Available',
        'image': imgNet,
        'spesification': 'Crimper RJ45/RJ11, kabel tester 8 pin, stripper UTP.',
      },

      // ======================== IOT ========================
      {
        'item_name': 'ESP32-S3 DevKit Dual-Core IoT',
        'category': 'IoT',
        'code': 'IOT-2026-04',
        'status': 'Available',
        'image': imgIot,
        'spesification': 'Xtensa LX7 Dual-Core 240MHz, WiFi 802.11 b/g/n + BLE 5.0, USB-C OTG, 44 GPIO.',
      },
      {
        'item_name': 'Arduino Uno R4 WiFi Matrix',
        'category': 'IoT',
        'code': 'IOT-2026-11',
        'status': 'Available',
        'image': imgIot2,
        'spesification': 'Renesas RA4M1 32-bit Arm Cortex-M4, ESP32-S3 WiFi Module, 12x8 LED Matrix Onboard.',
      },
      {
        'item_name': 'Raspberry Pi 5 8GB',
        'category': 'IoT',
        'code': 'IOT-2026-12',
        'status': 'Available',
        'image': imgIot,
        'spesification': 'Quad-core Cortex-A76 2.4GHz, 8GB RAM, PCIe 2.0, WiFi 5.',
      },
      {
        'item_name': 'Sensor Kit 37-in-1 Arduino',
        'category': 'IoT',
        'code': 'IOT-2026-13',
        'status': 'Available',
        'image': imgIot2,
        'spesification': '37 modul sensor: suhu, jarak, gerak, cahaya, suara, dan relay.',
      },
      {
        'item_name': 'NodeMCU ESP8266 V3',
        'category': 'IoT',
        'code': 'IOT-2026-14',
        'status': 'Available',
        'image': imgIot,
        'spesification': 'WiFi 802.11 b/g/n, CH340, 11 GPIO, USB micro.',
      },

      // ===================== HARDWARE =====================
      {
        'item_name': 'Fluke Network Cable Tester Kit',
        'category': 'Hardware',
        'code': 'HRD-2026-09',
        'status': 'Borrowed',
        'image': imgHw,
        'spesification': 'Digital Wiremap RJ45/RJ11, PoE Voltage Detector, Tone Generator & Crimping Pliers.',
      },
      {
        'item_name': 'Digital Multimeter Fluke 117',
        'category': 'Hardware',
        'code': 'HRD-2026-10',
        'status': 'Available',
        'image': imgHw,
        'spesification': 'True RMS, AutoVolt, CAT III 600V, pengukur non-kontak.',
      },
      {
        'item_name': 'Solder Station Digital 60W',
        'category': 'Hardware',
        'code': 'HRD-2026-11',
        'status': 'Available',
        'image': imgHw,
        'spesification': 'Suhu 200-480 C, layar digital, 5 mata solder.',
      },
      {
        'item_name': 'Power Supply DC Variabel 30V 5A',
        'category': 'Hardware',
        'code': 'HRD-2026-12',
        'status': 'Available',
        'image': imgHw,
        'spesification': 'Output 0-30V / 0-5A, proteksi short circuit, layar LED.',
      },

      // ==================== MULTIMEDIA ====================
      {
        'item_name': 'Epson EB-X500 XGA Laser Projector',
        'category': 'Multimedia',
        'code': 'MUL-2026-02',
        'status': 'Available',
        'image': imgMul,
        'spesification': '3600 Lumens Brightness, XGA Resolution, Dual HDMI & VGA, Wireless Projection Ready.',
      },
      {
        'item_name': 'Kamera Mirrorless Sony A6400',
        'category': 'Multimedia',
        'code': 'MUL-2026-03',
        'status': 'Available',
        'image': imgMul,
        'spesification': '24.2MP APS-C, 4K video, autofocus real-time, layar flip.',
      },
      {
        'item_name': 'Tripod Fluid Head Profesional',
        'category': 'Multimedia',
        'code': 'MUL-2026-04',
        'status': 'Available',
        'image': imgMul,
        'spesification': 'Tinggi maks 170 cm, kepala fluid, beban hingga 8 kg.',
      },
      {
        'item_name': 'Microphone Condenser USB',
        'category': 'Multimedia',
        'code': 'MUL-2026-05',
        'status': 'Available',
        'image': imgMul,
        'spesification': 'Cardioid, 24-bit/192kHz, plug and play, pop filter.',
      },
    ];

    final batch = _db.batch();
    var added = 0;
    for (final item in dummyItems) {
      if (existingCodes.contains(item['code'])) continue;
      final docRef = _db.collection('items').doc();
      batch.set(docRef, {
        'item_id': docRef.id,
        ...item,
        'created_at': FieldValue.serverTimestamp(),
      });
      added++;
    }
    if (added > 0) await batch.commit();
  }

  Future<void> addItem({
    required String itemName,
    required String code,
    required String category,
    required String status,
    required String spesification,
    String? image,
  }) async {
    const catImages = {
      'Jaringan': 'https://images.unsplash.com/photo-1544197150-b99a580bb7a8?auto=format&fit=crop&w=700&q=80',
      'IoT': 'https://images.unsplash.com/photo-1553406830-ef2513450d76?auto=format&fit=crop&w=700&q=80',
      'Hardware': 'https://images.unsplash.com/photo-1581092160562-40aa08e78837?auto=format&fit=crop&w=700&q=80',
      'Multimedia': 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?auto=format&fit=crop&w=700&q=80',
    };

    final finalImage = (image != null && image.trim().isNotEmpty)
        ? image.trim()
        : (catImages[category] ?? catImages['IoT']);

    final docRef = _db.collection('items').doc();
    await docRef.set({
      'item_id': docRef.id,
      'item_name': itemName,
      'code': code,
      'category': category,
      'status': status,
      'image': finalImage,
      'spesification': spesification,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateItem({
    required String itemId,
    required String itemName,
    required String code,
    required String category,
    required String status,
    required String spesification,
    String? image,
  }) async {
    // 'status' sengaja tidak ikut di-update: status diatur oleh pinjam/kembali.
    final updateData = <String, dynamic>{
      'item_name': itemName,
      'code': code,
      'category': category,
      'spesification': spesification,
    };

    if (image != null && image.trim().isNotEmpty) {
      updateData['image'] = image.trim();
    }

    await _db.collection('items').doc(itemId).update(updateData);
  }

  Future<void> deleteItem(String itemId) async {
    await _db.collection('items').doc(itemId).delete();
  }

  // =========================================================================
  // 3. SUB-KOLEKSI TRANSAKSI (users/{uid}/borrowings/{borrowId})
  // =========================================================================
  Stream<List<BorrowModel>> streamUserBorrowings(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('borrowings')
        .orderBy('borrow_date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BorrowModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Map<String, dynamic> get _freeFields => {
        'status': 'Available',
        'borrowed_by_uid': FieldValue.delete(),
        'borrowed_by_name': FieldValue.delete(),
        'borrowed_by_kelas': FieldValue.delete(),
        'borrow_date': FieldValue.delete(),
      };

  // Siswa meminjam: aman dari dua orang yang meminjam bersamaan (transaction)
  Future<void> borrowItem({
    required String uid,
    required ItemModel item,
  }) async {
    final userSnap = await _db.collection('users').doc(uid).get();
    final u = userSnap.data() ?? {};
    final itemRef = _db.collection('items').doc(item.itemId);
    final borrowRef =
        _db.collection('users').doc(uid).collection('borrowings').doc();

    await _db.runTransaction((tx) async {
      final fresh = await tx.get(itemRef);
      if ((fresh.data()?['status'] ?? 'Available') != 'Available') {
        throw Exception('Alat sudah dipinjam orang lain');
      }
      tx.update(itemRef, {
        'status': 'Borrowed',
        'borrowed_by_uid': uid,
        'borrowed_by_name': u['name'] ?? '-',
        'borrowed_by_kelas': u['kelas'] ?? '-',
        'borrow_date': FieldValue.serverTimestamp(),
      });
      tx.set(borrowRef, {
        'borrow_id': borrowRef.id,
        'item_id': item.itemId,
        'item_name': item.itemName,
        'borrow_date': FieldValue.serverTimestamp(),
        'return_date': null,
        'status': 'Borrowed',
      });
    });
  }

  // Siswa mengembalikan dari detail alat (mencari catatan peminjamannya sendiri)
  Future<void> returnItem({
    required String uid,
    required ItemModel item,
  }) async {
    final q = await _db
        .collection('users')
        .doc(uid)
        .collection('borrowings')
        .where('item_id', isEqualTo: item.itemId)
        .where('status', isEqualTo: 'Borrowed')
        .limit(1)
        .get();

    final batch = _db.batch();
    batch.update(_db.collection('items').doc(item.itemId), _freeFields);
    if (q.docs.isNotEmpty) {
      batch.update(q.docs.first.reference, {
        'status': 'Returned',
        'return_date': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  // Dipakai tombol "Kembalikan" di halaman Profil (nama dan parameter sama seperti sebelumnya)
  Future<void> returnBorrowedItem({
    required String uid,
    required BorrowModel borrowRecord,
  }) async {
    final batch = _db.batch();
    batch.update(_db.collection('items').doc(borrowRecord.itemId), _freeFields);
    batch.update(
      _db.collection('users').doc(uid).collection('borrowings').doc(borrowRecord.borrowId),
      {
        'status': 'Returned',
        'return_date': FieldValue.serverTimestamp(),
      },
    );
    await batch.commit();
  }
}