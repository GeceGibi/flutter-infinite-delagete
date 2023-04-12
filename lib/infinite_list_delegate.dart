library infinite_list_delegate;

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class InfiniteChildBuilderDelegate extends SliverChildBuilderDelegate {
  static Widget _defaultSeparatedBuilder(BuildContext context, int index) {
    return const SizedBox.shrink();
  }

  InfiniteChildBuilderDelegate({
    required this.itemCount,
    required this.itemBuilder,
    required this.onInfinite,
    this.canInfinite = true,
    this.separatorBuilder = _defaultSeparatedBuilder,
    this.endOfListWidget = const SizedBox.shrink(),
    this.progressIndicator = const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(child: CircularProgressIndicator.adaptive()),
    ),
  }) : super(
          (context, index) {},
          childCount: math.max(0, itemCount * 2) + 1,
          semanticIndexCallback: (_, index) {
            return index.isEven ? index ~/ 2 : null;
          },
          addRepaintBoundaries: true,
          addAutomaticKeepAlives: true,
          addSemanticIndexes: true,
        );

  final Future<void> Function() onInfinite;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final Widget Function(BuildContext context, int index) separatorBuilder;
  final int itemCount;

  final Widget progressIndicator;
  final Widget endOfListWidget;
  final bool canInfinite;

  var isWorking = false;

  Future<void> onInfiniteHandler() async {
    if (isWorking || !canInfinite || itemCount == 0) {
      return;
    }

    isWorking = true;
    await onInfinite();

    if (canInfinite) {
      isWorking = false;
    }
  }

  @override
  NullableIndexedWidgetBuilder get builder => (context, i) {
        final index = i ~/ 2;

        if (index >= itemCount) {
          if (canInfinite) {
            onInfiniteHandler();
            return progressIndicator;
          }

          return endOfListWidget;
        }

        if (i.isEven) {
          return itemBuilder(context, index);
        }

        return separatorBuilder(context, index);
      };
}
