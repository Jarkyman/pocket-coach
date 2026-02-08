import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'coach.g.dart';

@JsonSerializable()
class Coach extends Equatable {
  final String id;
  final String name;
  final String oneLiner;
  final String style;
  final String tone;
  final List<String> tags;
  final List<String> method;
  final List<String> rules;
  final List<String> topics;
  final List<String> prompts;
  final Map<String, String> previewExample;

  const Coach({
    required this.id,
    required this.name,
    required this.oneLiner,
    required this.style,
    required this.tone,
    required this.tags,
    required this.method,
    required this.rules,
    this.topics = const [],
    this.prompts = const [],
    required this.previewExample,
  });

  factory Coach.fromJson(Map<String, dynamic> json) => _$CoachFromJson(json);
  Map<String, dynamic> toJson() => _$CoachToJson(this);

  @override
  List<Object?> get props => [
    id,
    name,
    oneLiner,
    style,
    tone,
    tags,
    method,
    rules,
    topics,
    prompts,
    previewExample,
  ];

  String get imagePath => 'assets/coaches/$id.png';
}
