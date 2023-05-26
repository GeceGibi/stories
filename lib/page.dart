part of story;

class StoryPage<T extends Story> extends StatefulWidget {
  const StoryPage({
    required this.stories,
    this.onChange,
    this.onWantGoNext,
    this.onWantGoPrev,
    this.viewedCount = 0,
    this.options = const StoryPagerOptions(),
    super.key,
  });

  /// Callbacks
  final void Function()? onWantGoNext;
  final void Function()? onWantGoPrev;
  final void Function(int index)? onChange;

  /// Options
  final StoryPagerOptions options;

  /// Base
  final int viewedCount;
  final List<T> stories;

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  final storyController = StoryPagerController();
  late var index = widget.viewedCount;

  void onPageChangeHandler(int i) {
    setState(() {
      index = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.stories[index];

    storyController.index = index;

    switch (story.type) {
      ///
      case StoryType.image:
        return Stack(
          children: [
            story.builder(context, storyController),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: StoryPager(
                options: widget.options,
                initialIndex: widget.viewedCount,
                onChange: onPageChangeHandler,
                controller: storyController,
                onWantGoNext: widget.onWantGoNext,
                onWantGoPrev: widget.onWantGoPrev,
                stories: widget.stories.map((e) => e.toItemOptions()).toList(),
              ),
            ),
          ],
        );

      ///
      case StoryType.text:
        return const SizedBox.shrink();

      ///
      case StoryType.custom:
        return Stack(
          children: [
            story.builder(context, storyController),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: StoryPager(
                options: widget.options,
                initialIndex: widget.viewedCount,
                onChange: onPageChangeHandler,
                controller: storyController,
                onWantGoNext: widget.onWantGoNext,
                onWantGoPrev: widget.onWantGoPrev,
                stories: widget.stories.map((e) => e.toItemOptions()).toList(),
              ),
            ),
          ],
        );
    }
  }
}
