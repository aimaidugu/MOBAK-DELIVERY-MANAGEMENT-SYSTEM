import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class NotificationService {
  /// Shows a transient notification at the top of the screen.
  ///
  /// This uses Flushbar for a floating message but falls back to
  /// `ScaffoldMessenger` if anything goes wrong. The message widget is
  /// constrained and wrapped to avoid "A RenderFlex overflowed" errors
  /// (overflow in pixels) when content is long or the viewport is narrow.
  static void showNotificationToast(
    BuildContext context,
    String message,
    String title, [
    NotificationTypes type = NotificationTypes.none,
    Duration duration = const Duration(seconds: 3),
  ]) {
    try {
      final bg = type == NotificationTypes.error
          ? Colors.red
          : type == NotificationTypes.good
              ? Colors.green.shade600
              : Colors.grey.shade900;

      Flushbar(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.all(12),
        borderRadius: BorderRadius.circular(12),
        flushbarPosition: FlushbarPosition.TOP,
        duration: duration,
        backgroundColor: bg,
        isDismissible: true,
        titleText: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          softWrap: true,
        ),
        messageText: LayoutBuilder(builder: (context, constraints) {
          // Ensure long messages wrap and do not cause overflow on small viewports.
          final maxWidth = constraints.maxWidth.clamp(120.0, 800.0);
          return ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
              softWrap: true,
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }),
      ).show(context);
    } catch (e) {
      // Fallback to a SnackBar if Flushbar fails for any reason.
      try {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title: $message'),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (_) {
        // Last resort: print to debug console — avoid throwing in UI paths.
        debugPrint('Notification failed: $e -- $title: $message');
      }
    }
  }
}

enum NotificationTypes { error, good, none }

const List<String> nigerianStates = [
  'Abia',
  'Adamawa',
  'Akwa Ibom',
  'Anambra',
  'Bauchi',
  'Bayelsa',
  'Benue',
  'Borno',
  'Cross River',
  'Delta',
  'Ebonyi',
  'Edo',
  'Ekiti',
  'Enugu',
  'FCT',
  'Gombe',
  'Imo',
  'Jigawa',
  'Kaduna',
  'Kano',
  'Katsina',
  'Kebbi',
  'Kogi',
  'Kwara',
  'Lagos',
  'Nasarawa',
  'Niger',
  'Ogun',
  'Ondo',
  'Osun',
  'Oyo',
  'Plateau',
  'Rivers',
  'Sokoto',
  'Taraba',
  'Yobe',
  'Zamfara',
];
