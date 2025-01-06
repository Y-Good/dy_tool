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
    return Scaffold(
      backgroundColor: const Color(0xFFf6f6f6),
      appBar: AppBar(
        // backgroundColor: Theme.of(context).primaryColor,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "当前铃声",
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Obx(() {
              return Text(
                ctl.currentRingtone.value,
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              );
            })
          ],
        ),
        actions: [
          IconButton(
            color: Colors.black,
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
          padding: const EdgeInsets.symmetric(vertical: 6),
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
            padding:
                const EdgeInsets.symmetric(horizontal: 12).copyWith(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: CupertinoButton(
                    color: Colors.white,
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
