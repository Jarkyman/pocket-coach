import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../domain/user_context.dart';

class ContextRepository {
  static const String boxName = 'user_context';
  static const String key = 'current_context';

  final Box<UserContext> _box;

  ContextRepository(this._box);

  static Future<ContextRepository> init() async {
    // Register adapter if not already registered (handled in main usually, but checking here)
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserContextAdapter());
    }
    
    final box = await Hive.openBox<UserContext>(boxName);
    return ContextRepository(box);
  }

  Future<void> saveContext(UserContext context) async {
    await _box.put(key, context);
  }

  UserContext? getContext() {
    return _box.get(key);
  }
  
  Stream<UserContext?> watchContext() {
    return _box.watch(key: key).map((event) => event.value as UserContext?);
  }
}

final contextRepositoryProvider = Provider<ContextRepository>((ref) {
  throw UnimplementedError('Provider was not initialized');
});
