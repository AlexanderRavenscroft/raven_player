import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:raven_player/core/saf/saf.dart';

void main() => runApp(const MaterialApp(home: TestPage()));

class TestPage extends StatefulWidget {
  const TestPage({super.key});
  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final _player = AudioPlayer();
  String _status = 'Idle';
  final List<SafEntry> _books = []; // subfolders
  final List<SafEntry?> _firstAudio = []; // first audio per book

  static const _audioMimes = {
    'audio/mpeg',
    'audio/mp4',
    'audio/x-m4a',
    'audio/m4b',
    'audio/flac',
    'audio/ogg',
    'audio/x-flac',
  };
  static const _audioExts = ['.mp3', '.m4a', '.m4b', '.flac', '.ogg'];

  bool _isAudio(SafEntry e) {
    if (e.isDir) return false;
    if (e.mime != null && _audioMimes.contains(e.mime)) return true;
    final n = e.name?.toLowerCase() ?? '';
    return _audioExts.any(n.endsWith);
  }

  Future<void> _pickAndScan() async {
    setState(() => _status = 'Picking...');
    final tree = await Saf.pickTree();
    if (tree == null) {
      setState(() => _status = 'Cancelled');
      return;
    }

    _books.clear();
    _firstAudio.clear();

    final top = await Saf.listDir(tree);
    for (final entry in top.where((e) => e.isDir)) {
      _books.add(entry);
      final inner = await Saf.listDir(entry.uri);
      final firstAudio = inner.where(_isAudio).toList()
        ..sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
      _firstAudio.add(firstAudio.isEmpty ? null : firstAudio.first);
    }

    setState(() => _status = 'Found ${_books.length} books');
  }

  Future<void> _play(SafEntry e) async {
    try {
      await _player.setAudioSource(AudioSource.uri(Uri.parse(e.uri)));
      await _player.play();
      setState(() => _status = 'Playing: ${e.name}');
    } catch (err) {
      setState(() => _status = 'Error: $err');
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SAF Test')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton(
              onPressed: _pickAndScan,
              child: const Text('Pick Home Folder'),
            ),
          ),
          Padding(padding: const EdgeInsets.all(8), child: Text(_status)),
          Expanded(
            child: ListView.builder(
              itemCount: _books.length,
              itemBuilder: (_, i) {
                final book = _books[i];
                final audio = _firstAudio[i];
                return ListTile(
                  title: Text(book.name ?? '(unnamed)'),
                  subtitle: Text(audio?.name ?? 'No audio'),
                  enabled: audio != null,
                  onTap: audio == null ? null : () => _play(audio),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
