import 'dart:convert';

class Group {
  String id;
  String name;
  String? profileUrl;

  Group({
    required this.id,
    required this.name,
    this.profileUrl,
  });

  Group copyWith({
    String? id,
    String? name,
    String? profileUrl,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      profileUrl: profileUrl ?? this.profileUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'profileUrl': profileUrl,
    };
  }

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['id'] as String,
      name: map['name'] as String,
      profileUrl: map['profileUrl'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory Group.fromJson(String source) => Group.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Group(id: $id, name: $name, profileUrl: $profileUrl)';

  @override
  bool operator ==(covariant Group other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.name == name &&
      other.profileUrl == profileUrl;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ profileUrl.hashCode;
}
