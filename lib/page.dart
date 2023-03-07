part of story;

enum StoryType { image, text, custom }

class Story {
  const Story({
    required this.builder,
    this.duration = const Duration(seconds: 5),
    this.paused = false,
  }) : type = StoryType.custom;

  final StoryType type;
  final Duration duration;
  final bool paused;

  final Widget Function(
    BuildContext context,
    StoryPagerController controller,
  ) builder;

  StoryPagerItemOptions toItemOptions() => StoryPagerItemOptions(
        duration: duration,
        paused: paused,
      );
}

class ImageStory extends Story {
  ImageStory({
    required this.image,
    this.constraints = const BoxConstraints(maxHeight: 280),
    this.backgroundColor = const Color(0x00000000),
    this.useImageBlurredEffect = false,
    this.showMoreButton,
    this.textPadding = const EdgeInsets.all(12),
    this.text,
    super.duration,
  }) : super(
          builder: (_, controller) {
            return Positioned.fill(
              child: Stack(
                children: [
                  ColoredBox(color: backgroundColor),
                  if (useImageBlurredEffect)
                    Positioned.fill(
                      child: ClipRRect(
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                          child: _StoryImage(image, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  Positioned.fill(child: _StoryImage(image)),
                  Positioned.fill(
                    child: StoryPagerGestures(controller: controller),
                  ),
                  if (text != null)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      left: 0,
                      child: StoryExpandable(
                        text: text,
                        padding: textPadding,
                        constraints: constraints,
                        backgroundColorCollapsed: Colors.black.withOpacity(0.2),
                        onChange: (isExpanded) {
                          if (isExpanded) {
                            controller.pause();
                          } else {
                            controller.resume();
                          }
                        },
                      ),
                    )
                ],
              ),
            );
          },
        );

  @override
  StoryType get type => StoryType.image;

  /// Image
  final ImageProvider image;
  final bool useImageBlurredEffect;

  /// Core
  final Color backgroundColor;

  ///
  final Text? text;
  final Widget? showMoreButton;
  final EdgeInsets textPadding;
  final BoxConstraints constraints;
}

class StoryPage<T extends Story> extends StatefulWidget {
  const StoryPage({
    required this.stories,
    this.onChange,
    this.onPageComplete,
    this.onPageGoBack,
    this.viewedCount = 0,
    this.options = const StoryPagerOptions(),
    super.key,
  });

  /// Callbacks
  final void Function()? onPageComplete;
  final void Function()? onPageGoBack;
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
  final pagerController = StoryPagerController();
  late var index = widget.viewedCount;

  void onPageChangeHandler(int i) {
    setState(() {
      index = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.stories[index];

    pagerController.index = index;

    switch (story.type) {
      ///
      case StoryType.image:
        return Stack(
          children: [
            story.builder(context, pagerController),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: StoryPager(
                options: widget.options,
                initialIndex: widget.viewedCount,
                onChange: onPageChangeHandler,
                controller: pagerController,
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
            story.builder(context, pagerController),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: StoryPager(
                options: widget.options,
                initialIndex: widget.viewedCount,
                onChange: onPageChangeHandler,
                controller: pagerController,
                stories: widget.stories.map((e) => e.toItemOptions()).toList(),
              ),
            ),
          ],
        );
    }
  }
}

// class StoryPage extends StatefulWidget {
//   const StoryPage.custom({
//     required this.itemCount,
//     required this.itemBuilder,
//     this.onWantGoBack,
//     this.onComplete,
//     this.onChange,
//     this.viewedCount = 0,
//     this.pagerOptions = const StoryPagerOptions(),
//     super.key,
//   });

//   // StoryPage.image();
//   // StoryPage.video();
//   // StoryPage.text();

//   final void Function()? onComplete;
//   final void Function()? onWantGoBack;
//   final void Function(int index)? onChange;
//   final int viewedCount;

//   final StoryPagerOptions pagerOptions;

//   final int itemCount;
//   final StoryPagePayload Function(BuildContext, int) itemBuilder;

//   @override
//   State<StoryPage> createState() => _StoryPageState();
// }

// class _StoryPageState extends State<StoryPage> {
//   final pagerController = StoryPagerController();

//   late var index = widget.viewedCount;
//   var isDrawerOpen = false;

//   void drawerOpenedHandler() {
//     pagerController.pause();
//     setState(() {
//       isDrawerOpen = true;
//     });
//   }

//   void drawerClosedHandler() {
//     pagerController.resume();
//     setState(() {
//       isDrawerOpen = false;
//     });
//   }

//   Future<bool> onWillPopScope() async {
//     if (isDrawerOpen) {
//       drawerClosedHandler();
//       return false;
//     }

//     return true;
//   }

//   void onChangeHandler(int index) {
//     drawerClosedHandler();

//     setState(() {
//       this.index = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final payload = widget.itemBuilder(context, index);

//     return LayoutBuilder(builder: (context, constraints) {
//       return WillPopScope(
//         onWillPop: onWillPopScope,
//         child: Material(
//           color: Colors.white,
//           type: MaterialType.card,
//           child: Stack(
//             children: [
//               ColoredBox(color: payload.backgroundColor),
//               if (payload.image != null && payload.useImageBlurredEffect)
//                 Positioned.fill(
//                   child: ClipRRect(
//                     child: ImageFiltered(
//                       imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
//                       child: _StoryImage(payload.image!, fit: BoxFit.cover),
//                     ),
//                   ),
//                 ),
//               if (payload.image != null)
//                 Positioned.fill(
//                   child: _StoryImage(payload.image!),
//                 ),
//               Positioned.fill(
//                 child: StoryPager(
//                   storyCount: widget.itemCount,
//                   controller: pagerController,
//                   onChange: onChangeHandler,
//                   onComplete: widget.onComplete,
//                   onGoBack: widget.onWantGoBack,
//                   initialIndex: index,
//                   options: widget.pagerOptions,
//                 ),
//               ),
              // if (payload.text != null)
              //   Positioned(
              //     bottom: 0,
              //     right: 0,
              //     left: 0,
              //     child: StoryExpandable(
              //       constraints: BoxConstraints(
              //         maxHeight: constraints.maxHeight * 0.4,
              //       ),
              //       text: payload.text!,
              //       isOpen: isDrawerOpen,
              //       backgroundColorCollapsed: Colors.black.withOpacity(0.2),
              //       onChange: (isExpanded) {
              //         if (isExpanded) {
              //           drawerOpenedHandler();
              //         } else {
              //           drawerClosedHandler();
              //         }
              //       },
              //     ),
              //   )
//             ],
//           ),
//         ),
//       );
//     });
//   }
// }
