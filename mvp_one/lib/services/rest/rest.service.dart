import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mvp_one/utils/dialogs/error_dialog.dart';
import 'package:mvp_one/utils/global.dart';
import 'package:mvp_one/utils/payloads/request/base_req.dart';

class RestService {
  static Future<http.Response?> get(String uri) async {
    try {
      return http.get(Uri.parse(uri));
    } on SocketException {
      _handleSocketException();
      return null;
    } on Exception catch (error) {
      _handleGeneralException(error);
      return null;
    }
  }

  static Future<http.Response?> patch(String uri, BaseReq payload) async {
    try {
      return http.patch(Uri.parse(uri),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8'
          },
          body: payload.encode());
    } on SocketException {
      _handleSocketException();
      return null;
    } on Exception catch (error) {
      _handleGeneralException(error);
      return null;
    }
  }

  static Future<http.Response?> post(String uri, BaseReq payload) async {
    try {
      return http.post(Uri.parse(uri),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8'
          },
          body: payload.encode());
    } on SocketException {
      _handleSocketException();
      return null;
    } on Exception catch (error) {
      _handleGeneralException(error);
      return null;
    }
  }

  static Future<http.Response?> put(String uri, BaseReq payload) async {
    try {
      return http.put(Uri.parse(uri),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8'
          },
          body: payload.encode());
    } on SocketException {
      _handleSocketException();
      return null;
    } on Exception catch (error) {
      _handleGeneralException(error);
      return null;
    }
  }

  static void _handleGeneralException(error) {
    showDialog(
        context: Global.getSquareNavigatorKey().currentContext!,
        builder: (BuildContext context) {
          return const ErrorDialog(
            title: "Error",
            message: "Failed to connect to server. This might associate "
                "with the internet connection or server problem. Please check "
                "your internet connection or try again later",
            action: "OK",
          );
        });
  }

  static void _handleSocketException() {
    showDialog(
        context: Global.getSquareNavigatorKey().currentContext!,
        builder: (BuildContext context) {
          return const ErrorDialog(
            title: "Network Error",
            message: "Failed to connect to server. This might associate "
                "with the internet connection or server problem. Please check "
                "your internet connection or try again later",
            action: "Try again",
          );
        });
  }
}
