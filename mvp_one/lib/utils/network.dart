import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

const String LOCAL_COMPUTER_IP = '';

// Custom error exception for missing ip address
class MissingIpAddressException implements Exception {
  final String? message;

  MissingIpAddressException(this.message);

  @override
  String toString() {
    if (message == null) return "MissingIpAddressException";
    return "MissingIpAddressException: $message";
  }
}

class Network {
  static late String ip;

  static Future<String?> getServerIpAddress() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      if (iosInfo.isPhysicalDevice) {
        if (LOCAL_COMPUTER_IP.isEmpty) {
          throw MissingIpAddressException(
              "Missing local computer IP address. Please set it in network.dart.");
        }
        return LOCAL_COMPUTER_IP;
      } else {
        return '127.0.0.1';
      }
    } else if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.isPhysicalDevice) {
        if (LOCAL_COMPUTER_IP.isEmpty) {
          throw MissingIpAddressException(
              "Missing local computer IP address. Please set it in network.dart.");
        }
        return LOCAL_COMPUTER_IP;
      } else {
        return '10.0.2.2';
      }
    } else {
      return "localhost";
    }
  }

  static Future<void> initialize() async {
    ip = await getServerIpAddress() ?? "";
    if (ip.isEmpty) {
      throw Exception("server ip not found");
    }
  }
}
