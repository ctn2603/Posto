import 'package:mvp_one/utils/network.dart';

enum Flavor {
  dev,
  prod,
}

class F {
  static Flavor? appFlavor;

  static String get name => appFlavor?.name ?? '';

  static String get title {
    switch (appFlavor) {
      case Flavor.dev:
        return 'Posto Dev';
      case Flavor.prod:
        return 'Posto';
      default:
        return 'title';
    }
  }

  static String get baseUri {
    switch (appFlavor) {
      case Flavor.dev:
        return 'http://${Network.ip}:3000';
      case Flavor.prod:
        return 'https://posto-e4bc1.uc.r.appspot.com';
      default:
        return '';
    }
  }

  static String get usersDb {
    switch (appFlavor) {
      case Flavor.dev:
        return 'users_dev';
      case Flavor.prod:
        return 'users';
      default:
        return '';
    }
  }

  static String get profileImagesStorage {
    switch (appFlavor) {
      case Flavor.dev:
        return 'profile_images_dev';
      case Flavor.prod:
        return 'profile_images';
      default:
        return '';
    }
  }

  static String get postImagesStorage {
    switch (appFlavor) {
      case Flavor.dev:
        return 'post_images_dev';
      case Flavor.prod:
        return 'post_images';
      default:
        return '';
    }
  }
}
