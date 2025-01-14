import 'dart:io';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:douyin_ringtone/app/models/i_error.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/routes/app_pages.dart';

void main() {
  if (kReleaseMode) {
    var onError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      onError?.call(details);
      reportError(details);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      var details = FlutterErrorDetails(stack: stack, exception: error);
      FlutterError.dumpErrorToConsole(details);
      reportError(details);
      return true;
    };
  }
  runApp(
    GetMaterialApp(
      title: "Application",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF0957DE),
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        textTheme: const TextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          surfaceTintColor: Color(0xFF1E1E1E),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
          elevation: 0,
        ),
      ),
    ),
  );
}

Future<void> reportError(FlutterErrorDetails errorDetails) async {
  if (errorDetails.exception is DioException) return;
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  var androidInfo = await deviceInfo.androidInfo;
  IError error = IError(
    brand: androidInfo.manufacturer,
    version: androidInfo.version.release,
    content: errorDetails.exceptionAsString(),
    platform: Platform.operatingSystem,
    model: androidInfo.model,
    stack: errorDetails.stack.toString(),
    upTime: DateTime.now(),
  );
  try {
    await Dio().post(
      "http://120.46.18.167:3003/log",
      data: error.toJson(),
    );
  } catch (e) {
    debugPrint(e.toString());
  }
}
