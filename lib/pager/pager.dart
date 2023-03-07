import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

part 'controller.dart';
part 'gestures.dart';
part 'item.dart';

class StoryPagerOptions {
  const StoryPagerOptions({
    this.padding = const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
    this.gradient = const LinearGradient(
      colors: [Color(0xCC000000), Color(0x00000000)],
      end: Alignment.bottomCenter,
      begin: Alignment.topCenter,
    ),
  });

  final EdgeInsets padding;
  final Gradient gradient;

  StoryPagerOptions copyWith({
    StoryPagerItemOptions? itemOptions,
    EdgeInsets? padding,
    Gradient? gradient,
  }) {
    return StoryPagerOptions(
      gradient: gradient ?? this.gradient,
      padding: padding ?? this.padding,
    );
  }
}

class StoryPager extends StatefulWidget {
  const StoryPager({
    required this.stories,
    this.options = const StoryPagerOptions(),
    this.controller,
    this.initialIndex = 0,
    this.onComplete,
    this.onChange,
    this.onGoBack,
    super.key,
  });

  final List<StoryPagerItemOptions> stories;
  final int initialIndex;

  final StoryPagerOptions options;
  final StoryPagerController? controller;

  /// Callbacks
  final void Function(int index)? onChange;
  final void Function()? onGoBack;
  final void Function()? onComplete;

  @override
  State<StoryPager> createState() => _StoryPagerState();
}

class _StoryPagerState extends State<StoryPager> {
  late var index = widget.initialIndex;
  late final pagerController = widget.controller ?? StoryPagerController();

  var paused = false;
  var isHolding = false;
  var isDrawerOpen = false;

  Timer? holdingTimer;
  final holdDuration = const Duration(milliseconds: 100);

  void goPage(int page) {
    if (page < 0 || page > widget.stories.length || index == page) {
      return;
    }

    setState(() {
      index = page;
    });
  }

  bool get canGoNext => (index + 1) < widget.stories.length;
  bool get canGoPrev => index > 0;

  void goNextPage() {
    if (isHolding) {
      return;
    }

    if (canGoNext) {
      setState(() => index++);
      widget.onChange?.call(index);
    } else {
      widget.onComplete?.call();
    }
  }

  void goPrevPage() {
    if (isHolding) {
      return;
    }

    if (canGoPrev) {
      setState(() => index--);
      widget.onChange?.call(index);
    } else {
      widget.onGoBack?.call();
    }
  }

  void onCompleteItemDuration() {
    goNextPage();
  }

  @override
  void initState() {
    super.initState();
    pagerController._attachPager(this);
  }

  @override
  void dispose() {
    pagerController._detachPager(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: widget.options.gradient,
      ),
      child: Padding(
        padding: widget.options.padding,
        child: Row(
          children: List.generate(max(0, (widget.stories.length * 2) - 1), (i) {
            final actualIndex = i ~/ 2;
            final itemOptions = widget.stories[actualIndex];

            if (i.isOdd) {
              return SizedBox(width: itemOptions.gap);
            }

            return _StoryPagerItem(
              indexActive: index,
              onComplete: onCompleteItemDuration,
              controller: pagerController,
              options: itemOptions,
              indexSelf: actualIndex,
            );
          }),
        ),
      ),
    );
  }
}
