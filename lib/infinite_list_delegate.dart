library infinite_list_delegate;

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class InfiniteChildBuilderDelegate extends SliverChildBuilderDelegate {
  InfiniteChildBuilderDelegate({
    required this.itemCount,
    required this.itemBuilder,
    required this.onInfinite,
    this.separatorBuilder,

    ///
    this.canInfinite = true,
    this.endOfListWidget = const SizedBox.shrink(),
    this.progressIndicator = const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(child: CircularProgressIndicator.adaptive()),
    ),

    /// --
    int semanticIndexOffset = 0,
    bool addSemanticIndexes = true,
    bool addRepaintBoundaries = true,
    bool addAutomaticKeepAlives = true,
    int? Function(Key)? findChildIndexCallback,
    int? Function(Widget, int)? semanticIndexCallback,
  }) : super(
          (context, index) {
            /// Will override
            return null;
          },
          childCount: separatorBuilder != null
              ? math.max(0, itemCount * 2) + 1
              : itemCount + 1,
          semanticIndexCallback: (widget, index) {
            if (semanticIndexCallback != null) {
              return semanticIndexCallback(widget, index);
            }

            if (separatorBuilder != null) {
              return index.isEven ? index ~/ 2 : null;
            }

            return index;
          },
          semanticIndexOffset: semanticIndexOffset,
          addSemanticIndexes: addSemanticIndexes,
          addRepaintBoundaries: addRepaintBoundaries,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          findChildIndexCallback: findChildIndexCallback,
        );

  final Future<void> Function() onInfinite;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final Widget Function(BuildContext context, int index)? separatorBuilder;
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
        final index = separatorBuilder != null ? i ~/ 2 : i;

        if (index >= itemCount) {
          if (canInfinite) {
            onInfiniteHandler();
            return progressIndicator;
          }

          return endOfListWidget;
        }

        if (separatorBuilder == null || i.isEven) {
          return itemBuilder(context, index);
        }

        return separatorBuilder!(context, index);
      };
}
