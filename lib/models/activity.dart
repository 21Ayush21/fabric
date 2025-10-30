class Activity {
  final String id;
  final String name;
  final String category;
  final String location;
  final DateTime startTime;
  final int maxParticipants;
  final int currentParticipants;
  final double distance;
  final String description;

  Activity({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.startTime,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.distance,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'location': location,
    'startTime': startTime.toIso8601String(),
    'maxParticipants': maxParticipants,
    'currentParticipants': currentParticipants,
    'distance': distance,
    'description': description,
  };

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
    id: json['id'] as String,
    name: json['name'] as String,
    category: json['category'] as String,
    location: json['location'] as String,
    startTime: DateTime.parse(json['startTime'] as String),
    maxParticipants: json['maxParticipants'] as int,
    currentParticipants: json['currentParticipants'] as int,
    distance: (json['distance'] as num).toDouble(),
    description: json['description'] as String,
  );

  Activity copyWith({
    String? id,
    String? name,
    String? category,
    String? location,
    DateTime? startTime,
    int? maxParticipants,
    int? currentParticipants,
    double? distance,
    String? description,
  }) {
    return Activity(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      location: location ?? this.location,
      startTime: startTime ?? this.startTime,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      distance: distance ?? this.distance,
      description: description ?? this.description,
    );
  }
}