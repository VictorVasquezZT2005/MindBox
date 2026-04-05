import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/note.dart';
import '../models/password.dart';
import '../models/reminder.dart';
import '../models/certificate.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Authentication
  Future<UserCredential?> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential?> signUp(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Firestore Collections
  CollectionReference<Map<String, dynamic>> _userRef(String userId) => 
    _db.collection('users').doc(userId).collection('data'); // Placeholder or specific structure

  // Notes
  Stream<List<Note>> getNotes(String userId) {
    return _db.collection('users').doc(userId).collection('notes')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => Note.fromJson({'id': doc.id, ...doc.data()})).toList());
  }

  Future<void> addNote(String userId, Note note) async {
    await _db.collection('users').doc(userId).collection('notes').add(note.toJson());
  }

  Future<void> updateNote(String userId, String noteId, Note note) async {
    await _db.collection('users').doc(userId).collection('notes').doc(noteId).update(note.toJson());
  }

  Future<void> deleteNote(String userId, String noteId) async {
    await _db.collection('users').doc(userId).collection('notes').doc(noteId).delete();
  }

  // Passwords
  Stream<List<Password>> getPasswords(String userId) {
    return _db.collection('users').doc(userId).collection('passwords')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => Password.fromJson({'id': doc.id, ...doc.data()})).toList());
  }

  Future<void> addPassword(String userId, Password password) async {
    await _db.collection('users').doc(userId).collection('passwords').add(password.toJson());
  }

  Future<void> deletePassword(String userId, String passwordId) async {
    await _db.collection('users').doc(userId).collection('passwords').doc(passwordId).delete();
  }

  // Reminders
  Stream<List<Reminder>> getReminders(String userId) {
    return _db.collection('users').doc(userId).collection('reminders')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => Reminder.fromJson({'id': doc.id, ...doc.data()})).toList());
  }

  Future<void> addReminder(String userId, Reminder reminder) async {
    await _db.collection('users').doc(userId).collection('reminders').add(reminder.toJson());
  }

  Future<void> deleteReminder(String userId, String reminderId) async {
    await _db.collection('users').doc(userId).collection('reminders').doc(reminderId).delete();
  }

  // Certificates
  Stream<List<Certificate>> getCertificates(String userId) {
    return _db.collection('users').doc(userId).collection('certificates')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => Certificate.fromJson({'id': doc.id, ...doc.data()})).toList());
  }

  Future<void> addCertificate(String userId, Certificate cert) async {
    await _db.collection('users').doc(userId).collection('certificates').add(cert.toJson());
  }

  Future<void> deleteCertificate(String userId, String certId) async {
    await _db.collection('users').doc(userId).collection('certificates').doc(certId).delete();
  }
}
