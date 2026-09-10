import 'package:flutter/material.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.reveal,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: ChatTokens.assistantBubble(context),
        borderRadius: ChatTokens.bubbleRadiusAssistant,
        border: Border.all(color: ChatTokens.assistantBubbleBorder(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          3,
          (i) => _Dot(controller: _controller, index: i),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.controller, required this.index});

  final AnimationController controller;
  final int index;

  @override
  Widget build(BuildContext context) {
    final animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          index / 4,
          (index + 1) / 4 + 0.25,
          curve: Curves.easeInOut,
        ),
      ),
    );
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Opacity(opacity: animation.value, child: child),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
        width: 8.0,
        height: 8.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ChatTokens.typingIndicator(context),
        ),
      ),
    );
  }
}
