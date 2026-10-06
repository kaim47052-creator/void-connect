import 'package:flutter/material.dart';

abstract final class VoidMotion {
  static Duration duration(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context)
      ? Duration.zero
      : const Duration(milliseconds: 180);

  static AnimationStyle dialogStyle(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context)
      ? AnimationStyle.noAnimation
      : const AnimationStyle(
          duration: Duration(milliseconds: 180),
          reverseDuration: Duration(milliseconds: 120),
          curve: Curves.easeOut,
          reverseCurve: Curves.easeIn,
        );
}

class MotionSwitcher extends StatelessWidget {
  const MotionSwitcher({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return AnimatedSwitcher(
      duration: VoidMotion.duration(context),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      layoutBuilder: (currentChild, previousChildren) => Stack(
        alignment: Alignment.topCenter,
        children: [
          for (final previous in previousChildren)
            ExcludeSemantics(
              child: ExcludeFocus(child: IgnorePointer(child: previous)),
            ),
          ?currentChild,
        ],
      ),
      child: child,
    );
  }
}

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    liveRegion: true,
    child: ExcludeSemantics(
      child: MediaQuery.disableAnimationsOf(context)
          ? const Icon(Icons.hourglass_empty_rounded)
          : const CircularProgressIndicator(),
    ),
  );
}
