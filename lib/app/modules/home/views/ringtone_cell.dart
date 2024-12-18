import 'package:douyin_ringtone/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/i_file.dart';
import '../controllers/home_controller.dart';

class RingtoneCell extends StatelessWidget {
  const RingtoneCell({
    super.key,
    required this.selected,
    required this.item,
    this.onTap,
    this.onLongPress,
    this.duration = 0,
    this.currentTime = 0,
  });

  final bool selected;
  final IFile item;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  final int duration;
  final int currentTime;

  @override
  Widget build(BuildContext context) {
    final ctl = Get.find<HomeController>();
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onLongPress: onLongPress,
      onTap: onTap,
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            color: selected
                ? Get.isDarkMode
                    ? const Color(0xFF191919)
                    : Theme.of(context).primaryColor.withOpacity(.05)
                : null,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${Utils.formatFileSize(item.size)}\t|\t${Utils.formatTime(item.time)}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                CustomPaint(
                  size: const Size(20, 20),
                  painter: CustomRadio(
                    selected: selected,
                    animation: ctl.animation,
                  ),
                ),
              ],
            ),
          ),
          if (duration != 0 && selected)
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: 4,
              width: (currentTime / duration) * Get.width,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
        ],
      ),
    );
  }
}

class CustomRadio extends CustomPainter {
  final bool selected;
  final Animation<double> animation;

  const CustomRadio({
    required this.selected,
    required this.animation,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    Paint selectPaint = Paint()
      ..color = const Color(0xFF3670f7)
      ..style = PaintingStyle.fill;

    Paint unSelectPaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      selected ? size.width / 2 * animation.value : size.width / 2,
      selected ? selectPaint : unSelectPaint,
    );
    if (selected) {
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        size.width / 6,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(CustomRadio oldDelegate) {
    return oldDelegate.selected != selected;
  }
}
