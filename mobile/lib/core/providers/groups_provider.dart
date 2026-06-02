import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

// ─────────────────────────────────────────────────────────────
//  Gruplar Provider
// ─────────────────────────────────────────────────────────────

class GroupsNotifier extends AsyncNotifier<List<GroupModel>> {
  @override
  Future<List<GroupModel>> build() async {
    final user = ref.watch(currentUserProvider);
    if (user == null) return []; // Giriş yapmamışsa boş liste
    
    final apiService = ref.watch(apiServiceProvider);
    return await apiService.getUserGroups(user.id);
  }

  /// Yeni grup oluştur
  Future<void> createGroup({
    required String name,
    String? description,
    required String iconEmoji,
    required List<UserModel> members,
  }) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    
    state = const AsyncValue.loading();
    try {
      final apiService = ref.read(apiServiceProvider);
      // Sadece oluşturuyoruz, backend bize grubu dönecek ama üyeleri de eklememiz lazım
      // Gerçek bir backend'de üyelerle birlikte grup oluşturma ucu olur, ama biz şu an adım adım yapıyoruz.
      final newGroup = await apiService.createGroup(
        name: name,
        description: description,
        iconEmoji: iconEmoji,
        createdById: user.id,
      );
      
      // Tüm üyeleri ekleyelim
      for (final member in members) {
        if (member.id != user.id) {
          await apiService.addMember(newGroup.id, member.id);
        }
      }
      
      // Veriyi yeniden çek (refresh)
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Gruba üye ekle
  Future<void> addMember(String groupId, UserModel user) async {
    // UI optimistic update yapabiliriz ama garantili olması için api'ye gönderip yenilemek daha iyi
    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.addMember(groupId, user.id);
      
      // Mevcut state'i güncelleyelim (Optimistic Update)
      if (state.hasValue) {
        final currentGroups = state.value!;
        final updatedGroups = currentGroups.map((g) {
          if (g.id == groupId && !g.members.any((m) => m.id == user.id)) {
            return GroupModel(
              id: g.id,
              name: g.name,
              description: g.description,
              iconEmoji: g.iconEmoji,
              members: [...g.members, user],
              totalExpenses: g.totalExpenses,
              netBalance: g.netBalance,
            );
          }
          return g;
        }).toList();
        state = AsyncValue.data(updatedGroups);
      }
    } catch (e) {
      // Hata durumunda yeniden yükle
      ref.invalidateSelf();
    }
  }
}

final groupsProvider = AsyncNotifierProvider<GroupsNotifier, List<GroupModel>>(
  () => GroupsNotifier(),
);

// ─────────────────────────────────────────────────────────────
//  Kullanıcı (Kişi Rehberi) Provider
//  (Eğer ileride rehberi backend'den çekmek istersen)
// ─────────────────────────────────────────────────────────────

class ContactsNotifier extends StateNotifier<List<UserModel>> {
  ContactsNotifier() : super([]);

  // Yeni kişi eklendiğinde sadece listeye ekliyoruz, backend'de eklendiyse ona da gitmeli.
  UserModel addContact({required String name, required String email}) {
    final newUser = UserModel(
      id: 'u${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
    );
    state = [...state, newUser];
    return newUser;
  }
}

final contactsProvider = StateNotifierProvider<ContactsNotifier, List<UserModel>>(
  (ref) => ContactsNotifier(),
);
