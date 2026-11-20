import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class Post extends HiveObject {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String body;
  @HiveField(3)
  final int userId;

  Post({required this.id, required this.title, required this.body, required this.userId});

  factory Post.fromJson(Map<String, dynamic> json) => Post(
    id: json['id'] as int,
    title: json['title'] as String,
    body: json['body'] as String,
    userId: json['userId'] as int,
  );

  // HiveObjects must not be shared between boxes.
  Post copy() => Post(id: id, title: title, body: body, userId: userId);
}

// Hand-written adapter: same typeId and field indices as the section model.
// No code-generation step is required.
class PostAdapter extends TypeAdapter<Post> {
  @override
  final int typeId = 0;

  @override
  Post read(BinaryReader reader) {
    final count = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < count; i++) reader.readByte(): reader.read(),
    };
    return Post(id: fields[0] as int, title: fields[1] as String,
      body: fields[2] as String, userId: fields[3] as int);
  }

  @override
  void write(BinaryWriter writer, Post obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.title)
      ..writeByte(2)..write(obj.body)
      ..writeByte(3)..write(obj.userId);
  }
}
