import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/cart_provider.dart';

class AnimatedCartIcon extends ConsumerStatefulWidget {
  final bool selected;

  const AnimatedCartIcon({super.key, this.selected = false});

  @override
  ConsumerState<AnimatedCartIcon> createState() => _AnimatedCartIconState();
}

class _AnimatedCartIconState extends ConsumerState<AnimatedCartIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  int _previousCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _previousCount = ref.read(cartItemCountProvider);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(cartItemCountProvider, (previous, next) {
      if (next > (_previousCount)) {
        _controller.forward(from: 0);
      }
      _previousCount = next;
    });

    final count = ref.watch(cartItemCountProvider);

    return ScaleTransition(
      scale: _scale,
      child: Badge(
        label: Text('$count'),
        isLabelVisible: count > 0,
        child: Icon(
          widget.selected ? Icons.shopping_cart : Icons.shopping_cart_outlined,
        ),
      ),
    );
  }
}
