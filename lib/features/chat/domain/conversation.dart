import 'package:hive/hive.dart';

part 'conversation.g.dart';

@HiveType(typeId: 3)
class Conversation extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String coachId;

  @HiveField(2)
  final DateTime startTime;

  @HiveField(3)
  final String? lastMessage;

  @HiveField(4)
  final DateTime lastUpdated;

  Conversation({
    required this.id,
    required this.coachId,
    required this.startTime,
    this.lastMessage,
    required this.lastUpdated,
  });

  Conversation copyWith({
    String? lastMessage,
    DateTime? lastUpdated,
  }) {
    return Conversation(
      id: id,
      coachId: coachId,
      startTime: startTime,
      lastMessage: lastMessage ?? this.lastMessage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
