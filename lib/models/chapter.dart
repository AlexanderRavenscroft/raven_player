import 'package:hive_ce/hive.dart';

part 'chapter.g.dart';

@HiveType(typeId: 2)
class Chapter {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String uri;

  @HiveField(2)
  final String? mime;

  @HiveField(3)
  final int? durationMs;

  const Chapter({
    required this.name,
    required this.uri,
    this.mime,
    this.durationMs,
  });

  Duration? get duration =>
      durationMs != null ? Duration(milliseconds: durationMs!) : null;

  Chapter copyWith({String? name, String? uri, String? mime, int? durationMs}) {
    return Chapter(
      name: name ?? this.name,
      uri: uri ?? this.uri,
      mime: mime ?? this.mime,
      durationMs: durationMs ?? this.durationMs,
    );
  }
}
