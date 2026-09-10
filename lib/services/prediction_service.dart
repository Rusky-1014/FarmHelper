class PredictionService {

  static int argmax(
      List<double> values) {

    int index = 0;

    double maxVal = values[0];

    for (int i = 1;
        i < values.length;
        i++) {

      if (values[i] > maxVal) {
        maxVal = values[i];
        index = i;
      }
    }

    return index;
  }

  static double confidence(
      List<double> values) {

    return values.reduce(
        (a, b) => a > b ? a : b);
  }
}