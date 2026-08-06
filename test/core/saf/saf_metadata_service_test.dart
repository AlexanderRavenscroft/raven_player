import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raven_player/core/saf/saf_metadata_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('raven/saf');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('maps a successful metadata response', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          expect(call.method, 'getMetadata');
          return <String, Object?>{
            'title': 'Chapter title',
            'artist': 'Author',
            'duration': 1234,
            'cover': null,
          };
        });

    final metadata = await SafMetadataService().getMetadata('chapter-uri');

    expect(metadata.title, 'Chapter title');
    expect(metadata.artist, 'Author');
    expect(metadata.durationMs, 1234);
    expect(metadata.coverBytes, isNull);
  });

  test('propagates native metadata failures instead of returning null', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          throw PlatformException(
            code: 'METADATA_ERROR',
            message: 'Unreadable file',
          );
        });

    await expectLater(
      SafMetadataService().getMetadata('chapter-uri'),
      throwsA(
        isA<PlatformException>().having(
          (error) => error.code,
          'code',
          'METADATA_ERROR',
        ),
      ),
    );
  });

  test('rejects a null native metadata response', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async => null);

    await expectLater(
      SafMetadataService().getMetadata('chapter-uri'),
      throwsA(
        isA<PlatformException>().having(
          (error) => error.code,
          'code',
          'INVALID_METADATA_RESULT',
        ),
      ),
    );
  });

  test('propagates native duration failures instead of returning null', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          throw PlatformException(
            code: 'DURATION_ERROR',
            message: 'Unreadable file',
          );
        });

    await expectLater(
      SafMetadataService().getDurationMs('chapter-uri'),
      throwsA(
        isA<PlatformException>().having(
          (error) => error.code,
          'code',
          'DURATION_ERROR',
        ),
      ),
    );
  });
}
