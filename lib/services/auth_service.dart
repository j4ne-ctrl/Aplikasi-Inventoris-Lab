import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  // Login siswa
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Login admin: wajib punya role 'admin' di users/{uid}
  Future<void> loginAdmin({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final doc = await _db.collection('users').doc(cred.user!.uid).get();
    if (doc.data()?['role'] != 'admin') {
      await _auth.signOut();
      throw FirebaseAuthException(
        code: 'not-admin',
        message: 'Akun ini bukan admin',
      );
    }
  }

  // Register siswa (role selalu 'siswa')
  Future<UserCredential> register({
    required String name,
    required String kelas,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;
    final defaultAvatar =
        'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=0D9488&color=FFFFFF&bold=true&size=128';

    final userModel = UserModel(
      userId: uid,
      name: name,
      email: email,
      kelas: kelas,
      foto: defaultAvatar,
      role: 'siswa',
    );

    await _db.collection('users').doc(uid).set(userModel.toMap());
    return credential;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
