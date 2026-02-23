import 'package:hive/hive.dart';

class Conversation extends HiveObject {
  final String id;
  final String coachId;
  final DateTime startTime;
  final String? lastMessage;
  final DateTime lastUpdated;

  Conversation({
    required this.id,
    required this.coachId,
    required this.startTime,
    this.lastMessage,
    required this.lastUpdated,
  });

  Conversation copyWith({String? lastMessage, DateTime? lastUpdated}) {
    return Conversation(
      id: id,
      coachId: coachId,
      startTime: startTime,
      lastMessage: lastMessage ?? this.lastMessage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class ConversationAdapter extends TypeAdapter<Conversation> {
  @override
  final int typeId = 3;

  @override
  Conversation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Conversation(
      id: fields[0] as String,
      coachId: fields[1] as String,
      startTime: fields[2] as DateTime,
      lastMessage: fields[3] as String?,
      lastUpdated: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Conversation obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.coachId)
      ..writeByte(2)
      ..write(obj.startTime)
      ..writeByte(3)
      ..write(obj.lastMessage)
      ..writeByte(4)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
