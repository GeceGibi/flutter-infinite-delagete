library infinite_list_delegate;

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class InfiniteListDelegate extends SliverChildBuilderDelegate {
  InfiniteListDelegate({
    required this.itemBuilder,
    required this.itemCount,
    required this.onInfinite,
    this.separatorBuilder,
    this.progressIndicator,
    this.endOfListWidget = const SizedBox.shrink(),
  }) : super(
          (context, index) {},
          childCount: max(0, itemCount * 2) + 1,
          semanticIndexCallback: (Widget _, int index) {
            return index.isEven ? index ~/ 2 : null;
          },
        );

  final FutureOr<bool> Function() onInfinite;
  final Widget Function(BuildContext, int) itemBuilder;
  final Widget Function(BuildContext, int)? separatorBuilder;
  final int itemCount;

  final Widget? progressIndicator;
  final Widget endOfListWidget;

  var canInfinite = ValueNotifier(true);
  var isWorking = false;

  Future<void> onInfiniteHandler() async {
    if (isWorking || !canInfinite.value || itemCount == 0) {
      return;
    }

    isWorking = true;
    canInfinite.value = await onInfinite();

    if (canInfinite.value) {
      isWorking = false;
    }
  }

  @override
  NullableIndexedWidgetBuilder get builder => (context, index) {
        final itemIndex = index ~/ 2;

        if (itemIndex >= itemCount) {
          return ValueListenableBuilder(
            valueListenable: canInfinite,
            builder: (context, iCan, indicator) {
              if (iCan) {
                onInfiniteHandler();
                return indicator!;
              }

              return endOfListWidget;
            },
            child: progressIndicator ??
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator.adaptive()),
                ),
          );
        }

        if (index.isEven) {
          return itemBuilder(context, itemIndex);
        }

        if (separatorBuilder != null) {
          return separatorBuilder!(context, itemIndex);
        }

        return const SizedBox.shrink();
      };
}
