import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:puc/utils/constants.dart';
import 'package:puc/utils/mylogoalert.dart';

/// Global API helper — single Dio instance, automatic loader & error dialogs.
///
/// • Only 200 / 201 responses are returned to the caller.
/// • All other status codes show the API error message in an alert dialog and return `null`.
/// • [DioException]s show "Something went wrong" in an alert dialog and return `null`.
class ApiHelper {
  ApiHelper._();

  // ───────────────────────── Dio setup ─────────────────────────

  static final Dio _dio = _createDio();

  static Dio _createDio() {
    final dio = Dio(BaseOptions(
      baseUrl: kAPIBaseURL,
      connectTimeout: const Duration(milliseconds: 8000),
      receiveTimeout: const Duration(milliseconds: 8000),
    ));

    dio.interceptors
        .add(LogInterceptor(requestBody: true, responseBody: true));

    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };

    return dio;
  }

  // ───────────────────────── Public API ─────────────────────────

  /// Performs a **GET** request.
  ///
  /// Returns [Response] on 200/201, otherwise shows an error alert and returns `null`.
  static Future<Response?> get(
    BuildContext context,
    String url, {
    bool requiresAuth = true,
    bool showLoader = true,
  }) async {
    return _execute(
      context,
      showLoader: showLoader,
      request: () {
        _applyAuth(requiresAuth);
        return _dio.get(url);
      },
    );
  }

  /// Performs a **POST** request with a JSON body.
  ///
  /// Returns [Response] on 200/201, otherwise shows an error alert and returns `null`.
  static Future<Response?> post(
    BuildContext context,
    String url, {
    required Map<String, dynamic> data,
    bool requiresAuth = true,
    bool showLoader = true,
  }) async {
    return _execute(
      context,
      showLoader: showLoader,
      request: () {
        _applyAuth(requiresAuth);
        return _dio.post(url, data: data);
      },
    );
  }

  /// Performs a **POST** request with [FormData] (multipart).
  ///
  /// Returns [Response] on 200/201, otherwise shows an error alert and returns `null`.
  static Future<Response?> postMultipart(
    BuildContext context,
    String url, {
    required FormData data,
    bool requiresAuth = true,
    bool showLoader = true,
  }) async {
    return _execute(
      context,
      showLoader: showLoader,
      request: () {
        _applyAuth(requiresAuth);
        return _dio.post(url, data: data);
      },
    );
  }

  // ───────────────────────── Internals ─────────────────────────

  /// Core execution wrapper — shows/hides loader, handles status codes & exceptions.
  static Future<Response?> _execute(
    BuildContext context, {
    required bool showLoader,
    required Future<Response> Function() request,
  }) async {
    if (showLoader) _showLoader(context);

    try {
      final response = await request();

      if (showLoader) _hideLoader(context);

      return _handleResponse(context, response);
    } on DioException catch (e) {
      if (showLoader) _hideLoader(context);
      _handleError(context, e);
      return null;
    } catch (e) {
      if (showLoader) _hideLoader(context);
      _handleError(context, e);
      return null;
    }
  }

  /// Injects the Bearer token when required.
  static void _applyAuth(bool requiresAuth) {
    if (requiresAuth && glbAuthToken.isNotEmpty) {
      _dio.options.headers["Authorization"] = "Bearer $glbAuthToken";
    } else {
      _dio.options.headers.remove("Authorization");
    }
  }

  /// Returns the [Response] for 200/201; shows an error alert otherwise.
  static Response? _handleResponse(BuildContext context, Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response;
    }

    final String message =
        response.data?["message"] ?? "Something went wrong";
    myLogoAlert(
      context: context,
      message: message,
      navigateEnabled: false,
      route: '',
    );
    return null;
  }

  /// Shows an error alert for exceptions.
  static void _handleError(BuildContext context, dynamic e) {
    String message = "Something went wrong";

    if (e is DioException &&
        e.response != null &&
        e.response?.data != null) {
      message = e.response?.data["message"] ?? message;
    }

    myLogoAlert(
      context: context,
      message: message,
      navigateEnabled: false,
      route: '',
    );
  }

  // ───────────────────────── Loader ─────────────────────────

  /// Full-screen semi-transparent loader overlay.
  static void _showLoader(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Container(
        color: Colors.black.withOpacity(0.5),
        child: const Center(
          child: CircularProgressIndicator(color: kColorWhite),
        ),
      ),
    );
  }

  /// Dismisses the loader dialog.
  static void _hideLoader(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}
