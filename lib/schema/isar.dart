import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:punch_pal/schema/punch.dart';

late Isar isar;

class IsarInitializer {
  static Future<void> ensureInitialized() async {
    final directory = await getApplicationCacheDirectory();
    isar = await Isar.open([PunchSchema], directory: directory.path);
  }
}
