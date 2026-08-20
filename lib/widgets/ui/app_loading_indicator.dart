import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:invenicum/core/utils/loading_animation.dart';
import 'package:invenicum/providers/preferences_provider.dart';
import 'package:provider/provider.dart';

class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({
    super.key,
    this.size = 40,
    this.color,
    this.strokeWidth = 4,
    this.value,
    this.backgroundColor,
    this.valueColor,
    this.strokeCap,
  });

  final double size;
  final Color? color;
  final double strokeWidth;
  final double? value;
  final Color? backgroundColor;
  final Animation<Color?>? valueColor;
  final StrokeCap? strokeCap;

  @override
  Widget build(BuildContext context) {
    final animation = context.select<PreferencesProvider, LoadingAnimation>(
      (provider) => provider.loadingAnimation,
    );
    final spinnerColor =
        valueColor?.value ?? color ?? Theme.of(context).colorScheme.primary;

    return Semantics(
      liveRegion: true,
      child: SizedBox(
        width: size,
        height: size,
        child: FittedBox(
          fit: BoxFit.contain,
          child: _buildSpinner(animation, spinnerColor),
        ),
      ),
    );
  }

  Widget _buildSpinner(LoadingAnimation animation, Color spinnerColor) {
    if (value != null) {
      return CircularProgressIndicator(
        value: value,
        color: spinnerColor,
        backgroundColor: backgroundColor,
        valueColor: valueColor,
        strokeWidth: strokeWidth,
        strokeCap: strokeCap,
      );
    }

    return switch (animation) {
      LoadingAnimation.rotatingPlain => SpinKitRotatingPlain(
        color: spinnerColor,
        size: size,
      ),
      LoadingAnimation.doubleBounce => SpinKitDoubleBounce(
        color: spinnerColor,
        size: size,
      ),
      LoadingAnimation.wave => SpinKitWave(color: spinnerColor, size: size),
      LoadingAnimation.wanderingCubes => SpinKitWanderingCubes(
        color: spinnerColor,
        size: size,
      ),
      LoadingAnimation.fadingFour => SpinKitFadingFour(
        color: spinnerColor,
        size: size,
      ),
      LoadingAnimation.fadingCube => SpinKitFadingCube(
        color: spinnerColor,
        size: size,
      ),
      LoadingAnimation.pulse => SpinKitPulse(color: spinnerColor, size: size),
      LoadingAnimation.threeBounce => SpinKitThreeBounce(
        color: spinnerColor,
        size: size,
      ),
      LoadingAnimation.circle => SpinKitCircle(color: spinnerColor, size: size),
      LoadingAnimation.cubeGrid => SpinKitCubeGrid(
        color: spinnerColor,
        size: size,
      ),
      LoadingAnimation.fadingCircle => SpinKitFadingCircle(
        color: spinnerColor,
        size: size,
      ),
      LoadingAnimation.rotatingCircle => SpinKitRotatingCircle(
        color: spinnerColor,
        size: size,
      ),
      LoadingAnimation.foldingCube => SpinKitFoldingCube(
        color: spinnerColor,
        size: size,
      ),
      LoadingAnimation.pumpingHeart => SpinKitPumpingHeart(
        color: spinnerColor,
        size: size,
      ),
      LoadingAnimation.hourGlass => SpinKitHourGlass(
        color: spinnerColor,
        size: size,
      ),
      LoadingAnimation.pouringHourGlass => SpinKitPouringHourGlass(
        color: spinnerColor,
        size: size,
      ),
      LoadingAnimation.pouringHourGlassRefined =>
        SpinKitPouringHourGlassRefined(color: spinnerColor, size: size),
      LoadingAnimation.fadingGrid => SpinKitFadingGrid(
        color: spinnerColor,
        size: size,
      ),
      LoadingAnimation.ring => SpinKitRing(color: spinnerColor, size: size),
      LoadingAnimation.ripple => SpinKitRipple(color: spinnerColor, size: size),
      LoadingAnimation.spinningCircle => SpinKitSpinningCircle(
        color: spinnerColor,
        size: size,
      ),
      LoadingAnimation.spinningLines => SpinKitSpinningLines(
        color: spinnerColor,
        size: size,
      ),
      LoadingAnimation.squareCircle => SpinKitSquareCircle(
        color: spinnerColor,
        size: size,
      ),
      LoadingAnimation.dualRing => SpinKitDualRing(
        color: spinnerColor,
        size: size,
      ),
      LoadingAnimation.pianoWave => SpinKitPianoWave(
        color: spinnerColor,
        size: size,
      ),
      LoadingAnimation.dancingSquare => SpinKitDancingSquare(
        color: spinnerColor,
        size: size,
      ),
      LoadingAnimation.threeInOut => SpinKitThreeInOut(
        color: spinnerColor,
        size: size,
      ),
      LoadingAnimation.waveSpinner => SpinKitWaveSpinner(
        color: spinnerColor,
        size: size,
      ),
      LoadingAnimation.pulsingGrid => SpinKitPulsingGrid(
        color: spinnerColor,
        size: size,
      ),
      LoadingAnimation.chasingDots => SpinKitChasingDots(
        color: spinnerColor,
        size: size,
      ),
    };
  }
}
