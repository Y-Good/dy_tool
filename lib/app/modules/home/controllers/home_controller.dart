import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:douyin_ringtone/app/api/api.dart';
import 'package:douyin_ringtone/app/models/i_file.dart';
import 'package:douyin_ringtone/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:set_ringtone/set_ringtone.dart';

class HomeController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;
  late AppLifecycleListener _listener;
  final Dio dio = Dio();
  final AudioPlayer player = AudioPlayer();
  List<IFile> datas = <IFile>[].obs;
  Rx<IFile> selectFile = IFile("", "", 0, DateTime.now()).obs;
  Rx<bool> refreshing = false.obs;

  @override
  Future<void> onInit() async {
    _listener = AppLifecycleListener(
      onPause: () => player.stop(),
    );
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    animation = CurvedAnimation(parent: controller, curve: Curves.easeInOut);

    try {
      var status = await Permission.storage.status;
      if (status.isGranted) {
        await readFolderFiles();
      } else {
        await Permission.storage.request().then((v) async {
          if (v.isGranted) {
            await readFolderFiles();
          }
        });
      }
    } catch (e) {
      Utils.showToast(e.toString());
    }
    super.onInit();
  }

  /// 设置铃声
  Future<void> onSelected(IFile item) async {
    if (player.state == PlayerState.playing) {
      await player.stop();
    }
    player.play(DeviceFileSource(item.path));
    if (item == selectFile.value) return;
    controller.reset();
    controller.forward();
    // bool isWriteSettingsGranted = await Ringtone.isWriteSettingsGranted;
    // if (!isWriteSettingsGranted) {
    //   Utils.showToast("请先授予权限");
    //   return;
    // }
    bool res = await Ringtone.setRingtoneFromFile(File(item.path));
    if (res) {
      selectFile.value = item;
    } else {
      Utils.showToast("设置失败");
    }
  }

  /// 长按操作项
  void onOption(BuildContext context, IFile item) {
    Get.dialog(
      UnconstrainedBox(
        child: Material(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          color: Colors.white,
          child: InkWell(
            onTap: () => onDeleteFile(item),
            child: Container(
              width: Get.width / 2,
              padding: const EdgeInsets.all(16),
              child: const Text("删除"),
            ),
          ),
        ),
      ),
      barrierColor: Colors.black38,
    );
  }

  /// 删除文件
  void onDeleteFile(IFile item) {
    if (item == selectFile.value) {
      player.stop();
    }
    datas.remove(item);
    if (Get.isDialogOpen == true) Get.back();
    File file = File(item.path);
    file.delete();
  }

  /// 导入文件
  void onImport() async {
    try {
      Utils.loading(text: "正在导入");
      ClipboardData? clipboardData = await Clipboard.getData(
        Clipboard.kTextPlain,
      );
      if (clipboardData?.text == null) {
        throw "剪切板未找到链接";
      }
      String? text = Utils.extractUrl(clipboardData!.text!);
      if (text == null) {
        throw "剪切板未找到链接";
      }
      Utils.loading(text: "正在解析");
      // 获取视频信息
      var response = await dio.get(
        Api.baseUrl + Api.videoData,
        queryParameters: {"url": text, "minimal": false},
      );
      var uri = response.data["data"]?["music"]?["play_url"]?["uri"];
      var title = response.data["data"]?["music"]?["title"];
      Utils.loading(text: "音频：$title");
      if (uri == null) {
        throw "解析失败";
      }
      debugPrint(response.data["data"]?["music"]?["play_url"].toString());
      // 获取文件后缀
      String ext = p.extension(uri);
      if (ext.isEmpty) ext = ".mp3";
      Directory? folderPath = await getDownloadsDirectory();
      if (folderPath == null) return;
      await dio.download(
        uri,
        "${folderPath.path}/${title ?? DateTime.now().millisecondsSinceEpoch}$ext",
        queryParameters: {"url": text, "minimal": false},
      );
      await readFolderFiles(true);
      Utils.showToast("导入成功");
    } catch (e) {
      Utils.showToast(e.toString());
    }
  }

  /// 读取文件夹文件
  Future<void> readFolderFiles([bool isRefresh = false]) async {
    refreshing.value = true;
    if (isRefresh) datas.clear();
    Directory? folderPath = await getDownloadsDirectory();
    if (folderPath == null) return;
    if (!folderPath.existsSync()) {
      folderPath.createSync();
    }
    List<FileSystemEntity> files = folderPath.listSync();
    for (var e in files) {
      if (!e.path.endsWith(".mp3")) {
        continue;
      }
      var item = IFile(
        e.path,
        p.basenameWithoutExtension(e.path),
        e.statSync().size,
        e.statSync().modified,
      );
      datas.add(item);
    }
    if (isRefresh) {
      refreshing.value = false;
      return;
    }
    String? res = await Ringtone.getRingtone();
    if (res == null) {
      Utils.showToast("没有铃声文件");
      refreshing.value = false;
      return;
    }

    int idx = datas.indexWhere(
      (e) => e.name == p.basenameWithoutExtension(res),
    );
    if (!idx.isNegative) {
      selectFile.value = datas[idx];
      controller.forward();
    }
    refreshing.value = false;
  }

  @override
  void onClose() {
    _listener.dispose();
    super.onClose();
  }
}
