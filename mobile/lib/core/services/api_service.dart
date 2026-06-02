import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';

  // ==========================================
  // USERS / AUTHENTICATION (Mock Login)
  // ==========================================
  
  // Şimdilik test amaçlı, herhangi bir kullanıcı adı girildiğinde 
  // backend'de yoksa bile varsayılan bir profil döndürebiliriz 
  // ya da basitçe 'u1' gibi bir ID ile giriş yaparız.
  Future<UserModel?> login(String username) async {
    // Gerçekte burada bir /login endpointi olur
    // Şimdilik "u1" ID'si için örnek bir kullanıcı döndürelim
    // veya sadece giriş başarılı varsayalım.
    await Future.delayed(const Duration(seconds: 1)); // Fake network delay
    return UserModel(
      id: username.isEmpty ? 'u1' : username,
      name: username.isEmpty ? 'Test Kullanıcısı' : username,
      email: '$username@example.com',
    );
  }

  // ==========================================
  // GROUPS
  // ==========================================

  Future<List<GroupModel>> getUserGroups(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/groups/user/$userId'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => GroupModel.fromJson(json)).toList();
      } else {
        throw Exception('Gruplar yüklenemedi: ${response.body}');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }

  Future<GroupModel> createGroup({
    required String name,
    String? description,
    required String iconEmoji,
    required String createdById,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/groups'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'description': description,
          'iconEmoji': iconEmoji,
          'createdById': createdById,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return GroupModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Grup oluşturulamadı: ${response.body}');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }

  // Gruba üye ekleme
  Future<void> addMember(String groupId, String userId) async {
    // Backend API'de gruba üye ekleme ucu lazım
    // Şimdilik mock yapalım veya eğer backend'de endpoint varsa çağıralım
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/groups/$groupId/members'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId}),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Üye eklenemedi: ${response.body}');
      }
    } catch (e) {
      // Endpoint yoksa bile şimdilik UI'ın donmasını engellemek için ignore ediyoruz
      print('Üye ekleme hatası (endpoint olmayabilir): $e');
    }
  }

  // ==========================================
  // EXPENSES
  // ==========================================

  Future<List<ExpenseModel>> getGroupExpenses(String groupId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/expenses/group/$groupId'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ExpenseModel.fromJson(json)).toList();
      } else {
        throw Exception('Harcamalar yüklenemedi: ${response.body}');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }

  Future<ExpenseModel> createExpense({
    required String groupId,
    required String paidById,
    required String title,
    required double amount,
    required String category,
    required DateTime date,
    required List<String> splitAmongIds,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/expenses'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'groupId': groupId,
          'paidById': paidById,
          'title': title,
          'amount': amount,
          'category': category,
          'date': date.toIso8601String(),
          'splitAmongIds': splitAmongIds,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return ExpenseModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Harcama oluşturulamadı: ${response.body}');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }
}

// Riverpod için provider
final apiServiceProvider = Provider((ref) => ApiService());
