import 'package:flutter_test/flutter_test.dart';
import 'package:invenicum/core/utils/loading_animation.dart';
import 'package:invenicum/data/models/user_preferences.dart';

void main() {
  test('unknown loading animation values fall back to rotatingPlain', () {
    expect(
      LoadingAnimation.fromValue('unknown'),
      LoadingAnimation.rotatingPlain,
    );
    expect(LoadingAnimation.fromValue(null), LoadingAnimation.rotatingPlain);
  });

  test('loading animation is serialized using the backend contract', () {
    final preferences = UserPreferences.fromJson({'loadingAnimation': 'wave'});

    expect(preferences.loadingAnimation, LoadingAnimation.wave);
    expect(preferences.toJson()['loadingAnimation'], 'wave');
  });
}
