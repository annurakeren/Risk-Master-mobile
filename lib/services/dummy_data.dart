// lib/services/dummy_data.dart
// DATA DUMMY - Ganti dengan API service saat backend sudah siap
import '../models/user.dart';
import '../models/criteria.dart';
import '../models/alternative.dart';
import '../models/assessment.dart';

class DummyData {
  // Users
  static List<User> users = [
    User(id: 1, name: 'Admin Utama', email: 'admin@riskmaster.com', role: 'admin'),
    User(id: 2, name: 'Budi Santoso', email: 'budi@kampus.ac.id', role: 'user'),
    User(id: 3, name: 'Siti Rahma', email: 'siti@kampus.ac.id', role: 'user'),
  ];

  // Criteria
  static List<Criteria> criteria = [
    Criteria(id: 1, name: 'Efektivitas Pengurangan Risiko', description: 'Seberapa efektif mitigasi mengurangi risiko', type: 'benefit', weight: 0.40),
    Criteria(id: 2, name: 'Biaya Implementasi', description: 'Total biaya yang dibutuhkan untuk implementasi', type: 'cost', weight: 0.35),
    Criteria(id: 3, name: 'Kompleksitas Teknis', description: 'Tingkat kesulitan implementasi secara teknis', type: 'cost', weight: 0.25),
  ];

  // Alternatives
  static List<Alternative> alternatives = [
    Alternative(id: 1, name: 'Pemasangan Firewall', description: 'Instalasi dan konfigurasi firewall jaringan', source: 'admin', createdBy: 1),
    Alternative(id: 2, name: 'Enkripsi Total', description: 'Enkripsi end-to-end seluruh data sensitif', source: 'admin', createdBy: 1),
    Alternative(id: 3, name: 'Multi-Factor Authentication', description: 'Penerapan autentikasi berlapis', source: 'admin', createdBy: 1),
    Alternative(id: 4, name: 'Patch Management Rutin', description: 'Update dan patch sistem secara berkala', source: 'user', createdBy: 2),
  ];

  // Assessments
  static List<Assessment> assessments = [
    Assessment(id: 1, userId: 2, title: 'Evaluasi Q1 2026', description: 'Evaluasi risiko semester pertama', status: 'draft'),
    Assessment(id: 2, userId: 3, title: 'Audit Keamanan API', description: 'Fokus pada keamanan endpoint API', status: 'completed'),
  ];

  // Simulasi login - return user jika email & password cocok
  static User? login(String email, String password) {
    // Di dummy ini password apapun diterima asal emailnya ada
    try {
      return users.firstWhere((u) => u.email == email);
    } catch (_) {
      return null;
    }
  }
}
