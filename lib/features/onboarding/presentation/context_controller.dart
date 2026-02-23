import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/context_repository.dart';
import '../domain/user_context.dart';

part 'context_controller.g.dart';

@riverpod
class ContextController extends _$ContextController {
  @override
  UserContext build() {
    final repo = ref.watch(contextRepositoryProvider);
    return repo.getContext() ?? UserContext();
  }

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
    final repo = ref.read(contextRepositoryProvider);
    await repo.saveContext(newContext);
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
    final repo = ref.read(contextRepositoryProvider);
    await repo.saveContext(newContext);
  }

  Future<void> completeOnboarding() async {
    final newContext = state.copyWith(hasCompletedOnboarding: true);
    state = newContext;
    final repo = ref.read(contextRepositoryProvider);
    await repo.saveContext(newContext);
  }
}
