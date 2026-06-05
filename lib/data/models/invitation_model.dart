class InvitationModel {
  final String id;
  final String brideName;
  final String groomName;
  final DateTime weddingDate;
  final String weddingTime; // Format: "HH:mm"
  final String venueName;
  final String venueAddress;
  final String personalMessage;
  final int selectedTemplateId;
  final String brideImageUrl;
  final String groomImageUrl;

  InvitationModel({
    required this.id,
    required this.brideName,
    required this.groomName,
    required this.weddingDate,
    required this.weddingTime,
    required this.venueName,
    required this.venueAddress,
    required this.personalMessage,
    required this.selectedTemplateId,
    this.brideImageUrl = '',
    this.groomImageUrl = '',
  });

  // Empty placeholder instance for initial states
  factory InvitationModel.empty() {
    return InvitationModel(
      id: '',
      brideName: '',
      groomName: '',
      weddingDate: DateTime.now(),
      weddingTime: '18:00',
      venueName: '',
      venueAddress: '',
      personalMessage: '',
      selectedTemplateId: 1,
      brideImageUrl: '',
      groomImageUrl: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brideName': brideName,
      'groomName': groomName,
      'weddingDate': weddingDate.toIso8601String(),
      'weddingTime': weddingTime,
      'venueName': venueName,
      'venueAddress': venueAddress,
      'personalMessage': personalMessage,
      'selectedTemplateId': selectedTemplateId,
      'brideImageUrl': brideImageUrl,
      'groomImageUrl': groomImageUrl,
    };
  }

  factory InvitationModel.fromJson(Map<String, dynamic> json) {
    return InvitationModel(
      id: json['id'] ?? '',
      brideName: json['brideName'] ?? '',
      groomName: json['groomName'] ?? '',
      weddingDate: json['weddingDate'] != null 
          ? DateTime.parse(json['weddingDate']) 
          : DateTime.now(),
      weddingTime: json['weddingTime'] ?? '18:00',
      venueName: json['venueName'] ?? '',
      venueAddress: json['venueAddress'] ?? '',
      personalMessage: json['personalMessage'] ?? '',
      selectedTemplateId: json['selectedTemplateId'] ?? 1,
      brideImageUrl: json['brideImageUrl'] ?? '',
      groomImageUrl: json['groomImageUrl'] ?? '',
    );
  }

  InvitationModel copyWith({
    String? id,
    String? brideName,
    String? groomName,
    DateTime? weddingDate,
    String? weddingTime,
    String? venueName,
    String? venueAddress,
    String? personalMessage,
    int? selectedTemplateId,
    String? brideImageUrl,
    String? groomImageUrl,
  }) {
    return InvitationModel(
      id: id ?? this.id,
      brideName: brideName ?? this.brideName,
      groomName: groomName ?? this.groomName,
      weddingDate: weddingDate ?? this.weddingDate,
      weddingTime: weddingTime ?? this.weddingTime,
      venueName: venueName ?? this.venueName,
      venueAddress: venueAddress ?? this.venueAddress,
      personalMessage: personalMessage ?? this.personalMessage,
      selectedTemplateId: selectedTemplateId ?? this.selectedTemplateId,
      brideImageUrl: brideImageUrl ?? this.brideImageUrl,
      groomImageUrl: groomImageUrl ?? this.groomImageUrl,
    );
  }
}
