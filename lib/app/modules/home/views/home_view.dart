import 'package:douyin_ringtone/app/modules/home/views/play_float.dart';
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
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Theme.of(context).primaryColor,
        title: const Text('铃声'),
        actions: [
          IconButton(
            color: isDark ? Colors.white : Colors.black,
            icon: const Icon(Icons.refresh),
            onPressed: () => ctl.readFolderFiles(true),
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
                key: ValueKey(item.name),
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
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: PlayFloat(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12).copyWith(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: CupertinoButton(
                    color: const Color(0xFFefefef),
                    borderRadius: const BorderRadius.all(Radius.circular(99)),
                    onPressed: ctl.onImport,
                    child: Text(
                      "导入",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CupertinoButton(
                    color: Theme.of(context).primaryColor,
                    borderRadius: const BorderRadius.all(Radius.circular(99)),
                    onPressed: ctl.onSetRingtone,
                    child: const Text(
                      "设置",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
