part of 'pager.dart';

class StoryPagerItemOptions {
  const StoryPagerItemOptions({
    this.borderRadius = const BorderRadius.all(Radius.circular(4)),
    this.backgroundColor = const Color(0x66ffffff),
    this.foregroundColor = const Color(0xFFFFFFFF),
    this.duration = const Duration(seconds: 5),
    this.height = 2.0,
    this.gap = 2.0,
    this.paused = false,
  });

  final BorderRadius borderRadius;
  final Color backgroundColor;
  final Color foregroundColor;
  final Duration duration;
  final double height;
  final double gap;
  final bool paused;

  StoryPagerItemOptions copyWith({
    BorderRadius? borderRadius,
    Color? backgroundColor,
    Color? foregroundColor,
    Duration? duration,
    double? height,
    double? gap,
    bool? paused,
  }) {
    return StoryPagerItemOptions(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderRadius: borderRadius ?? this.borderRadius,
      duration: duration ?? this.duration,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      gap: gap ?? this.gap,
      height: height ?? this.height,
      paused: paused ?? this.paused,
    );
  }
}

class _StoryPagerItem extends StatefulWidget {
  const _StoryPagerItem({
    required this.indexSelf,
    required this.indexActive,
    required this.onComplete,
    required this.options,
    this.controller,
  });

  final int indexSelf;
  final int indexActive;

  final void Function() onComplete;

  final StoryPagerItemOptions options;
  final StoryPagerController? controller;

  @override
  State<_StoryPagerItem> createState() => _StoryPagerItemState();
}

class _StoryPagerItemState extends State<_StoryPagerItem>
    with SingleTickerProviderStateMixin {
  late var paused = widget.options.paused;

  /// Base controller
  late var controller = AnimationController(
    duration: widget.options.duration,
    vsync: this,
  );

  ///
  late final offsetAnimation = Tween<Offset>(
    begin: const Offset(-1, 0),
    end: const Offset(0, 0),
  ).animate(CurvedAnimation(
    curve: Curves.linear,
    parent: controller,
  ));

  void pause() {
    if (controller.isAnimating) {
      controller.stop();
    }
  }

  void play() {
    if (widget.indexSelf == widget.indexActive &&
        !controller.isAnimating &&
        controller.value != 1.0 &&
        !paused) {
      controller.forward().whenComplete(widget.onComplete);
    }
  }

  void setAnimationState() {
    if (widget.indexSelf == widget.indexActive &&
        offsetAnimation.status != AnimationStatus.forward) {
      controller.reset();
      play();
    }

    /// Passed
    else if (widget.indexSelf < widget.indexActive) {
      controller.stop();
      controller.value = 1;
    }

    ///  Next
    else if (widget.indexSelf > widget.indexActive) {
      controller.stop();
      controller.value = 0;
    }
  }

  @override
  void didUpdateWidget(_StoryPagerItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    setAnimationState();
  }

  @override
  void initState() {
    super.initState();
    widget.controller?._attachItem(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setAnimationState();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    widget.controller?._detachItem(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: widget.options.height,
        child: ClipRRect(
          borderRadius: widget.options.borderRadius,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(color: widget.options.backgroundColor),
              SlideTransition(
                position: offsetAnimation,
                child: ColoredBox(color: widget.options.foregroundColor),
              )
            ],
          ),
        ),
      ),
    );
  }
}
