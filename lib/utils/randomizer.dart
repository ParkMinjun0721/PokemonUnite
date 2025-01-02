import 'dart:math';

class Randomizer {
  static final Random _random = Random();

  static T getRandomElement<T>(List<T> list) {
    return list[_random.nextInt(list.length)];
  }

  static List<T> shuffleList<T>(List<T> list) {
    return List.from(list)..shuffle(_random);
  }
}
