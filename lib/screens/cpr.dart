import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'dart:developer' as dev;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';

enum PushStatus { keepPushing, pushHard, pushFast, notPushing }

NumberFormat formatter = NumberFormat("00");

class CprProvider extends ChangeNotifier {
  final Stopwatch stopwatch;
  final Stopwatch countSuccessCpr;
  PushStatus _status;
  String currentTime;
  //variable to hold the value of success cpr count
  String currentSuccessCpr;
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
  late final Timer successCounter;

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
    successCounter.cancel();
  }

  CprProvider()
      : _status = PushStatus.notPushing,
        stopwatch = Stopwatch(),
        countSuccessCpr = Stopwatch(),
        currentTime = "00:00",
        currentSuccessCpr = '0',
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

    //Customized timer for success CPR counter
    successCounter = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        final currentSuccess = countSuccessCpr.elapsed;
        final inSeconds = currentSuccess.inSeconds;
        currentSuccessCpr = formatter.format(inSeconds);
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
      //controls the behavior of success cpr timer to only increment when correct
      //cpr execution is achieved
      if (duration > standardDuration) {
        _status = PushStatus.pushFast;
        countSuccessCpr.stop();
      } else if (lastMaxAccleration < standardAcceleration) {
        _status = PushStatus.pushHard;
        countSuccessCpr.stop();
      } else {
        _status = PushStatus.keepPushing;
        countSuccessCpr.start();
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
    countSuccessCpr.start();
    isWatchRunning = true;
    notifyListeners();
  }

  void stopWatch() {
    countSuccessCpr.stop();
    countSuccessCpr.reset();
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
    final isRunning = context.select<CprProvider, bool>(
      (value) => value.isWatchRunning,
    );
    return Scaffold(
      backgroundColor: const Color(0xFFF7ECEC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF7ECEC),
        leading: IconButton(
          onPressed: () {
            if (!isRunning) {
              Get.back();
            } else {
              showDialog(
                  context: context,
                  builder: (context) {
                    return const AlertDialog(
                        icon: Icon(Icons.info, color: Colors.red),
                        title: Text('Note!'),
                        content:
                            Text('In order to exit please stop the timer'));
                  });
            }
          },
          icon: Image.asset('assets/images/icons8-left-96 1.png'),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //const SizedBox(height: 40),
            Container(
              margin: const EdgeInsets.only(left: 30, right: 30),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: const [
                    TimerView(),
                    SizedBox(width: 50),
                    SuccessCount()
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 40,
                right: 40,
                top: 30,
                bottom: 15,
              ),
              child: Image.asset(
                'assets/images/cpr-unscreen.gif',
                fit: BoxFit.cover,
                colorBlendMode: BlendMode.overlay,
              ),
            ),
            const PushStatusText(),
            const SizedBox(height: 10),
            const StartStopButton(),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.only(bottom: 50.0, right: 30),
              child: Align(
                  alignment: Alignment.bottomRight, child: CallEmergency()),
            ),
          ],
        ),
      ),
    );
  }
}

class TimerView extends StatefulWidget {
  const TimerView({Key? key}) : super(key: key);

  @override
  _TimerViewState createState() => _TimerViewState();
}

class _TimerViewState extends State<TimerView> {
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

class SuccessCount extends StatelessWidget {
  const SuccessCount({super.key});

  @override
  Widget build(BuildContext context) {
    final success = context.select<CprProvider, String>(
      (value) => value.currentSuccessCpr,
    );
    return Row(
      children: [
        SizedBox(
          height: 30,
          width: 30,
          child: Image.asset('assets/images/icons8-check-64.png'),
        ),
        Text(
          success,
          style: GoogleFonts.fanwoodText(
            color: const Color(0xFFCD5F5F),
            fontSize: 50,
          ),
        )
      ],
    );
  }
}

class StartStopButton extends StatefulWidget {
  const StartStopButton({Key? key}) : super(key: key);

  @override
  _StartStopButtonState createState() => _StartStopButtonState();
}

class _StartStopButtonState extends State<StatefulWidget> {
  var latitude, longitude;
  late String emergencyID = '';

  Future getuserLocation() async {
    //To check if location service is enabled
    //if disabled, prompt the user to turn it on
    bool isEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isEnabled) {
      //return Future.error('Location service is disabled');
      return await Geolocator.requestPermission();
    }

    //verify or check permissions
    //if permissions are denied re-state checking of permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Permission denied by user');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Unable to share location, permission is permanently denied');
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  void initState() {
    getuserLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isRunning = context.select<CprProvider, bool>(
      (value) => value.isWatchRunning,
    );
    if (!isRunning) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 52, 73, 94)),
        onPressed: () async {
          context.read<CprProvider>().startWatch();
          String useruid = FirebaseAuth.instance.currentUser!.uid;
          Position coordinates = await Geolocator.getCurrentPosition();
          await FirebaseFirestore.instance.collection('emergency').add({
            'latitude': coordinates.latitude,
            'longitude': coordinates.longitude,
            'active': true,
            'used_id': useruid,
          }).then((value) async {
            print('location id: ${value.id}');
            setState(() {
              emergencyID = value.id;
            });
            await FirebaseFirestore.instance
                .collection('emergency')
                .doc(emergencyID)
                .set({'uid': emergencyID}, SetOptions(merge: true));
          });
          print(
              'Emergency Location: ${coordinates.latitude}, ${coordinates.longitude}');
        },
        child: Text(
          'Start',
          style: GoogleFonts.fanwoodText(
            color: Colors.white,
            fontSize: 34,
          ),
        ),
      );
    }
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xffC93542)),
      onPressed: () async {
        context.read<CprProvider>().stopWatch();
        await FirebaseFirestore.instance
            .collection('emergency')
            .doc(emergencyID)
            .set({
          'active': false,
        }, SetOptions(merge: true));
      },
      child: Text(
        'Stop',
        style: GoogleFonts.fanwoodText(
          color: Colors.white,
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

//Emergency Dial that pops up whenever CPR is started
//shown at the bottom right of the screen represented with
//a phone dial icon image
class CallEmergency extends StatelessWidget {
  const CallEmergency({super.key});

  // function that navigates the user outside the app
  // then dials 911 and ready for calling
  dialCall() async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: '911',
    );
    await UrlLauncher.launchUrl(launchUri);
  }

  @override
  Widget build(BuildContext context) {
    final isRunning = context.select<CprProvider, bool>(
      (value) => value.isWatchRunning,
    );
    if (!isRunning) {
      return const SizedBox();
    }
    return InkWell(
      onTap: () {
        dialCall();
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(boxShadow: [
          BoxShadow(offset: Offset.zero, blurRadius: 3, spreadRadius: -1)
        ], shape: BoxShape.circle, color: Colors.lightGreen),
        child: Image.asset('assets/images/icons8-ringer-volume-50.png',
            height: 50, width: 50),
      ),
    );
  }
}
