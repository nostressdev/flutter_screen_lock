import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';

/// Animated ScreenLock
///
/// - `correctString`: Input correct string (Required).
///   If [confirmation] is `true`, it will be ignored, so set it to any string or empty.
/// - `screenLockConfig`: Configurations of [ScreenLock]
/// - `secretsConfig`: Configurations of [Secrets]
/// - `inputButtonConfig`: Configurations of [InputButton]
/// - `canCancel`: `true` is show cancel button
/// - `confirmation`: Make sure the first and second inputs are the same.
/// - `digits`: Set the maximum number of characters to enter when [confirmation] is `true`.
/// - `maxRetries`: `0` is unlimited. For example, if it is set to 1, didMaxRetries will be called on the first failure. Default `0`
/// - `retryDelay`: Delay until we can retry. Duration.zero is no delay.
/// - `delayChild`: Specify the widget during input invalidation by retry delay.
/// - `didUnlocked`: Called if the value matches the correctString.
/// - `didError`: Called if the value does not match the correctString.
/// - `didMaxRetries`: Events that have reached the maximum number of attempts
/// - `didOpened`: For example, when you want to perform biometric authentication
/// - `didConfirmed`: Called when the first and second inputs match during confirmation
/// - `didCancelled`: Called when the user cancels the screen
/// - `customizedButtonTap`: Tapped for left side lower button
/// - `customizedButtonChild`: Child for bottom left side button
/// - `footer`: Add a Widget to the footer
/// - `cancelButton`: Change the child widget for the delete button
/// - `deleteButton`: Change the child widget for the delete button
/// - `title`: Change the title widget
/// - `confirmTitle`: Change the confirm title widget
/// - `inputController`: Control inputs externally
/// - `withBlur`: Blur the background
/// - `secretsBuilder`: Custom secrets animation widget builder
/// - `useLandscape`: Use a landscape orientation. Default `true`
/// - `onValidate`: Callback to validate input values filled in [digits].
Future<void> screenLock({
  required BuildContext context,
  required String correctString,
  VoidCallback? didUnlocked,
  VoidCallback? didOpened,
  VoidCallback? didCancelled,
  void Function(String matchedText)? didConfirmed,
  void Function(int retries)? didError,
  void Function(int retries)? didMaxRetries,
  VoidCallback? customizedButtonTap,
  bool confirmation = false,
  bool canCancel = true,
  int digits = 4,
  int maxRetries = 0,
  Duration retryDelay = Duration.zero,
  Widget? title,
  Widget? confirmTitle,
  ScreenLockConfig? screenLockConfig,
  SecretsConfig? secretsConfig,
  SecretsConfig? errorSecretsConfig,
  KeyPadConfig? keyPadConfig,
  DelayBuilderCallback? delayBuilder,
  Widget? customizedButtonChild,
  Widget? footer,
  Widget? cancelButton,
  Widget? deleteButton,
  InputController? inputController,
  bool withBlur = true,
  SecretsBuilderCallback? secretsBuilder,
  bool useLandscape = true,
  ValidationCallback? onValidate,
}) async {
  return Navigator.push<void>(
    context,
    PageRouteBuilder<void>(
      opaque: false,
      barrierColor: Colors.black.withOpacity(0.8),
      pageBuilder: (context, animation, secondaryAnimation) => WillPopScope(
        onWillPop: () async => canCancel && didCancelled == null,
        child: ScreenLock(
          correctString: correctString,
          screenLockConfig: screenLockConfig,
          secretsConfig: secretsConfig,
          errorSecretsConfig: errorSecretsConfig,
          keyPadConfig: keyPadConfig,
          didCancelled:
              canCancel ? didCancelled ?? Navigator.of(context).pop : null,
          confirmation: confirmation,
          digits: digits,
          maxRetries: maxRetries,
          retryDelay: retryDelay,
          delayBuilder: delayBuilder,
          didUnlocked: didUnlocked ?? Navigator.of(context).pop,
          didError: didError,
          didMaxRetries: didMaxRetries,
          didConfirmed: didConfirmed,
          didOpened: didOpened,
          customizedButtonTap: customizedButtonTap,
          customizedButtonChild: customizedButtonChild,
          footer: footer,
          deleteButton: deleteButton,
          cancelButton: cancelButton,
          title: title,
          confirmTitle: confirmTitle,
          inputController: inputController,
          withBlur: withBlur,
          secretsBuilder: secretsBuilder,
          useLandscape: useLandscape,
          onValidate: onValidate,
        ),
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.0, 2.4),
          end: Offset.zero,
        ).animate(animation),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset.zero,
            end: const Offset(0.0, 2.4),
          ).animate(secondaryAnimation),
          child: child,
        ),
      ),
    ),
  );
}
