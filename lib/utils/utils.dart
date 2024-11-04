import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Utils {
  Utils._();

  static void loading({String text = "正在处理"}) {
    dismiss();
    Get.dialog(
      Material(
        color: Colors.transparent,
        child: UnconstrainedBox(
          child: Container(
            height: 100,
            constraints: const BoxConstraints(minWidth: 100,maxWidth: 200),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LoadingAnimationWidget.flickr(
                  leftDotColor: const Color(0xFF29dbeb),
                  rightDotColor: const Color(0xFFed4f4d),
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
      barrierColor: Colors.black38,
    );
  }

  static void dismiss() {
    if (Get.isDialogOpen == false) return;
    Get.back();
  }

  static String formatFileSize(int value) {
    if (value < 1024) {
      return "${value}B";
    } else if (value < 1024 * 1024) {
      return "${(value / 1024).toStringAsFixed(0)}KB";
    } else {
      return "${(value / 1024 / 1024).toStringAsFixed(0)}MB";
    }
  }

  static String formatTime(DateTime time) {
    return "${time.year}年${time.month}月${time.day}日";
  }

  static void showToast(String msg) {
    dismiss();
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
    );
  }

  /// 提取字符串中的URL
  static String? extractUrl(String text) {
    final urlStart = text.indexOf('https://');
    if (urlStart == -1) return null;

    final end = text.indexOf(' ', urlStart);
    final endIndex = end == -1 ? text.length : end;

    return text.substring(urlStart, endIndex);
  }
}
