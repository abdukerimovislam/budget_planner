import 'package:flutter/material.dart';

import '../../core/utils/responsive.dart';

class AdaptivePagePadding extends StatelessWidget {
  final Widget child;
  final bool addBottomSafeArea;

  const AdaptivePagePadding({
    super.key,
    required this.child,
    this.addBottomSafeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    final horizontal = Responsive.pageHorizontalPadding(context);
    final top = Responsive.pageTopPadding(context);
    final bottomSafe = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontal,
        top,
        horizontal,
        addBottomSafeArea ? (bottomSafe > 0 ? bottomSafe : 16) : 0,
      ),
      child: child,
    );
  }
}