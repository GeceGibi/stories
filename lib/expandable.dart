part of story;

class StoryExpandableOptions {}

class StoryExpandable extends StatefulWidget {
  const StoryExpandable({
    required this.text,
    this.isOpen = false,
    this.isExpandable = true,
    this.padding = const EdgeInsets.all(12),
    this.backgroundColorExpanded = Colors.black,
    this.backgroundColorCollapsed = Colors.transparent,
    this.onChange,
    this.constraints = const BoxConstraints(maxHeight: 240),
    this.readMoreButton,
    this.readMoreTextExpanded = 'read more',
    this.readMoreTextCollapsed = 'read less',
    super.key,
  });

  final Color backgroundColorExpanded;
  final Color backgroundColorCollapsed;
  final BoxConstraints constraints;
  final EdgeInsets? padding;

  final Text text;
  final Widget? readMoreButton;
  final String readMoreTextExpanded;
  final String readMoreTextCollapsed;

  final bool isOpen;
  final bool isExpandable;

  final void Function(bool index)? onChange;

  @override
  State<StoryExpandable> createState() => _StoryExpandableState();
}

class _StoryExpandableState extends State<StoryExpandable> {
  final scrollController = ScrollController();
  late var isExpanded = widget.isOpen;

  void onChangeHandler() {
    setState(() {
      isExpanded = !isExpanded;
    });

    widget.onChange?.call(isExpanded);
  }

  @override
  void didUpdateWidget(covariant StoryExpandable oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isOpen != widget.isOpen && isExpanded != widget.isOpen) {
      setState(() {
        isExpanded = widget.isOpen;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.text.data!.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedSize(
      alignment: Alignment.bottomCenter,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutQuart,
      child: ConstrainedBox(
        constraints: widget.constraints,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutQuart,
          color: isExpanded
              ? widget.backgroundColorExpanded
              : widget.backgroundColorCollapsed,
          child: Stack(
            children: [
              RawScrollbar(
                thickness: 2,
                thumbColor: Colors.white,
                radius: const Radius.circular(8),
                padding: const EdgeInsets.all(4),
                controller: scrollController,
                child: SingleChildScrollView(
                    controller: scrollController,
                    physics: const ClampingScrollPhysics(),
                    padding: widget.padding,
                    child: Builder(
                      builder: (context) {
                        // if (payload.showMoreButton != null) {
                        //   final textPainter = TextPainter(
                        //     ellipsis: '...',
                        //     text: TextSpan(
                        //       text: payload.text!.data!,
                        //       style: payload.text?.style,
                        //     ),
                        //     textDirection: TextDirection.ltr,
                        //     maxLines: 2,
                        //   )..layout(
                        //       minWidth: constraints.minWidth,
                        //       maxWidth: constraints.maxWidth -
                        //           payload.textPadding.horizontal,
                        //     );

                        //   return Column(
                        //     mainAxisSize: MainAxisSize.min,
                        //     children: [
                        //       Text(
                        //         payload.text!.data!,
                        //         style: payload.text?.style,
                        //         maxLines: isDrawerOpen ? null : 2,
                        //         overflow: isDrawerOpen
                        //             ? null
                        //             : TextOverflow.ellipsis,
                        //       ),
                        //       if (!isDrawerOpen &&
                        //           textPainter.didExceedMaxLines)
                        //         payload.showMoreButton!
                        //     ],
                        //   );
                        // }

                        return ExpandableText(
                          widget.text.data!,
                          maxLines: 2,
                          buttonLabelClosed: widget.readMoreTextExpanded,
                          buttonLabelOpened: widget.readMoreTextCollapsed,
                          isExpanded: isExpanded,
                          style: widget.text.style,
                          buttonTextStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    )),
              ),
              if (widget.isExpandable)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: onChangeHandler,
                  ),
                ),
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
