import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/context_repository.dart';
import '../domain/user_context.dart';

class ContextController extends StateNotifier<UserContext> {
  final ContextRepository _repository;

  ContextController(this._repository) : super(_repository.getContext() ?? UserContext());

  Future<void> saveContext({
    String? goals,
    String? values,
    String? challenges,
    List<String>? topics,
  }) async {
    final newContext = state.copyWith(
      goals: goals ?? state.goals,
      values: values ?? state.values,
      challenges: challenges ?? state.challenges,
      topics: topics ?? state.topics,
    );
    
    state = newContext;
    await _repository.saveContext(newContext);
  }

  Future<void> toggleSavedCoach(String coachId) async {
    final currentSaved = state.savedCoachIds;
    final List<String> newSaved;
    
    if (currentSaved.contains(coachId)) {
      newSaved = currentSaved.where((id) => id != coachId).toList();
    } else {
      newSaved = [...currentSaved, coachId];
    }

    final newContext = state.copyWith(savedCoachIds: newSaved);
    state = newContext;
    await _repository.saveContext(newContext);
  }

  Future<void> completeOnboarding() async {
    final newContext = state.copyWith(hasCompletedOnboarding: true);
    state = newContext;
    await _repository.saveContext(newContext);
  }
}

final contextControllerProvider = StateNotifierProvider<ContextController, UserContext>((ref) {
  final repo = ref.watch(contextRepositoryProvider);
  return ContextController(repo);
});
