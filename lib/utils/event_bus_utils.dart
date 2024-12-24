import 'package:douyin_ringtone/app/models/i_file.dart';
import 'package:event_bus/event_bus.dart';

EventBus bus = EventBus();

class PlayEvent{
  final IFile file;
  PlayEvent(this.file);
}
