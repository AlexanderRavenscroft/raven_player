import 'package:hive_ce/hive.dart';
import 'package:raven_player/core/hive/hive_boxes.dart';
import 'package:raven_player/utils/app_logger.dart';

class HiveDebugUtils {
  //* DELETE BOX
  static Future<void> deleteBox<T>(HiveBox box) async {
    Hive.deleteBoxFromDisk(box.name);
    log.w('Deleted box: ${box.name}');
  }
}
