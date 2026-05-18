import 'dart:io';

import 'package:flutter/services.dart';

Future<void> exitApp() async {
  if (Platform.isAndroid || Platform.isIOS) {
    await SystemNavigator.pop();
    return;
  }

  exit(0);
}

