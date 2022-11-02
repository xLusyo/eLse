import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'dart:developer' as dev;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';

enum PushStatus { keepPushing, pushHard, pushFast, notPushing }

NumberFormat formatter = NumberFormat("00");

class CprProvider extends ChangeNotifier {
  final Stopwatch stopwatch;
  PushStatus _status;
  String currentTime;
  int lastRegisteredHalfPush = 0;
  late StreamSubscription _subscription;
  double maxInEpoch = 0;
  double minInEpoch = 0;
  double lastMaxAccleration = 0;
  int count = 0;
  double threshold = 1;
  int minimumRecognizableDuration = 100;
  double x = 0, y = 0, z = 0;
  double g = 9.8;
  Queue<int> timeBetweenHalfPushes = Queue<int>();
  int movingAvgWindow = 5;
  int maximumRecognizableDuration = 2000;
  int standardDuration = 500;
  int standardAcceleration = 5;
  String log = '';
  int timestamp = 0;
  final audioPlayer = AudioPlayer();
  late final Timer audioTimer;
  late final Timer countTimer;

  double get duration =>
      timeBetweenHalfPushes.reduce((value, element) => value + element) /
      timeBetweenHalfPushes.length *
      2;

  @override
  void dispose() {
    super.dispose();
    _subscription.cancel();
    audioTimer.cancel();
    countTimer.cancel();
  }

  CprProvider()
      : _status = PushStatus.notPushing,
        stopwatch = Stopwatch(),
        currentTime = "00:00",
        isWatchRunning = false {
    audioTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      dev.log('Audio fired');
      if (isWatchRunning) {
        switch (_status) {
          case PushStatus.pushFast:
            audioPlayer.play(AssetSource('sounds/push_faster.mp3'));
            break;
          case PushStatus.pushHard:
            audioPlayer.play(AssetSource('sounds/push_harder.mp3'));
            break;
          case PushStatus.keepPushing:
            audioPlayer.play(AssetSource('sounds/keep_pushing.mp3'));
            break;
          default:
        }
      }
    });
    countTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        final currentDuration = stopwatch.elapsed;
        final inMinutes = currentDuration.inMinutes;
        final inSeconds = currentDuration.inSeconds;
        currentTime =
            "${formatter.format(inMinutes)}:${formatter.format(inSeconds % 60)}";
        notifyListeners();
      },
    );
    timeBetweenHalfPushes.addFirst(0);
    _subscription = userAccelerometerEvents.listen((event) {
      dev.log('New acc event, is watch running: $isWatchRunning');
      if (!isWatchRunning) {
        return;
      }
      final newz = event.z;
      timestamp = DateTime.now().millisecondsSinceEpoch;
      final timeFromLastHalfPush = timestamp - lastRegisteredHalfPush;
      if (timeFromLastHalfPush > maximumRecognizableDuration) {
        timeBetweenHalfPushes.clear();
        timeBetweenHalfPushes.add(0);
        lastMaxAccleration = 0;
      }
      if (z * newz < 0) {
        if (maxInEpoch > threshold && minInEpoch < -threshold) {
          final timeFromLastHalfPush = timestamp - lastRegisteredHalfPush;
          if (timeFromLastHalfPush > minimumRecognizableDuration &&
              timeFromLastHalfPush < maximumRecognizableDuration) {
            count++;
            timeBetweenHalfPushes.addFirst(timeFromLastHalfPush);
            lastMaxAccleration = (maxInEpoch - minInEpoch) / 2;
            while (timeBetweenHalfPushes.length > movingAvgWindow) {
              timeBetweenHalfPushes.removeLast();
            }
          } else if (timeFromLastHalfPush > maximumRecognizableDuration) {
            timeBetweenHalfPushes.clear();
            timeBetweenHalfPushes.add(0);
          }
          lastRegisteredHalfPush = timestamp;
        }
        if (newz < 0) {
          minInEpoch = 0;
        } else {
          maxInEpoch = 0;
        }
      }
      maxInEpoch = max(maxInEpoch, newz);
      minInEpoch = min(minInEpoch, newz);
      x = event.x;
      y = event.y;
      z = event.z;
      dev.log('duration: ${duration.toString()}');
      dev.log('last acceleration: ${lastMaxAccleration.toString()}');
      if (duration > standardDuration) {
        _status = PushStatus.pushFast;
        stopwatch.stop();
      } else if (lastMaxAccleration < standardAcceleration) {
        _status = PushStatus.pushHard;
        stopwatch.stop();
      } else {
        _status = PushStatus.keepPushing;
        stopwatch.start();
      }
      notifyListeners();
    });
  }

  bool isWatchRunning;
  PushStatus get status => _status;

  String get pushStatusStr {
    switch (status) {
      case PushStatus.keepPushing:
        return "Keep Pushing";
      case PushStatus.pushFast:
        return "Push Fast";
      case PushStatus.pushHard:
        return "Push Hard";
      default:
        return "";
    }
  }

  void startWatch() {
    stopwatch.start();
    isWatchRunning = true;
    notifyListeners();
  }

  void stopWatch() {
    stopwatch.stop();
    stopwatch.reset();
    isWatchRunning = false;
    _status = PushStatus.notPushing;
    notifyListeners();
  }
}

class Cpr extends StatelessWidget {
  const Cpr({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CprProvider(),
      child: const CprContent(),
    );
  }
}

class CprContent extends StatelessWidget {
  const CprContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7ECEC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF7ECEC),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Image.asset('assets/images/icons8-left-96 1.png'),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          const TimerView(),
          Padding(
            padding: const EdgeInsets.only(
              left: 40,
              right: 40,
              top: 30,
              bottom: 15,
            ),
            child: Image.asset(
              'assets/images/cpr.gif',
              fit: BoxFit.cover,
              colorBlendMode: BlendMode.overlay,
            ),
          ),
          const PushStatusText(),
          const SizedBox(height: 10),
          const StartStopButton(),
        ],
      ),
    );
  }
}

class TimerView extends StatelessWidget {
  const TimerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentTime =
        context.select<CprProvider, String>((v) => v.currentTime);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 30,
          width: 30,
          child: Image.asset('assets/images/stopwatch.png'),
        ),
        const SizedBox(width: 5),
        Text(
          currentTime,
          style: GoogleFonts.fanwoodText(
            color: const Color(0xFFCD5F5F),
            fontSize: 50,
          ),
        )
      ],
    );
  }
}

class StartStopButton extends StatelessWidget {
  const StartStopButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isRunning = context.select<CprProvider, bool>(
      (value) => value.isWatchRunning,
    );
    if (!isRunning) {
      return TextButton(
        onPressed: () => context.read<CprProvider>().startWatch(),
        child: Text(
          'Start',
          style: GoogleFonts.fanwoodText(
            color: const Color.fromARGB(255, 52, 73, 94),
            fontSize: 34,
          ),
        ),
      );
    }
    return TextButton(
      onPressed: () => context.read<CprProvider>().stopWatch(),
      child: Text(
        'Stop',
        style: GoogleFonts.fanwoodText(
          color: const Color(0xFFCD5F5F),
          fontSize: 34,
        ),
      ),
    );
  }
}

class PushStatusText extends StatelessWidget {
  const PushStatusText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isRunning = context.select<CprProvider, bool>(
      (value) => value.isWatchRunning,
    );
    final statusStr = context.select<CprProvider, String>(
      (v) => v.pushStatusStr,
    );
    if (isRunning) {
      return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Text(
          statusStr,
          style: GoogleFonts.fanwoodText(
            color: const Color(0xFF34495E),
            fontSize: 34,
          ),
        ),
      );
    }
    return const SizedBox(height: 0);
  }
}
