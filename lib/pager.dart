part of story;

class StoryPagerController {
  final _listeners = <_StoryPagerDotState>[];
  void _attach(_StoryPagerDotState state) {
    _listeners.add(state);
  }

  void _detach(_StoryPagerDotState state) {
    _listeners.remove(state);
  }

  void pause() {
    for (final listener in _listeners) {
      listener.pause();
    }
  }

  void resume() {
    for (final listener in _listeners) {
      listener.play();
    }
  }
}

class StoryPagerOptions {
  const StoryPagerOptions({
    this.backgroundColor = const Color(0x66ffffff),
    this.foregroundColor = const Color(0xFFFFFFFF),
    this.duration = const Duration(seconds: 5),
    this.gradient = const LinearGradient(
      colors: [Color(0xCC000000), Color(0x00000000)],
      end: Alignment.bottomCenter,
      begin: Alignment.topCenter,
    ),
  });

  final Gradient gradient;
  final Duration duration;
  final Color backgroundColor;
  final Color foregroundColor;
}

class StoryPager extends StatelessWidget {
  const StoryPager({
    required this.itemCount,
    required this.activeIndex,
    required this.onComplete,
    this.controller,
    this.options = const StoryPagerOptions(),
    super.key,
  });

  final int itemCount;
  final int activeIndex;
  final void Function() onComplete;
  final StoryPagerOptions options;
  final StoryPagerController? controller;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: options.gradient,
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 8,
          bottom: 32,
          right: 8,
          left: 8,
        ),
        child: Row(
          children: List.generate(itemCount, (i) {
            return _StoryPagerDot(
              indexActive: activeIndex,
              onComplete: onComplete,
              controller: controller,
              options: options,
              indexSelf: i,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _StoryPagerDot extends StatefulWidget {
  const _StoryPagerDot({
    required this.indexSelf,
    required this.indexActive,
    required this.onComplete,
    required this.options,
    this.controller,
  });

  final int indexSelf;
  final int indexActive;
  final StoryPagerOptions options;
  final void Function() onComplete;
  final StoryPagerController? controller;

  @override
  State<_StoryPagerDot> createState() => _StoryPagerDotState();
}

class _StoryPagerDotState extends State<_StoryPagerDot>
    with SingleTickerProviderStateMixin {
  /// Base controller
  late final controller = AnimationController(
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
    if (widget.indexSelf == widget.indexActive && !controller.isAnimating) {
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
  void initState() {
    super.initState();
    widget.controller?._attach(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setAnimationState();
    });
  }

  @override
  void didUpdateWidget(_StoryPagerDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    setAnimationState();
  }

  @override
  void dispose() {
    controller.dispose();
    widget.controller?._detach(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: SizedBox(
          height: 2,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(4)),
            child: Stack(
              fit: StackFit.passthrough,
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
      ),
    );
  }
}
