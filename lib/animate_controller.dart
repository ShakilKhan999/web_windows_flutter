import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class GifController extends ChangeNotifier {
  final TickerProvider vsync;
  AnimationController? _animationController;

  GifController({required this.vsync});

  void initialize(Duration duration) {
    _animationController =
        AnimationController(vsync: vsync, duration: duration);
    _animationController!.stop();
  }

  void play() {
    _animationController?.forward();
    notifyListeners();
  }

  void stop() {
    _animationController?.stop();
    notifyListeners();
  }

  void reset() {
    _animationController?.reset();
    notifyListeners();
  }

  AnimationController? get animationController => _animationController;
}
