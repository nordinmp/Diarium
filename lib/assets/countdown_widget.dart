part of asset_library;


class CountdownTimerWidget extends StatefulWidget {
  final int timeLeft;

  const CountdownTimerWidget({super.key, required this.timeLeft});

  @override
  State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  late int _remainingSeconds; // 3 minutes in seconds
  late Timer _timer;

  @override
  void initState() {
    super.initState();
     _remainingSeconds = widget.timeLeft; // 3 minutes in seconds
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer.cancel();
        // Timer has finished, you can perform any action here
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return
      Center(
        child:
        Text(_formatTime(_remainingSeconds),
          style: TextStyle(
            color: Theme.of(context).colorScheme.scrim,
            fontSize: 26,
            fontWeight: FontWeight.normal,
          ),
        ),
      );
  }
}