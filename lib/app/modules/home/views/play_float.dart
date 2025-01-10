import 'dart:async';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:douyin_ringtone/app/models/i_file.dart';
import 'package:douyin_ringtone/utils/event_bus_utils.dart';
import 'package:flutter/material.dart';

class PlayFloat extends StatefulWidget {
  const PlayFloat({super.key});

  @override
  State<PlayFloat> createState() => _PlayFloatState();
}

class _PlayFloatState extends State<PlayFloat> {
  late AppLifecycleListener _listener;
  final AudioPlayer player = AudioPlayer();
  IFile? file;

  // int currentTime = 0;
  int totalTime = 0;
  bool isPlaying = false;

  // 局部刷新定义
  ValueNotifier<int> currentTime = ValueNotifier<int>(0);
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;

  @override
  void initState() {
    _durationSubscription = player.onDurationChanged.listen((duration) {
      totalTime = duration.inSeconds;
      isPlaying = true;
      setState(() {});
    });

    _positionSubscription = player.onPositionChanged.listen((p) {
      currentTime.value = p.inSeconds;
    });

    _playerCompleteSubscription = player.onPlayerComplete.listen((event) {
      totalTime = 0;
      player.state = PlayerState.stopped;
      isPlaying = false;
      setState(() {});
    });

    _listener = AppLifecycleListener(onPause: () {
      player.pause();
      isPlaying = false;
      setState(() {});
    });

    bus.on<PlayEvent>().listen((e) async {
      file = e.file;
      isPlaying = false;
      totalTime = 0;
      currentTime.value = 0;
      setState(() {});
      await player.stop();
      player.play(DeviceFileSource(e.file.path));
    });

    bus.on<DeleteEvent>().listen((e) {
      if (e.file.path == file?.path) {
        player.stop();
        file = null;
        isPlaying = false;
        totalTime = 0;
        currentTime.value = 0;
        setState(() {});
      }
    });
    super.initState();
  }

  void onPlay() {
    if (isPlaying) {
      player.pause();
    } else {
      if (player.state == PlayerState.stopped && file?.path != null) {
        player.play(DeviceFileSource(file!.path));
      } else {
        player.resume();
      }
    }
    isPlaying = !isPlaying;
    setState(() {});
  }

  @override
  void dispose() {
    _listener.dispose();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (file == null) return const SizedBox();
    return TweenAnimationBuilder(
      curve: Curves.easeInOut,
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, t, child) {
        return Transform.translate(
          offset: Offset(0, 60 * (1 - t)),
          child: Opacity(opacity: t, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF596780),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Row(
          children: [
            const SizedBox(width: 24),
            Expanded(
              child: Text(
                file?.name ?? "-",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  height: 1,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onPlay,
              child: ColoredBox(
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  child: SizedBox(
                    width: 26,
                    height: 26,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: ValueListenableBuilder<int>(
                            valueListenable: currentTime,
                            builder: (_, v, ___) {
                              return CircularProgressIndicator(
                                strokeCap: StrokeCap.round,
                                backgroundColor: Colors.white54,
                                color: Colors.white,
                                strokeWidth: 2,
                                value: totalTime == 0 ? 0 : v / totalTime,
                              );
                            },
                          ),
                        ),
                        AnimatedCrossFade(
                          crossFadeState: isPlaying
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                          duration: const Duration(milliseconds: 150),
                          firstChild: const Icon(
                            Icons.pause_rounded,
                            size: 19,
                            color: Colors.white,
                          ),
                          secondChild: const Icon(
                            Icons.play_arrow_rounded,
                            size: 22,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
