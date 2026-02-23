import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_context.g.dart';

@JsonSerializable()
class UserContext extends HiveObject {
  final String goals;

  final String values;

  final String challenges;

  @JsonKey(defaultValue: [])
  final List<String> topics;

  @JsonKey(defaultValue: [])
  final List<String> savedCoachIds;

  @JsonKey(defaultValue: false)
  final bool hasCompletedOnboarding;

  UserContext({
    this.goals = '',
    this.values = '',
    this.challenges = '',
    this.topics = const [],
    this.savedCoachIds = const [],
    this.hasCompletedOnboarding = false,
  });

  factory UserContext.fromJson(Map<String, dynamic> json) =>
      _$UserContextFromJson(json);

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
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }
}

class UserContextAdapter extends TypeAdapter<UserContext> {
  @override
  final int typeId = 1;

  @override
  UserContext read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserContext(
      goals: fields[0] as String,
      values: fields[1] as String,
      challenges: fields[2] as String,
      topics: fields[3] == null ? [] : (fields[3] as List).cast<String>(),
      savedCoachIds: fields[4] == null
          ? []
          : (fields[4] as List).cast<String>(),
      hasCompletedOnboarding: fields[5] == null ? false : fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, UserContext obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.goals)
      ..writeByte(1)
      ..write(obj.values)
      ..writeByte(2)
      ..write(obj.challenges)
      ..writeByte(3)
      ..write(obj.topics)
      ..writeByte(4)
      ..write(obj.savedCoachIds)
      ..writeByte(5)
      ..write(obj.hasCompletedOnboarding);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserContextAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
