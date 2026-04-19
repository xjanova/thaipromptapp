import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/api/endpoints.dart';
import '../../core/auth/auth_state.dart';
import '../../shared/models/commerce.dart';

class ChatRepository {
  ChatRepository(this._api);
  final ApiClient _api;

  Future<List<ChatMessage>> listMessages(int orderId, {required int currentUserId}) async {
    final res = await _api.get<Map<String, dynamic>>(Api.orderMessages(orderId));
    final items = res['data'] is List ? res['data'] as List : (res['messages'] as List? ?? []);
    return items
        .map((j) => ChatMessage.fromJson(j as Map<String, dynamic>, currentUserId: currentUserId))
        .toList(growable: false);
  }

  Future<ChatMessage> send(int orderId, {required String text, required int currentUserId}) async {
    final res = await _api.post<Map<String, dynamic>>(
      Api.orderMessages(orderId),
      data: {'text': text},
    );
    final data = (res['data'] is Map<String, dynamic>)
        ? res['data'] as Map<String, dynamic>
        : res;
    return ChatMessage.fromJson(data, currentUserId: currentUserId);
  }
}

final chatRepositoryProvider = FutureProvider<ChatRepository>((ref) async {
  final api = await ref.watch(apiClientProvider.future);
  return ChatRepository(api);
});

final chatMessagesProvider = FutureProvider.autoDispose
    .family<List<ChatMessage>, int>((ref, orderId) async {
  final auth = ref.watch(authControllerProvider);
  final userId = auth is AuthAuthenticated ? auth.user.id : -1;
  final repo = await ref.watch(chatRepositoryProvider.future);
  return repo.listMessages(orderId, currentUserId: userId);
});
