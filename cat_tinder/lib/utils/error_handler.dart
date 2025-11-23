import 'package:flutter/material.dart';

import 'constants.dart';

class ErrorHandler {
  static void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(AppConstants.errorTitle),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(AppConstants.tryAgain),
            ),
          ],
        );
      },
    );
  }

  static String handleError(dynamic error) {
    if (error is NetworkError) {
      return AppConstants.noConnection;
    }
    return AppConstants.unknownError;
  }
}

class NetworkError implements Exception {
  final String message;
  NetworkError(this.message);
}
