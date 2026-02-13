class Webhook {
  final String id;
  final String url;
  final String name;
  final DateTime createdAt;

  const Webhook({
    required this.id,
    required this.url,
    required this.name,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Webhook.fromJson(Map<String, dynamic> json) {
    return Webhook(
      id: json['id'] as String,
      url: json['url'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Webhook copyWith({
    String? id,
    String? url,
    String? name,
    DateTime? createdAt,
  }) {
    return Webhook(
      id: id ?? this.id,
      url: url ?? this.url,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
