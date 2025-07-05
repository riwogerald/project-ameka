class NumberFormatter {
  static String format(int number) {
    if (number < 1000) {
      return number.toString();
    } else if (number < 1000000) {
      double thousands = number / 1000;
      if (thousands == thousands.toInt()) {
        return '${thousands.toInt()}K';
      } else {
        return '${thousands.toStringAsFixed(1)}K';
      }
    } else if (number < 1000000000) {
      double millions = number / 1000000;
      if (millions == millions.toInt()) {
        return '${millions.toInt()}M';
      } else {
        return '${millions.toStringAsFixed(1)}M';
      }
    } else {
      double billions = number / 1000000000;
      if (billions == billions.toInt()) {
        return '${billions.toInt()}B';
      } else {
        return '${billions.toStringAsFixed(1)}B';
      }
    }
  }
}