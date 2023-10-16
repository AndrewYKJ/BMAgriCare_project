import 'package:behn_meyer_flutter/const/app_color.dart';
import 'package:flutter/material.dart';

Widget floatingButtonScrollToTop(
    ScrollController scrollController, bool isReversing) {
  return (isReversing && scrollController.position.pixels > 0.0)
      ? FloatingActionButton(
          child: Icon(Icons.arrow_upward),
          backgroundColor: AppColor.appBlue(),
          onPressed: () {
            scrollController.animateTo(
              0.0,
              curve: Curves.ease,
              duration: Duration(milliseconds: 500),
            );
          },
        )
      : null;
}
