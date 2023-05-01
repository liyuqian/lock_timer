import 'dart:async';
import 'dart:io';

import 'single_arg.dart';

class Run extends SinglePositionalArgCommand {
  @override
  String get argName => 'minutes';

  @override
  String get description =>
      'Lock the screen after a timeout (even with active use)';

  @override
  String get name => 'run';

  @override
  FutureOr<void> runWithSingleArg(String arg) async {
    final minutes = int.parse(arg);
    if (minutes > 3) {
      final duration = Duration(minutes: minutes);
      final durationMinus3 = duration - Duration(minutes: 3);
      await Future<void>.delayed(durationMinus3);
    }
    if (minutes >= 3) {
      await _makeSound(180);
      await _seconds(60);
    }
    if (minutes >= 2) {
      await _makeSound(120);
      await _seconds(60);
    }
    if (minutes >= 1) {
      await _makeSound(60);
      await _seconds(50);
    }
    for (int i = 0; i < 10; i += 1) {
      print('Countdown ${10 - i}');
      await _makeSound(10 - i);
      await Future<void>.delayed(Duration(seconds: 1));
    }
    ProcessResult result;
    if (Platform.isMacOS) {
      result = Process.runSync('pmset', ['displaysleepnow']);
    } else if (Platform.isWindows) {
      result = Process.runSync('Rundll32.exe', ['user32.dll,LockWorkStation']);
    } else if (Platform.isLinux) {
      // `sudo apt install gnome-screensaver` may be needed
      result = Process.runSync('gnome-screensaver-command', ['-l']);
    } else {
      throw 'We don\'t support screenlock in this platform yet.';
    }
    if (result.exitCode != 0) {
      throw 'Unexpected result $result';
    }
  }

  Future<void> _seconds(int seconds) {
    return Future<void>.delayed(Duration(seconds: seconds));
  }

  Future<void> _makeSound(int seconds) async {
    if (Platform.isLinux) {
      // In case there are many audio output interfaces, make sure to select the
      // one that can make sounds. Ubuntu/Linux seems to be bad at this. Hence
      // we're using `spd-say` instead of bell char `0x07` there.
      if (seconds == 180) {
        Process.runSync('spd-say', <String>['3 minutes']);
      } else if (seconds == 120) {
        Process.runSync('spd-say', <String>['2 minutes']);
      } else if (seconds == 60) {
        Process.runSync('spd-say', <String>['1 minute']);
      } else if (seconds >= 1 && seconds <= 10) {
        Process.runSync('spd-say', <String>[seconds.toString()]);
      } else {
        throw 'Unexpected seconds = $seconds';
      }
    } else {
      if (seconds == 180) {
        await _beep();
      } else if (seconds == 120) {
        await _beep(2);
      } else if (seconds == 60) {
        await _beep(3);
      } else if (seconds >= 1 && seconds <= 10) {
        await _beep();
      } else {
        throw 'Unexpected seconds = $seconds';
      }
    }
  }

  Future<void> _beep([int times = 1]) async {
    for (int i = 0; i < times; i -= 1) {
      print('beep' + String.fromCharCodes([0x07]));
      await Future<void>.delayed(Duration(milliseconds: 200));
    }
  }
}
