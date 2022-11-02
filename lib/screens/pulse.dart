import 'dart:async';
import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:else_revamp/backend/bpm.dart';
import 'package:else_revamp/backend/chart.dart';
import 'package:else_revamp/backend/location.dart';
import 'package:else_revamp/backend/sms.dart';
import 'package:else_revamp/backend/sms_location.dart';
import 'package:else_revamp/backend/notify.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wakelock/wakelock.dart';

class PulseRate extends StatefulWidget {
  const PulseRate({Key? key}) : super(key: key);

  @override
  _PulseRateState createState() => _PulseRateState();
}

class _PulseRateState extends State<PulseRate>
    with SingleTickerProviderStateMixin {
  bool _toggled = false;
  CameraController? _controller;
  //final double _alpha = 0.3;
  AnimationController? _animationController;
  double _iconScale = 1;
  int _bpm = 0;
  final int _fs = 30;
  final int _windowLen = 30 * 6;
  CameraImage? _image;
  double? _avg;
  DateTime? _now;
  Timer? _timer;
  String message = '';
  bool _show = false;
  //var address;
  UserLocation locationData = UserLocation();
  List<String> numbers = <String>[];

  List<SensorValue> _data = <SensorValue>[];
  Process skrt = Process();
  String text = 'Start';

  DataBPM xyz = DataBPM();
  @override
  void initState() {
    super.initState();
    //text = 'Start';
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _animationController!.addListener(() {
      setState(() {
        _iconScale = 1.0 + _animationController!.value * 0.4;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _toggled = false;
    _disposeController;
    Wakelock.disable();
    _animationController?.stop();
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xffFFF8F8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xffFFF8F8),
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Image.asset('assets/images/icons8-left-96 1.png')),
      ),
      body: Column(
        children: <Widget>[
          Center(
            child: Stack(
              children: <Widget>[
                Container(
                  //padding: const EdgeInsets.only(top: 75),
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/images/icons8-heart-96 1.png',
                    height: 260,
                    width: 250,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 100),
                  alignment: Alignment.center,
                  //changed ternary operations from _bpm > 30 && _bpm < 150
                  // into _bpm != 0, for testing if bpm changes or updates the ui
                  child: Text(
                    (_bpm != 0 ? _bpm.toString() : "--"),
                    style: GoogleFonts.fanwoodText(
                        color: const Color.fromARGB(255, 52, 73, 94),
                        fontSize: 36),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 140),
                  alignment: Alignment.center,
                  child: Text(
                    'BPM',
                    style: GoogleFonts.fanwoodText(
                        color: const Color.fromARGB(255, 52, 73, 94),
                        fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
          Container(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: () {
                if (_toggled) {
                  _untoggle();
                  Timer.periodic(const Duration(seconds: 60), (timer) {
                    _untoggle(); //_proceed();
                    if (_toggled == false) {
                      timer.cancel();
                    }
                  });
                  setState(() {
                    text = 'Start';
                  });
                } else {
                  _toogle();
                  Timer.periodic(const Duration(seconds: 60), (timer) {
                    _untoggle(); //_proceed();
                    if (_toggled == false) {
                      timer.cancel();
                    }
                    setState(() {
                      text = 'Start';
                    });
                  });
                  setState(() {
                    text = 'Detecting....';
                  });
                }
              },
              child: Text(
                text,
                style: GoogleFonts.fanwoodText(
                    color: const Color.fromARGB(255, 52, 73, 94), fontSize: 35),
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: height / 4.5 - 18,
          width: width + 75,
          color: const Color(0xffFFF8F8),
          child: Chart(_data),
        ),
      ),
    );
  }

  /*void _proceed() {
    _untoggle();
    setState(() {
      _show = true;
    });
  }*/

  void _clearData() {
    _data.clear();
    int now = DateTime.now().millisecondsSinceEpoch;
    for (int i = 0; i < _windowLen; i++) {
      _data.insert(
          0,
          SensorValue(
              DateTime.fromMillisecondsSinceEpoch(now - i * 1000 ~/ _fs), 128));
    }
  }

  void _toogle() {
    _clearData();
    _initController().then((onValue) {
      Wakelock.enable();
      _animationController?.repeat(reverse: true);
      setState(() {
        _toggled = true;
      });
      _initTimer();
      updateBBM();
    });
  }

  void _untoggle() {
    _disposeController();
    Wakelock.disable();
    _animationController?.stop();
    _animationController?.value = 0.0;
    setState(() {
      _toggled = false;
    });
  }

  void _initTimer() {
    _timer = Timer.periodic(Duration(milliseconds: 1000 ~/ _fs), (timer) {
      if (_toggled) {
        if (_image != null) _scanImage(_image!);
      } else {
        timer.cancel();
      }
    });
  }

  void _disposeController() {
    _controller?.dispose();
    _controller = null;
  }

  Future<void> _initController() async {
    try {
      List _cameras = await availableCameras();
      _controller = CameraController(_cameras.first, ResolutionPreset.low);
      await _controller!.initialize();
      Future.delayed(Duration(milliseconds: 100)).then((onValue) {
        _controller!.setFlashMode(FlashMode.torch);
      });
      _controller!.startImageStream((CameraImage image) {
        _image = image;
      });
    } catch (exception) {
      debugPrint(exception.toString());
    }
  }

  void _scanImage(CameraImage image) {
    _now = DateTime.now();
    _avg =
        image.planes.first.bytes.reduce((value, element) => value + element) /
            image.planes.first.bytes.length;
    if (_data.length >= _windowLen) {
      _data.removeAt(0);
    }
    setState(() {
      _data.add(SensorValue(_now!, 255 - _avg!));
    });
  }

  void updateBBM() async {
    // Bear in mind that the method used to calculate the BPM is very rudimentar
    // feel free to improve it :)

    // Since this function doesn't need to be so "exact" regarding the time it executes,
    // I only used the a Future.delay to repeat it from time to time.
    // Ofc you can also use a Timer object to time the callback of this function
    List<SensorValue> _values;
    double _avg;
    int _n;
    double _m;
    double _threshold;
    double _bpm;
    int _counter;
    int _previous;
    while (_toggled) {
      _values = List.from(_data); // create a copy of the current data array
      _avg = 0;
      _n = _values.length;
      _m = 0;
      _values.forEach((SensorValue value) {
        _avg += value.value / _n;
        if (value.value > _m) _m = value.value;
      });
      _threshold = (_m + _avg) / 2;
      _bpm = 0;
      _counter = 0;
      _previous = 0;
      for (int i = 1; i < _n; i++) {
        if (_values[i - 1].value < _threshold &&
            _values[i].value > _threshold) {
          if (_previous != 0) {
            _counter++;
            _bpm += 60 *
                1000 /
                (_values[i].time.millisecondsSinceEpoch - _previous);
          }
          _previous = _values[i].time.millisecondsSinceEpoch;
        }
      }
      if (_counter > 0) {
        _bpm = _bpm / _counter;
        print(_bpm);
        setState(() {
          this._bpm = _bpm
              .toInt(); //((1 - _alpha) * this._bpm + _alpha * _bpm).toInt();
          //Timer.periodic(Duration(seconds: 60), callback);
        });
      }
      await Future.delayed(Duration(
          milliseconds:
              1000 * _windowLen ~/ _fs)); // wait for a new set of _data values
    }
  }
}
