import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/routes/app_pages.dart';

void main() {
  runApp(
    GetMaterialApp(
      title: "Application",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      theme: ThemeData(
        primaryColor: const Color(0xFF3670f7),
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        primaryColor: const Color(0xFF3670f7),
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          surfaceTintColor: Colors.black,
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
