class RsvpModel {
  final String id;
  final String guestName;
  final int guestsCount;
  final String mealPreference; // Standard, Vegetarian, Vegan
  final bool isAttending;
  final DateTime timestamp;

  RsvpModel({
    required this.id,
    required this.guestName,
    required this.guestsCount,
    required this.mealPreference,
    required this.isAttending,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'guestName': guestName,
      'guestsCount': guestsCount,
      'mealPreference': mealPreference,
      'isAttending': isAttending,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory RsvpModel.fromJson(Map<String, dynamic> json) {
    return RsvpModel(
      id: json['id'] ?? '',
      guestName: json['guestName'] ?? '',
      guestsCount: json['guestsCount'] ?? 1,
      mealPreference: json['mealPreference'] ?? 'Standard',
      isAttending: json['isAttending'] ?? true,
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : DateTime.now(),
    );
  }
}
