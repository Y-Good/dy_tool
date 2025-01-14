import 'package:douyin_ringtone/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/i_file.dart';
import '../controllers/home_controller.dart';

class RingtoneCell extends StatefulWidget {
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
  State<RingtoneCell> createState() => _RingtoneCellState();
}

class _RingtoneCellState extends State<RingtoneCell> {
  @override
  Widget build(BuildContext context) {
    final ctl = Get.find<HomeController>();
    return Material(
      // borderRadius: BorderRadius.circular(8),
      // color: const Color(0xFF596780),
      color: const Color(0xFF1E1E1E),
      child: InkWell(
        onLongPress: widget.onLongPress,
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          // padding: const EdgeInsets.all(12),
          // decoration: BoxDecoration(
          //   borderRadius: BorderRadius.circular(8),
          //   // color: Colors.white,
          // ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFE0E9F4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "${Utils.formatFileSize(widget.item.size)}\t|\t${Utils.formatTime(widget.item.time)}",
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFFE0E9F4).withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              CustomPaint(
                size: const Size(20, 20),
                painter: CustomRadio(
                  selected: widget.selected,
                  animation: ctl.animation,
                ),
              ),
            ],
          ),
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
