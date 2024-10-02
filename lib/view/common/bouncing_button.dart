import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class BouncingButton extends StatefulWidget {

  final Widget child;
  final VoidCallback? onTap;

  const BouncingButton({
    required this.child,
    this.onTap,
    super.key
  });

  @override
  State<BouncingButton> createState() => _BouncingButtonState();
}

class _BouncingButtonState extends State<BouncingButton> with SingleTickerProviderStateMixin {
  late double _scale;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
      lowerBound: 0.0,
      upperBound: 0.1,
    )..addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() async {
    _controller.forward();
    await Future.delayed(const Duration(milliseconds: 50));
    _controller.reverse();

    if (widget.onTap != null) {
      widget.onTap!();
    }
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _controller.value;

    return GestureDetector(
      onTap: _onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: () {
        _controller.reverse();
      },
      behavior: HitTestBehavior.translucent,
      child: Transform.scale(
        scale: _scale,
        child: widget.child,
      ),
    );
  }

}
