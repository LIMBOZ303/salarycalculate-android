import 'package:flutter/material.dart';

import '../core/utils/responsive.dart';

class ResponsivePage extends StatelessWidget {
  const ResponsivePage({
    super.key,
    required this.child,
    this.scrollable = true,
    this.withBottomNav = false,
    this.padding,
    this.backgroundColor,
    this.refreshIndicator,
  });

  final Widget child;
  final bool scrollable;
  final bool withBottomNav;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Future<void> Function()? refreshIndicator;

  @override
  Widget build(BuildContext context) {
    final contentPadding = padding ??
        ResponsiveHelper.pagePadding(context, withBottomNav: withBottomNav);

    Widget body = Padding(
      padding: contentPadding,
      child: child,
    );

    body = ResponsiveHelper.constrainContent(context, body);

    if (scrollable) {
      body = SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: body,
      );
    }

    if (refreshIndicator != null) {
      body = RefreshIndicator(
        onRefresh: refreshIndicator!,
        color: Theme.of(context).colorScheme.primary,
        child: scrollable
            ? body
            : LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Padding(
                        padding: contentPadding,
                        child: ResponsiveHelper.constrainContent(context, child),
                      ),
                    ),
                  );
                },
              ),
      );
    }

    return SafeArea(
      child: body,
    );
  }
}

/// Scroll view với padding bottom cho bottom navigation.
class TabScrollView extends StatelessWidget {
  const TabScrollView({
    super.key,
    required this.slivers,
    this.onRefresh,
    this.padding,
  });

  final List<Widget> slivers;
  final Future<void> Function()? onRefresh;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final bottomPad = ResponsiveHelper.pagePadding(context, withBottomNav: true);

    Widget scroll = CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        ...slivers,
        SliverPadding(padding: EdgeInsets.only(bottom: bottomPad.bottom)),
      ],
    );

    scroll = ResponsiveHelper.constrainContent(
      context,
      scroll,
    );

    if (onRefresh != null) {
      return RefreshIndicator(
        onRefresh: onRefresh!,
        child: scroll,
      );
    }

    return SafeArea(child: scroll);
  }
}
