import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

class Ringtone {
  static const MethodChannel _channel = MethodChannel('ringtone_set');

  static Future<bool> get isWriteSettingsGranted async {
    final bool granted = await _channel.invokeMethod('isWriteGranted');
    return granted;
  }

  static Future<bool> setRingtoneFromFile(File file) async {
    final bool result = await _channel.invokeMethod("setRingtone", {
      "path": file.path,
    });
    return result;
  }

  static Future<String?> getRingtone() async {
    return await _channel.invokeMethod("getRingtone");
  }

  static Future<void> deleteRingtone(File file) async {
    final String fileName = file.path.split("/").last;
    await _channel.invokeMethod("deleteRingtone", {"fileName": fileName});
  }
}
