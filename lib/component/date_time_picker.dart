import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<DateTime?> showDateTimePicker(
  BuildContext context, {
  Widget? header,
  DateTime? initialDateTime,
  String? text,
}) async {
  return showModalBottomSheet(
    backgroundColor: Colors.transparent,
    context: context,
    builder: (context) {
      return _ParentData(
        dateTime: initialDateTime,
        child: _Dialog(
          header: header,
          initialDateTime: initialDateTime,
          text: text,
        ),
      );
    },
  );
}

class DefaultDateTimerPickerHeader extends StatelessWidget {
  const DefaultDateTimerPickerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        'Select DateTime',
        style: TextStyle(
          color: color,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Button extends StatelessWidget {
  final void Function()? onTap;
  final String? text;
  const _Button({this.onTap, this.text});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primary = colorScheme.primary;
    final onPrimary = colorScheme.onPrimary;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(48),
          color: primary,
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          child: Text(
            (text ?? 'confirm').toUpperCase(),
            style: TextStyle(
              color: onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _DateTimePickerController extends ChangeNotifier {
  DateTime dateTime = DateTime.now();
  void updateDateTime(DateTime dateTime) {
    this.dateTime = dateTime;
    notifyListeners();
  }
}

class _Dialog extends StatelessWidget {
  final String? text;
  final Widget? header;
  final DateTime? initialDateTime;
  const _Dialog({this.text, this.header, this.initialDateTime});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = colorScheme.surfaceContainer;
    final mediaQuery = MediaQuery.of(context);
    final bottom = mediaQuery.padding.bottom;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: color,
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              header ?? const DefaultDateTimerPickerHeader(),
              const _Picker(),
              const SizedBox(height: 8),
              Builder(builder: (context) {
                return _Button(onTap: () => handleTap(context), text: text);
              })
            ],
          ),
        ),
        SizedBox(height: bottom),
      ],
    );
  }

  void handleTap(BuildContext context) {
    final dateTime = _ParentData.of(context).controller.dateTime;
    Navigator.of(context).pop(dateTime);
  }
}

class _ParentData extends InheritedWidget {
  final controller = _DateTimePickerController();
  _ParentData({required super.child, DateTime? dateTime}) {
    controller.dateTime = dateTime ?? DateTime.now();
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return controller.dateTime !=
        (oldWidget as _ParentData).controller.dateTime;
  }

  static _ParentData of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_ParentData>()!;
  }
}

class _Picker extends StatelessWidget {
  const _Picker();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: Row(
        children: [
          Expanded(
            child: _WheelPicker(
              onChanged: (value) => updateYear(context, value),
              options: getYears(),
              initValue: getYear(context),
            ),
          ),
          Expanded(
            child: _WheelPicker(
              onChanged: (value) => updateDate(context, value),
              options: getDates(int.parse('2024')),
              initValue: getDate(context),
            ),
          ),
          Expanded(
            child: _WheelPicker(
              onChanged: (value) => updateHour(context, value),
              options: getHours(),
              initValue: getHour(context),
            ),
          ),
          Expanded(
            child: _WheelPicker(
              onChanged: (value) => updateMinute(context, value),
              options: getMinutes(),
              initValue: getMinute(context),
            ),
          )
        ],
      ),
    );
  }

  String getDate(BuildContext context) {
    final controller = _ParentData.of(context).controller;
    final initialDateTime = controller.dateTime;
    final time = initialDateTime;
    final month = time.month.toString().padLeft(2, '0');
    final day = time.day.toString().padLeft(2, '0');
    return '$month/$day';
  }

  List<String> getDates(int year) {
    List<String> dates = [];
    DateTime date = DateTime(year, 1, 1);
    while (date.year == year) {
      final month = date.month.toString().padLeft(2, '0');
      final day = date.day.toString().padLeft(2, '0');
      dates.add('$month/$day');
      date = date.add(const Duration(days: 1));
    }
    return dates;
  }

  String getHour(BuildContext context) {
    final controller = _ParentData.of(context).controller;
    final initialDateTime = controller.dateTime;
    final time = initialDateTime;
    return time.hour.toString().padLeft(2, '0');
  }

  List<String> getHours() {
    return List.generate(24, (index) => index.toString().padLeft(2, '0'));
  }

  String getMinute(BuildContext context) {
    final controller = _ParentData.of(context).controller;
    final initialDateTime = controller.dateTime;
    final time = initialDateTime;
    return time.minute.toString().padLeft(2, '0');
  }

  List<String> getMinutes() {
    return List.generate(60, (index) => index.toString().padLeft(2, '0'));
  }

  String getYear(BuildContext context) {
    final controller = _ParentData.of(context).controller;
    final initialDateTime = controller.dateTime;
    final time = initialDateTime;
    return time.year.toString();
  }

  List<String> getYears() {
    final now = DateTime.now();
    return List.generate(5, (index) => (now.year + index).toString());
  }

  void updateDate(BuildContext context, String value) {
    final controller = _ParentData.of(context).controller;
    final dateTime = controller.dateTime;
    final year = dateTime.year;
    final month = int.parse(value.split('/')[0]);
    final day = int.parse(value.split('/')[1]);
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    controller.updateDateTime(DateTime(year, month, day, hour, minute));
  }

  void updateHour(BuildContext context, String value) {
    final controller = _ParentData.of(context).controller;
    final dateTime = controller.dateTime;
    final year = dateTime.year;
    final month = dateTime.month;
    final day = dateTime.day;
    final hour = int.parse(value);
    final minute = dateTime.minute;
    controller.updateDateTime(DateTime(year, month, day, hour, minute));
  }

  void updateMinute(BuildContext context, String value) {
    final controller = _ParentData.of(context).controller;
    final dateTime = controller.dateTime;
    final year = dateTime.year;
    final month = dateTime.month;
    final day = dateTime.day;
    final hour = dateTime.hour;
    final minute = int.parse(value);
    controller.updateDateTime(DateTime(year, month, day, hour, minute));
  }

  void updateYear(BuildContext context, String value) {
    final controller = _ParentData.of(context).controller;
    final dateTime = controller.dateTime;
    final year = int.parse(value);
    final month = dateTime.month;
    final day = dateTime.day;
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    controller.updateDateTime(DateTime(year, month, day, hour, minute));
  }
}

class _PickerTile extends StatelessWidget {
  final _Style style;
  final String text;
  const _PickerTile({required this.style, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: getColor(context),
        fontSize: getFontSize(),
        fontWeight: getFontWeight(),
      ),
    );
  }

  Color getColor(BuildContext context) {
    var color = const Color(0xFF666666);
    if (style == _Style.primary) {
      color = Theme.of(context).colorScheme.primary;
    } else if (style == _Style.secondary) {
      color = const Color(0xFF9E9E9E);
    }
    return color;
  }

  double getFontSize() {
    var fontSize = 12.0;
    if (style == _Style.primary) {
      fontSize = 16.0;
    } else if (style == _Style.secondary) {
      fontSize = 14.0;
    }
    return fontSize;
  }

  FontWeight getFontWeight() {
    var fontWeight = FontWeight.w300;
    if (style == _Style.primary) {
      fontWeight = FontWeight.w600;
    } else if (style == _Style.secondary) {
      fontWeight = FontWeight.w400;
    }
    return fontWeight;
  }
}

enum _Style { primary, secondary, tertiary }

class _WheelPicker extends StatefulWidget {
  final String? initValue;
  final void Function(String)? onChanged;
  final List<String> options;
  const _WheelPicker({
    this.initValue,
    this.onChanged,
    required this.options,
  });

  @override
  State<_WheelPicker> createState() => _WheelPickerState();
}

class _WheelPickerState extends State<_WheelPicker> {
  int selected = 0;
  late FixedExtentScrollController controller;

  @override
  Widget build(BuildContext context) {
    return ListWheelScrollView.useDelegate(
      controller: controller,
      childDelegate: ListWheelChildBuilderDelegate(
        builder: (context, index) {
          return _PickerTile(
            style: getStyle(index),
            text: widget.options[index],
          );
        },
        childCount: widget.options.length,
      ),
      itemExtent: 36,
      onSelectedItemChanged: (value) {
        HapticFeedback.selectionClick();
        setState(() {
          selected = value;
        });
        widget.onChanged?.call(widget.options[value]);
      },
      physics: const FixedExtentScrollPhysics(),
    );
  }

  _Style getStyle(int index) {
    var style = _Style.tertiary;
    if (selected == index) {
      style = _Style.primary;
    } else if (index == selected - 1 || index == selected + 1) {
      style = _Style.secondary;
    }
    return style;
  }

  @override
  void initState() {
    super.initState();
    int index = 0;
    if (widget.initValue != null) {
      index = widget.options.indexOf(widget.initValue!);
    }
    int initialItem = 0;
    if (index != -1) {
      setState(() => selected = index);
      initialItem = index;
    }
    controller = FixedExtentScrollController(initialItem: initialItem);
  }
}
