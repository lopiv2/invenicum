import 'package:flutter/material.dart';

class ChromaticAberrationLayer extends StatelessWidget {
  final double offset;
  final Widget child;

  const ChromaticAberrationLayer({
    super.key,
    required this.offset,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: ClipRect(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Transform.translate(
                      offset: Offset(-offset, 0),
                      child: BackdropFilter(
                        filter: const ColorFilter.matrix([
                          1, 0, 0, 0, 0,
                          0, 0, 0, 0, 0,
                          0, 0, 0, 0, 0,
                          0, 0, 0, 0.5, 0,
                        ]),
                        child: Container(color: Colors.transparent),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Transform.translate(
                      offset: Offset(offset, 0),
                      child: BackdropFilter(
                        filter: const ColorFilter.matrix([
                          0, 0, 0, 0, 0,
                          0, 0, 0, 0, 0,
                          0, 0, 1, 0, 0,
                          0, 0, 0, 0.5, 0,
                        ]),
                        child: Container(color: Colors.transparent),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
