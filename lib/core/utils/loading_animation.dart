enum LoadingAnimation {
  rotatingPlain('rotatingPlain'),
  doubleBounce('doubleBounce'),
  wave('wave'),
  wanderingCubes('wanderingCubes'),
  fadingFour('fadingFour'),
  fadingCube('fadingCube'),
  pulse('pulse'),
  chasingDots('chasingDots'),
  threeBounce('threeBounce'),
  circle('circle'),
  cubeGrid('cubeGrid'),
  fadingCircle('fadingCircle'),
  rotatingCircle('rotatingCircle'),
  foldingCube('foldingCube'),
  pumpingHeart('pumpingHeart'),
  hourGlass('hourGlass'),
  pouringHourGlass('pouringHourGlass'),
  pouringHourGlassRefined('pouringHourGlassRefined'),
  fadingGrid('fadingGrid'),
  ring('ring'),
  ripple('ripple'),
  spinningCircle('spinningCircle'),
  spinningLines('spinningLines'),
  squareCircle('squareCircle'),
  dualRing('dualRing'),
  pianoWave('pianoWave'),
  dancingSquare('dancingSquare'),
  threeInOut('threeInOut'),
  waveSpinner('waveSpinner'),
  pulsingGrid('pulsingGrid');

  const LoadingAnimation(this.value);

  final String value;

  static LoadingAnimation fromValue(String? value) {
    return LoadingAnimation.values.firstWhere(
      (animation) => animation.value == value,
      orElse: () => LoadingAnimation.rotatingPlain,
    );
  }
}
