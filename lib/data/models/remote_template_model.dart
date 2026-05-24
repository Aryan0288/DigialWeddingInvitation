class RemoteTemplateModel {
  final int id;
  final String title;
  final String description;
  final String primaryColorHex;
  final String secondaryColorHex;
  final List<String> bgGradientHex;
  final String bgPatternUrl;
  final String dividerIconUrl;
  final String borderFrameUrl;
  final String fontTitle;
  final String fontBody;

  RemoteTemplateModel({
    required this.id,
    required this.title,
    required this.description,
    required this.primaryColorHex,
    required this.secondaryColorHex,
    required this.bgGradientHex,
    required this.bgPatternUrl,
    required this.dividerIconUrl,
    required this.borderFrameUrl,
    required this.fontTitle,
    required this.fontBody,
  });

  factory RemoteTemplateModel.fromJson(Map<String, dynamic> json) {
    return RemoteTemplateModel(
      id: json['id'] ?? 1,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      primaryColorHex: json['primaryColorHex'] ?? '#FFFFFF',
      secondaryColorHex: json['secondaryColorHex'] ?? '#000000',
      bgGradientHex: List<String>.from(json['bgGradientHex'] ?? []),
      bgPatternUrl: json['bgPatternUrl'] ?? '',
      dividerIconUrl: json['dividerIconUrl'] ?? '',
      borderFrameUrl: json['borderFrameUrl'] ?? '',
      fontTitle: json['fontTitle'] ?? 'Serif',
      fontBody: json['fontBody'] ?? 'Sans-Serif',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'primaryColorHex': primaryColorHex,
      'secondaryColorHex': secondaryColorHex,
      'bgGradientHex': bgGradientHex,
      'bgPatternUrl': bgPatternUrl,
      'dividerIconUrl': dividerIconUrl,
      'borderFrameUrl': borderFrameUrl,
      'fontTitle': fontTitle,
      'fontBody': fontBody,
    };
  }
}
