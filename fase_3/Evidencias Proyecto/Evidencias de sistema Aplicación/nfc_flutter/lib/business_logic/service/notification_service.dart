import 'package:flutter/material.dart';

class NotificationService {
  // Muestra una notificación tipo SnackBar
  static void showSnackBar(BuildContext context, String message,
      {Color backgroundColor = Colors.blue}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  // Muestra una notificación de éxito
  static void showSuccess(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: Colors.green);
  }

  // Muestra una notificación de error
  static void showError(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: Colors.red);
  }

  // Muestra una notificación de advertencia
  static void showWarning(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: Colors.orange);
  }

  static void showInfo(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.blue, // Puedes personalizar el color
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
