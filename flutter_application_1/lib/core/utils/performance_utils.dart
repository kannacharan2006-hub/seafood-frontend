import 'package:flutter/material.dart';

class PerformanceUtils {
  static void logBuildTime(BuildContext context, String name) {
    assert(() {
      final longPress = DateTime.now();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        debugPrint('$name build time: ${DateTime.now().difference(longPress).inMilliseconds}ms');
      });
      return true;
    }());
  }

  static void preventOverscroll(BuildContext scrollView) {
    if (scrollView is ScrollView) {
      // Already optimized by default
    }
  }
}

class OptimizedListView extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final Widget? header;
  final Widget? footer;
  final EdgeInsets? padding;
  final ScrollController? controller;
  final Future<void> Function()? onRefresh;
  final bool shrinkWrap;

  const OptimizedListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.header,
    this.footer,
    this.padding,
    this.controller,
    this.onRefresh,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget listView = ListView.builder(
      itemCount: itemCount + (header != null ? 1 : 0) + (footer != null ? 1 : 0),
      controller: controller,
      shrinkWrap: shrinkWrap,
      physics: const BouncingScrollPhysics(),
      cacheExtent: 250,
      itemBuilder: (context, index) {
        if (header != null && index == 0) {
          return header!;
        }
        
        final dataIndex = header != null ? index - 1 : index;
        
        if (footer != null && index == itemCount + (header != null ? 1 : 0)) {
          return footer!;
        }
        
        return itemBuilder(context, dataIndex);
      },
    );

    if (onRefresh != null) {
      listView = RefreshIndicator(
        onRefresh: onRefresh!,
        child: listView,
      );
    }

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: listView,
    );
  }
}

class OptimizedGridView extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;

  const OptimizedGridView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.crossAxisCount = 2,
    this.crossAxisSpacing = 12,
    this.mainAxisSpacing = 12,
    this.childAspectRatio = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: itemCount,
      physics: const BouncingScrollPhysics(),
      cacheExtent: 200,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: itemBuilder,
    );
  }
}

class LazyColumn extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final Widget? header;
  final EdgeInsets? padding;

  const LazyColumn({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.header,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount + (header != null ? 1 : 0),
      padding: padding,
      physics: const BouncingScrollPhysics(),
      cacheExtent: 300,
      itemBuilder: (context, index) {
        if (header != null && index == 0) {
          return header!;
        }
        return itemBuilder(context, header != null ? index - 1 : index);
      },
    );
  }
}

extension OptimizedWidget on Widget {
  Widget cached() => _CachedWidget(child: this);
}

class _CachedWidget extends StatefulWidget {
  final Widget child;

  const _CachedWidget({required this.child});

  @override
  State<_CachedWidget> createState() => _CachedWidgetState();
}

class _CachedWidgetState extends State<_CachedWidget> {
  @override
  Widget build(BuildContext context) => widget.child;
}
