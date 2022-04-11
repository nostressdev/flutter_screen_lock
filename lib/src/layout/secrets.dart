import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/src/configurations/secret_config.dart';
import 'package:flutter_screen_lock/src/configurations/secrets_config.dart';

class SecretsWithShakingAnimation extends StatefulWidget {
  const SecretsWithShakingAnimation({
    Key? key,
    required this.config,
    required this.length,
    required this.inputStream,
    required this.verifyStream,
  }) : super(key: key);
  final SecretsConfig config;
  final int length;
  final Stream<String> inputStream;
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

  @override
  void initState() {
    super.initState();

    _verifySubscription = widget.verifyStream.listen((valid) {
      if (!valid) {
        // shake animation when invalid
        _animationController.forward();
      }
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    );

    _animation = _animationController
        .drive(CurveTween(curve: Curves.elasticIn))
        .drive(Tween<Offset>(begin: Offset.zero, end: const Offset(0.05, 0)))
      ..addListener(() {
        setState(() {});
      })
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
    _verifySubscription.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: Secrets(
        inputStream: widget.inputStream,
        length: widget.length,
        config: widget.config,
      ),
    );
  }
}

class Secrets extends StatefulWidget {
  const Secrets({
    Key? key,
    this.config = const SecretsConfig(),
    required this.inputStream,
    required this.length,
  }) : super(key: key);

  final SecretsConfig config;
  final Stream<String> inputStream;
  final int length;

  @override
  _SecretsState createState() => _SecretsState();
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
    return StreamBuilder<String>(
      stream: widget.inputStream,
      builder: (context, snapshot) {
        return Container(
          padding: widget.config.padding,
          child: Wrap(
            spacing: _computeSpacing(context),
            children: List.generate(
              widget.length,
              (index) {
                if (!snapshot.hasData) {
                  return Secret(
                    config: widget.config.secretConfig,
                    enabled: false,
                  );
                }

                return Secret(
                  config: widget.config.secretConfig,
                  enabled: index < snapshot.data!.length,
                );
              },
              growable: false,
            ),
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
