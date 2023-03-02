// ignore_for_file: no_leading_underscores_for_local_identifiers

part of story;

class StoryBarItem<T> {
  StoryBarItem({
    required this.image,
    required this.value,
    this.borderWidth,
    this.borderColor,
    this.isViewed = false,
    this.borderCount,
    this.borderSeparatorWidth,
  });

  final T value;
  final ImageProvider image;
  final double? borderWidth;
  final Color? borderColor;
  final int? borderCount;
  final double? borderSeparatorWidth;
  final bool isViewed;
}

class StoryBar<T> extends StatelessWidget {
  const StoryBar({
    required this.items,
    this.onTap,
    this.borderColor = const Color(0xff000000),
    this.borderWidth = 1.0,
    this.size = 48.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
    this.separatorWidth = 12.0,
    this.borderImageGap = 4.0,
    super.key,
  });

  final double size;
  final void Function(T item)? onTap;
  final List<StoryBarItem<T>> items;
  final double borderWidth;
  final Color borderColor;
  final EdgeInsets padding;
  final double separatorWidth;
  final double borderImageGap;

  @override
  Widget build(BuildContext context) {
    final viewed = items.where((e) => e.isViewed).toList();
    final unViewed = items.where((e) => !e.isViewed).toList();

    final sortedList = [...unViewed, ...viewed];

    return SizedBox(
      height: size + max(12, padding.vertical),
      child: ListView.separated(
        padding: padding,
        separatorBuilder: (_, __) => SizedBox(width: separatorWidth),
        scrollDirection: Axis.horizontal,
        itemCount: sortedList.length,
        itemBuilder: (context, index) {
          final item = sortedList.elementAt(index);

          final _borderWidth = item.borderWidth ?? borderWidth;
          final _borderColor = item.borderColor ?? borderColor;
          final _borderCount = item.borderCount ?? 4;
          final _borderSeparatorWidth = item.borderSeparatorWidth ?? 4;

          return Opacity(
            opacity: item.isViewed ? 0.6 : 1,
            child: GestureDetector(
              onTap: () => onTap?.call(item.value),
              child: SizedBox(
                height: size,
                width: size,
                child: CustomPaint(
                    painter: DottedBorder(
                      borderWidth: _borderWidth,
                      borderColor: _borderColor,
                      borderCount: _borderCount,
                      separatorWidth: _borderSeparatorWidth,
                    ),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(borderImageGap),
                        child: SizedBox.expand(
                          child: ClipOval(
                            child: _StoryImage(
                              item.image,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    )),
              ),
            ),
          );
        },
      ),
    );
  }
}

class DottedBorder extends CustomPainter {
  final Color borderColor;
  final double borderWidth;
  final int borderCount;
  final double separatorWidth;

  DottedBorder({
    this.borderCount = 10,
    this.separatorWidth = 10,
    this.borderWidth = 4,
    this.borderColor = const Color(0xff000000),
  });

  //start of the arc painting in degree(0-360)
  double startOfArcInDegree = 0;

  // drawArc deals with rads, easier for me to use degrees
  // so this takes a degree and change it to rad
  double inRads(double degree) {
    return (degree * pi) / 180;
  }

  @override
  bool shouldRepaint(DottedBorder oldDelegate) {
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    //circle angle is 360, remove all space arcs between the main story arc (the number of spaces(stories) times the  space length
    //then subtract the number from 360 to get ALL arcs length
    //then divide the ALL arcs length by number of Arc (number of stories) to get the exact length of one arc
    double arcLength = (360 - (borderCount * separatorWidth)) / borderCount;

    //be careful here when arc is a negative number
    //that happens when the number of spaces is more than 360
    //feel free to use what logic you want to take care of that
    //note that numberOfStories should be limited too here
    if (arcLength <= 0) {
      arcLength = 360 / separatorWidth - 1;
    }

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    //looping for number of stories to draw every story arc
    for (int i = 0; i < borderCount; i++) {
      //printing the arc
      canvas.drawArc(
        rect,
        inRads(startOfArcInDegree),
        //be careful here is:  "double sweepAngle", not "end"
        inRads(arcLength),
        false,
        Paint()
          ..color = borderColor
          ..strokeWidth = borderWidth
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke,
      );

      //the logic of spaces between the arcs is to start the next arc after jumping the length of space
      startOfArcInDegree += arcLength + separatorWidth;
    }
  }
}
