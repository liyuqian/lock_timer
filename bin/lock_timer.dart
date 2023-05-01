import 'package:args/command_runner.dart';
import 'package:lock_timer/run.dart';

void main(List<String> args) {
  final CommandRunner<void> runner = CommandRunner<void>(
    'lock_timer',
    'Lock the screen after a timeout (even with active use)',
  );
  runner.addCommand(Run());
  runner.run(args);
}
