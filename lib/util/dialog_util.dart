import 'package:flutter/material.dart';

class DialogUtil {
  static Future<void> openBottomSheet(
    BuildContext context,
    Widget sheet,
  ) async {
    await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) => sheet,
    );
  }
}
