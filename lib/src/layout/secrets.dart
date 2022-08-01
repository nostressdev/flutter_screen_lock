import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/src/configurations/secret_config.dart';
import 'package:flutter_screen_lock/src/configurations/secrets_config.dart';

class SecretsWithShakingAnimation extends StatefulWidget {
  const SecretsWithShakingAnimation({
    Key? key,
    required this.config,
    required this.length,
    required this.input,
    required this.verifyStream,
    required this.errorConfig,
  }) : super(key: key);
  final SecretsConfig config;
  final SecretsConfig? errorConfig;
  final int length;
  final ValueListenable<String> input;
  final Stream<bool> verifyStream;

  @override
  State<SecretsWithShakingAnimation> createState() =>
      _SecretsWithShakingAnimationState();
}

class _SecretsWithShakingAnimationState
    extends State<SecretsWithShakingAnimation>
    with SingleTickerProviderStateMixin {
  late Animation<Offset> _animation;
  late AnimationController _animationController;
  late StreamSubscription<bool> _verifySubscription;

  SecretsConfig _config = const SecretsConfig();
  var _didMismatch = false;

  @override
  void initState() {
    super.initState();

    _config = widget.config;
    _verifySubscription = widget.verifyStream.listen((valid) {
      if (!valid) {
        // shake animation when invalid
        _animationController.forward();
        if (widget.errorConfig != null) {
          setState(() {
            _config = widget.errorConfig!;
            _didMismatch = true;
          });
        }
      }
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    );

    _animation = _animationController
        .drive(CurveTween(curve: Curves.elasticIn))
        .drive(Tween<Offset>(begin: Offset.zero, end: const Offset(0.05, 0)))
      ..addListener(() => setState(() {}))
      ..addStatusListener(
        (status) {
          if (status == AnimationStatus.completed) {
            _animationController.reverse();
          }
        },
      );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _verifySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: Secrets(
        input: widget.input,
        length: widget.length,
        config: _config,
        didMismatch: _didMismatch,
      ),
    );
  }
}

class Secrets extends StatefulWidget {
  const Secrets({
    Key? key,
    this.config = const SecretsConfig(),
    required this.input,
    required this.length,
    this.didMismatch = false,
  }) : super(key: key);

  final SecretsConfig config;
  final ValueListenable<String> input;
  final int length;
  final bool didMismatch;

  @override
  State<Secrets> createState() => _SecretsState();
}

class _SecretsState extends State<Secrets> with SingleTickerProviderStateMixin {
  double _computeSpacing(BuildContext context) {
    if (widget.config.spacing != null) {
      return widget.config.spacing!;
    }

    return MediaQuery.of(context).size.width * widget.config.spacingRatio;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: widget.input,
      builder: (context, value, child) {
        return SizedBox(
          width: double.infinity,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  padding: widget.config.padding,
                  child: Column(
                    children: [
                      Wrap(
                        spacing: _computeSpacing(context),
                        children: List.generate(
                          widget.length,
                          (index) {
                            if (value.isEmpty) {
                              return Secret(
                                config: widget.config.secretConfig,
                                enabled: false,
                              );
                            }

                            return Secret(
                              config: widget.config.secretConfig,
                              enabled: index < value.length,
                            );
                          },
                          growable: false,
                        ),
                      ),
                      // SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              if (widget.didMismatch)
                Positioned.fill(
                  top: widget.config.errorSpacing! + 30,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      widget.config.errorTitle!,
                      style: widget.config.errorTitleStyle,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class Secret extends StatelessWidget {
  const Secret({
    Key? key,
    this.enabled = false,
    this.config = const SecretConfig(),
  }) : super(key: key);

  final bool enabled;

  final SecretConfig config;

  @override
  Widget build(BuildContext context) {
    if (config.build != null) {
      // Custom build.
      return config.build!(
        context,
        config: config,
        enabled: enabled,
      );
    }

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: enabled ? config.enabledColor : config.disabledColor,
        border: Border.all(
          width: config.borderSize,
          color: config.borderColor,
        ),
      ),
      width: config.width,
      height: config.height,
    );
  }
}
