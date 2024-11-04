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
  });

  final bool selected;
  final IFile item;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final ctl = Get.find<HomeController>();
    return InkWell(
      onLongPress: onLongPress,
      onTap: onTap,
      child: Container(
        color:
            selected ? Theme.of(context).primaryColor.withOpacity(.05) : null,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
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
                    style: const TextStyle(fontSize: 16),
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
