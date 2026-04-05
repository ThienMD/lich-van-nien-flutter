import 'package:flutter/material.dart';

class Dot extends StatelessWidget {
  const Dot(this.isShow, this.color, {super.key});

  final bool isShow;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 8,
      height: 8,
      child: DecoratedBox(
        decoration: isShow
            ? BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              )
            : const BoxDecoration(),
      ),
    );
  }
}