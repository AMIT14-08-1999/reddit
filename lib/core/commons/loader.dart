import 'package:flutter/material.dart';
import 'package:flutter_loading_animation_kit/flutter_loading_animation_kit.dart';

class Loader extends StatelessWidget {
  const Loader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: LoadingAnimationKit.fourCirclePulse(
      circleColor: Colors.white,
      dimension: 48.0,
      turns: 1,
      loopDuration: const Duration(seconds: 1),
      curve: Curves.easeInOutCubic,
    ));
  }
}
