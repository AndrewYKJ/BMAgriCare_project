import 'package:flutter/material.dart';

Widget dottedLineSeperator({double height, Color color}) {
  return LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) {
      final boxWidth = constraints.constrainWidth();
      final dashWidth = 2.0;
      final dashHeight = height ?? 1;
      final dashCount = (boxWidth / (2 * dashWidth)).floor();
      return Flex(
        children: List.generate(dashCount, (_) {
          return SizedBox(
            width: dashWidth,
            height: dashHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: (color != null) ? color : Colors.black,
              ),
            ),
          );
        }),
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        direction: Axis.horizontal,
      );
    },
  );
}
