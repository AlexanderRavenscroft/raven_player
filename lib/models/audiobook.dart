import 'package:hive_ce/hive.dart';
import 'package:raven_player/models/chapter.dart';

part 'audiobook.g.dart';

@HiveType(typeId: 1)
class Audiobook {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? author;

  @HiveField(3)
  final String folderUri;

  @HiveField(4)
  final String? coverPath;

  @HiveField(5)
  final List<Chapter> chapters;

  @HiveField(6)
  final int? totalDurationMs;

  @HiveField(7)
  final int currentChapterIndex;

  @HiveField(8)
  final int currentPositionMs;

  @HiveField(9)
  final bool isRead;

  const Audiobook({
    required this.id,
    required this.title,
    required this.folderUri,
    required this.chapters,
    this.author,
    this.coverPath,
    this.totalDurationMs,
    this.currentChapterIndex = 0,
    this.currentPositionMs = 0,
    this.isRead = false,
  });

  bool get isEnriched => author != null || coverPath != null;
  Duration get currentPosition => Duration(milliseconds: currentPositionMs);
  Duration? get totalDuration {
    final milliseconds = totalDurationMs;
    return milliseconds == null ? null : Duration(milliseconds: milliseconds);
  }

  Audiobook copyWith({
    String? id,
    String? title,
    String? author,
    String? folderUri,
    String? coverPath,
    List<Chapter>? chapters,
    int? totalDurationMs,
    int? currentChapterIndex,
    int? currentPositionMs,
    bool? isRead,
  }) {
    return Audiobook(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      folderUri: folderUri ?? this.folderUri,
      coverPath: coverPath ?? this.coverPath,
      chapters: chapters ?? this.chapters,
      totalDurationMs: totalDurationMs ?? this.totalDurationMs,
      currentChapterIndex: currentChapterIndex ?? this.currentChapterIndex,
      currentPositionMs: currentPositionMs ?? this.currentPositionMs,
      isRead: isRead ?? this.isRead,
    );
  }
}
