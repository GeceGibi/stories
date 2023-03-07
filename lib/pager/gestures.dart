part of 'pager.dart';

class StoryPagerGestures extends StatelessWidget {
  StoryPagerGestures({
    required this.controller,
    this.onStateChange,
    super.key,
  });

  final StoryPagerController controller;
  final void Function(bool isHolding)? onStateChange;

  var isHolding = false;

  Timer? holdingTimer;
  final holdDuration = const Duration(milliseconds: 100);

  void onTapDownHandler(_) {
    holdingTimer?.cancel();
    holdingTimer = Timer(holdDuration, () {
      isHolding = true;
      onStateChange?.call(isHolding);
      controller.pause();
    });
  }

  void onTapUpHandler(_) {
    holdingTimer?.cancel();
    holdingTimer = Timer(holdDuration, () {
      if (isHolding) {
        isHolding = false;
        onStateChange?.call(isHolding);
        controller.resume();
      }
    });
  }

  void goPrevHandler() {
    if (isHolding) {
      return;
    }

    controller.goPrevPage();
  }

  void goNextHandler() {
    if (isHolding) {
      return;
    }

    controller.goNextPage();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: goPrevHandler,
            onTapUp: onTapUpHandler,
            onTapDown: onTapDownHandler,
            onTapCancel: () => onTapUpHandler(null),
          ),
        ),
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: goNextHandler,
            onTapUp: onTapUpHandler,
            onTapDown: onTapDownHandler,
            onTapCancel: () => onTapUpHandler(null),
          ),
        ),
      ],
    );
  }
}
