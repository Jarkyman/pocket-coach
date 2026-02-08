import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_context.g.dart';

@JsonSerializable()
@HiveType(typeId: 1)
class UserContext extends HiveObject {
  @HiveField(0)
  final String goals;

  @HiveField(1)
  final String values;

  @HiveField(2)
  final String challenges;

  @HiveField(3, defaultValue: [])
  final List<String> topics;

  @HiveField(4, defaultValue: [])
  final List<String> savedCoachIds;

  @HiveField(5, defaultValue: false)
  final bool hasCompletedOnboarding;

  UserContext({
    this.goals = '',
    this.values = '',
    this.challenges = '',
    this.topics = const [],
    this.savedCoachIds = const [],
    this.hasCompletedOnboarding = false,
  });

  factory UserContext.fromJson(Map<String, dynamic> json) => _$UserContextFromJson(json);

  Map<String, dynamic> toJson() => _$UserContextToJson(this);

  UserContext copyWith({
    String? goals,
    String? values,
    String? challenges,
    List<String>? topics,
    List<String>? savedCoachIds,
    bool? hasCompletedOnboarding,
  }) {
    return UserContext(
      goals: goals ?? this.goals,
      values: values ?? this.values,
      challenges: challenges ?? this.challenges,
      topics: topics ?? this.topics,
      savedCoachIds: savedCoachIds ?? this.savedCoachIds,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }
}
