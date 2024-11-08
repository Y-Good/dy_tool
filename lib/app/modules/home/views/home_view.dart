import 'package:douyin_ringtone/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../controllers/home_controller.dart';
import './ringtone_cell.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctl = Get.find<HomeController>();
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Theme.of(context).primaryColor,
        title: const Text('铃声'),
        actions: [
          IconButton(
            color:Get.isDarkMode ? Colors.white : Colors.black,
            icon: const Icon(Icons.refresh),
            // onPressed: () => ctl.readFolderFiles(true),
            onPressed: () => Utils.showToast("正在解析"),
          ),
        ],
      ),
      body: Obx(() {
        if (ctl.refreshing.value) {
          return Center(
            child: LoadingAnimationWidget.flickr(
              leftDotColor: const Color(0xFF29dbeb),
              rightDotColor: const Color(0xFFed4f4d),
              size: 32,
            ),
          );
        }
        if (ctl.datas.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/noData.png",
                  width: 200,
                ),
                const SizedBox(height: 16),
                const Text("暂无数据"),
              ],
            ),
          );
        }
        return ListView.builder(
          itemBuilder: (ctx, idx) {
            var item = ctl.datas[idx];
            return Obx(() {
              return RingtoneCell(
                selected: item == ctl.selectFile.value,
                item: item,
                onTap: () => ctl.onSelected(item),
                onLongPress: () => ctl.onOption(ctx, item),
              );
            });
          },
          itemCount: ctl.datas.length,
        );
      }),
      bottomNavigationBar: CupertinoButton(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.zero,
        onPressed: ctl.onImport,
        child: const Text(
          "导入",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
