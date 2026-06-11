class PlaybackPosition {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  const PlaybackPosition({
    required this.position,
    required this.bufferedPosition,
    required this.duration,
  });
}
