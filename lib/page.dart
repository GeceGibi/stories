part of story;

class StoryPagePayload {
  StoryPagePayload({
    this.backgroundColor = const Color(0x00000000),
    this.useImageBlurredEffect = false,
    this.showMoreButton,
    this.textPadding = const EdgeInsets.all(12),
    this.image,
    this.text,
  });

  /// Image
  final ImageProvider? image;
  final bool useImageBlurredEffect;

  /// Core
  final Color backgroundColor;

  ///
  final Text? text;
  final EdgeInsets textPadding;
  final Widget? showMoreButton;
}

class StoryPage extends StatefulWidget {
  const StoryPage({
    required this.items,
    this.onWantGoBack,
    this.onComplete,
    this.onChange,
    super.key,
  });

  final List<StoryPagePayload> items;
  final void Function()? onComplete;
  final void Function()? onWantGoBack;
  final void Function(int index)? onChange;

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage>
    with SingleTickerProviderStateMixin {
  final pagerController = StoryPagerController();

  late final animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
  );

  late final colorAnimation = ColorTween(
    begin: Colors.transparent,
    end: Colors.black.withOpacity(0.6),
  ).animate(animationController);

  late final transitionAnimation = Tween(
    begin: const Offset(0, 0.74),
    end: const Offset(0, 0),
  ).animate(CurvedAnimation(
    curve: Curves.easeOutQuart,
    parent: animationController,
  ));

  var paused = false;
  var activeIndex = 0;
  var isHolding = false;
  var isDrawerOpen = false;

  Timer? holdingTimer;
  final holdDuration = const Duration(milliseconds: 125);
  final drawerMinSize = 0.08;
  final drawerMaxSize = 0.40;

  Future<void> next() async {
    if (isHolding) {
      return;
    }

    if (isDrawerOpen) {
      closeDrawer();
    }

    if ((activeIndex + 1) < widget.items.length) {
      setState(() {
        activeIndex++;
      });

      widget.onChange?.call(activeIndex);
    } else {
      if (widget.onComplete != null) {
        widget.onComplete?.call();
      } else {
        setState(() {
          activeIndex = 0;
        });
      }
    }
  }

  Future<void> prev() async {
    if (isHolding) {
      return;
    }

    if (isDrawerOpen) {
      closeDrawer();
    }

    if (activeIndex > 0) {
      setState(() {
        activeIndex--;
      });

      widget.onChange?.call(activeIndex);
    } else {
      widget.onWantGoBack?.call();
    }
  }

  Widget builder(StoryPagePayload payload) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: payload.backgroundColor),
        if (payload.image != null && payload.useImageBlurredEffect)
          Positioned.fill(
            child: ClipRRect(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: _StoryImage(payload.image!, fit: BoxFit.cover),
              ),
            ),
          ),
        if (payload.image != null) _StoryImage(payload.image!),
      ],
    );
  }

  void toggleDrawer() {
    if (!isDrawerOpen) {
      openDrawer();
    } else {
      closeDrawer();
    }
  }

  void openDrawer() {
    if (!isDrawerOpen) {
      pagerController.pause();
      animationController.forward();
      setState(() {
        isDrawerOpen = true;
      });
    }
  }

  void closeDrawer() {
    if (isDrawerOpen) {
      pagerController.resume();
      animationController.reverse();
      setState(() {
        isDrawerOpen = false;
      });
    }
  }

  void onTapDownHandler(_) {
    holdingTimer?.cancel();
    holdingTimer = Timer(holdDuration, () {
      isHolding = true;
      pagerController.pause();
    });
  }

  void onTapUpHandler(_) {
    holdingTimer?.cancel();
    holdingTimer = Timer(holdDuration, () {
      isHolding = false;
      pagerController.resume();
    });
  }

  Future<bool> onWillPopScope() async {
    if (isDrawerOpen) {
      closeDrawer();
      return false;
    }

    return true;
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final payload = widget.items.elementAt(activeIndex);

    return WillPopScope(
      onWillPop: onWillPopScope,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SizedBox.expand(
          child: Stack(
            children: [
              Positioned.fill(child: builder(payload)),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: StoryPager(
                  itemCount: widget.items.length,
                  controller: pagerController,
                  activeIndex: activeIndex,
                  onComplete: next,
                ),
              ),
              Positioned.fill(
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: prev,
                        onTapUp: onTapUpHandler,
                        onTapDown: onTapDownHandler,
                        onTapCancel: () => onTapUpHandler(null),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: next,
                        onTapUp: onTapUpHandler,
                        onTapDown: onTapDownHandler,
                        onTapCancel: () => onTapUpHandler(null),
                      ),
                    ),
                  ],
                ),
              ),
              if (payload.text != null)
                Positioned(
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: AnimatedSize(
                    alignment: Alignment.bottomCenter,
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutQuart,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 280.0),
                      child: AnimatedBuilder(
                        animation: animationController,
                        builder: (context, child) {
                          return ColoredBox(
                            color: colorAnimation.value!,
                            child: child,
                          );
                        },
                        child: Stack(
                          children: [
                            RawScrollbar(
                              thickness: 2,
                              thumbColor: Colors.white,
                              radius: const Radius.circular(8),
                              padding: const EdgeInsets.all(4),
                              child: SingleChildScrollView(
                                  physics: const ClampingScrollPhysics(),
                                  padding: payload.textPadding,
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      if (payload.showMoreButton != null) {
                                        final textPainter = TextPainter(
                                          ellipsis: '...',
                                          text: TextSpan(
                                            text: payload.text!.data!,
                                            style: payload.text?.style,
                                          ),
                                          textDirection: TextDirection.ltr,
                                          maxLines: 2,
                                        )..layout(
                                            minWidth: constraints.minWidth,
                                            maxWidth: constraints.maxWidth -
                                                payload.textPadding.horizontal,
                                          );

                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              payload.text!.data!,
                                              style: payload.text?.style,
                                              maxLines: isDrawerOpen ? null : 2,
                                              overflow: isDrawerOpen
                                                  ? null
                                                  : TextOverflow.ellipsis,
                                            ),
                                            if (!isDrawerOpen &&
                                                textPainter.didExceedMaxLines)
                                              payload.showMoreButton!
                                          ],
                                        );
                                      }

                                      return ExpandableText(
                                        payload.text!.data!,
                                        maxLines: 2,
                                        buttonLabelClosed: 'Devamını Gör',
                                        buttonLabelOpened: '',
                                        isExpanded: isDrawerOpen,
                                        style: payload.text?.style,
                                        buttonTextStyle: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    },
                                  )),
                            ),
                            Positioned.fill(
                              child: GestureDetector(
                                onTap: toggleDrawer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}

class ExpandableText extends StatelessWidget {
  const ExpandableText(
    this.value, {
    super.key,
    this.maxLines = 2,
    this.style,
    this.buttonTextStyle,
    this.buttonLabelClosed = 'show more',
    this.buttonLabelOpened = 'show less',
    this.isExpanded = false,
    this.ellipsis = '... ',
  });

  final String value;
  final int maxLines;
  final TextStyle? style;
  final TextStyle? buttonTextStyle;
  final String buttonLabelClosed;
  final String buttonLabelOpened;
  final bool isExpanded;
  final String ellipsis;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: TextSpan(text: value, style: style),
          textDirection: TextDirection.ltr,
          maxLines: maxLines,
          ellipsis: ellipsis,
        )..layout(
            minWidth: constraints.minWidth,
            maxWidth: constraints.maxWidth,
          );

        final moreTextPainter = TextPainter(
          text: TextSpan(
            text: isExpanded ? buttonLabelOpened : buttonLabelClosed,
            style: buttonTextStyle,
          ),
          textDirection: TextDirection.ltr,
          maxLines: 1,
        )..layout(
            minWidth: constraints.minWidth,
            maxWidth: constraints.maxWidth,
          );

        final position = textPainter.getPositionForOffset(Offset(
          textPainter.size.width - moreTextPainter.size.width,
          textPainter.height,
        ));

        final endOffset = textPainter.getOffsetBefore(position.offset) ?? 0;

        var text = value;

        if (textPainter.didExceedMaxLines) {
          text = isExpanded
              ? value
              : '${value.substring(0, endOffset - ellipsis.length)}$ellipsis';
        }

        return RichText(
          softWrap: true,
          overflow: TextOverflow.clip,
          text: TextSpan(
            text: text,
            style: style,
            children: [
              // WidgetSpan(child: child),
              if (textPainter.didExceedMaxLines)
                TextSpan(
                  text: isExpanded ? buttonLabelOpened : buttonLabelClosed,
                  style: buttonTextStyle,
                  // recognizer: TapGestureRecognizer()..onTap = onTapHandler,
                ),
            ],
          ),
        );
      },
    );
  }
}
