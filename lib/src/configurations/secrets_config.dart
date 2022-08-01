import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/src/configurations/secret_config.dart';

class SecretsConfig {
  const SecretsConfig({
    this.spacing,
    this.spacingRatio = 0.05,
    this.padding = const EdgeInsets.only(top: 20, bottom: 50),
    this.errorSpacing = 10,
    this.errorTitle = 'Passwords do not match',
    this.secretConfig = const SecretConfig(),
    this.errorTitleStyle,
  });

  /// Absolute space between secret widgets.
  /// If specified together with spacingRatio, this will take precedence.
  final double? spacing;

  /// Space ratio between secret widgets.
  ///
  /// Default `0.05`
  final double spacingRatio;

  /// padding of Secrets Widget.
  ///
  /// Default [EdgeInsets.only(top: 20, bottom: 50)]
  final EdgeInsetsGeometry padding;

  final SecretConfig secretConfig;


  /// Error title customization
  final double? errorSpacing;

  final String? errorTitle;

  final TextStyle? errorTitleStyle;
}
