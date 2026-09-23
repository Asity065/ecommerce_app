import 'package:flutter/material.dart';

class AddToCartButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool filled;
  final Widget child;

  const AddToCartButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.filled = false,
  });

  @override
  State<AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends State<AddToCartButton> {
  double _scale = 1.0;

  void _pulse() {
    if (widget.onPressed == null) return;
    setState(() => _scale = 0.85);
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) setState(() => _scale = 1.0);
    });
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: widget.filled
          ? IconButton.filled(
              visualDensity: VisualDensity.compact,
              icon: widget.child,
              onPressed: widget.onPressed == null ? null : _pulse,
            )
          : InkWell(
              onTap: widget.onPressed == null ? null : _pulse,
              child: widget.child,
            ),
    );
  }
}
