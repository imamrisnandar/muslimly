class QuranFolder {
  final int? id;
  final String mode; // 'list' or 'mushaf'
  final String name;
  final bool isSystem;
  final String? systemKey; // 'hapalan' | 'bacaan' | null for custom
  final int createdAt;
  final String? serverId;

  const QuranFolder({
    this.id,
    required this.mode,
    required this.name,
    this.isSystem = false,
    this.systemKey,
    required this.createdAt,
    this.serverId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mode': mode,
      'name': name,
      'is_system': isSystem ? 1 : 0,
      'system_key': systemKey,
      'created_at': createdAt,
      'server_id': serverId,
    };
  }

  factory QuranFolder.fromMap(Map<String, dynamic> map) {
    return QuranFolder(
      id: map['id'] as int?,
      mode: map['mode'] as String,
      name: map['name'] as String,
      isSystem: (map['is_system'] as int? ?? 0) == 1,
      systemKey: map['system_key'] as String?,
      createdAt: map['created_at'] as int,
      serverId: map['server_id'] as String?,
    );
  }

  QuranFolder copyWith({String? name, String? serverId}) {
    return QuranFolder(
      id: id,
      mode: mode,
      name: name ?? this.name,
      isSystem: isSystem,
      systemKey: systemKey,
      createdAt: createdAt,
      serverId: serverId ?? this.serverId,
    );
  }
}
