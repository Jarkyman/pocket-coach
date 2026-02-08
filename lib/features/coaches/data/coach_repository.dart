import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/coach.dart';

class CoachRepository {
  Future<List<Coach>> loadCoaches() async {
    // Simulate network delay for realistic feel
    await Future.delayed(const Duration(milliseconds: 600));
    
    final String response = await rootBundle.loadString('assets/coaches.json');
    final List<dynamic> data = json.decode(response);
    return data.map((json) => Coach.fromJson(json)).toList();
  }

  Future<Coach?> getCoachById(String id) async {
    final coaches = await loadCoaches();
    try {
      return coaches.firstWhere((coach) => coach.id == id);
    } catch (_) {
      return null;
    }
  }
}

final coachRepositoryProvider = Provider<CoachRepository>((ref) {
  return CoachRepository();
});

final coachesProvider = FutureProvider<List<Coach>>((ref) async {
  final repository = ref.watch(coachRepositoryProvider);
  return repository.loadCoaches();
});
