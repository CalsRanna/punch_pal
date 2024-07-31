import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'setting.g.dart';

@riverpod
class SettingNotifier extends _$SettingNotifier {
  @override
  bool build() {
    return false;
  }

  void toggle() {
    state = !state;
  }
}
