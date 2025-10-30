import 'user.dart';
import 'activity.dart';

class ActivityGroup {
  final String id;
  final Activity activity;
  final List<User> participants;
  final DateTime scheduledTime;

  ActivityGroup({
    required this.id,
    required this.activity,
    required this.participants,
    required this.scheduledTime,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'activity': activity.toJson(),
    'participants': participants.map((u) => u.toJson()).toList(),
    'scheduledTime': scheduledTime.toIso8601String(),
  };

  factory ActivityGroup.fromJson(Map<String, dynamic> json) => ActivityGroup(
    id: json['id'] as String,
    activity: Activity.fromJson(json['activity'] as Map<String, dynamic>),
    participants: (json['participants'] as List)
        .map((p) => User.fromJson(p as Map<String, dynamic>))
        .toList(),
    scheduledTime: DateTime.parse(json['scheduledTime'] as String),
  );
}