import "package:base/base.dart";

class Images {
  static String logo() {
    if (AppColors.darkMode()) {
      return "assets/image/vireopos_black.png";
    } else {
      return "assets/image/vireopos_white.png";
    }
  }

  static String logoInverse() {
    if (AppColors.darkMode()) {
      return "assets/image/vireopos_white.png";
    } else {
      return "assets/image/vireopos_black.png";
    }
  }

  static String logo100px() {
    if (AppColors.darkMode()) {
      return "assets/image/vireopos_black_100px.png";
    } else {
      return "assets/image/vireopos_white_100px.png";
    }
  }

  static String logoInverse100px() {
    if (AppColors.darkMode()) {
      return "assets/image/vireopos_white_100px.png";
    } else {
      return "assets/image/vireopos_black_100px.png";
    }
  }

  static String logo50px() {
    if (AppColors.darkMode()) {
      return "assets/image/vireopos_black_50px.png";
    } else {
      return "assets/image/vireopos_white_50px.png";
    }
  }

  static String logoInverse50px() {
    if (AppColors.darkMode()) {
      return "assets/image/vireopos_white_50px.png";
    } else {
      return "assets/image/vireopos_black_50px.png";
    }
  }
}
