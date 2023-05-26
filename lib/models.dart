part of story;

enum StoryType { image, text, custom }

class Story {
  const Story.builder({
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

//! Image Story
class ImageStory extends Story {
  ImageStory({
    required this.image,
    this.constraints = const BoxConstraints(maxHeight: 280),
    this.backgroundColor = const Color(0x00000000),
    this.useImageBlurredEffect = false,
    this.showMoreButton,
    this.textPadding = const EdgeInsets.all(12),
    this.readMoreTextExpanded = 'read less',
    this.readMoreTextCollapsed = 'read more',
    this.text,
    super.duration,
  }) : super.builder(
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
                        readMoreTextExpanded: readMoreTextExpanded,
                        readMoreTextCollapsed: readMoreTextCollapsed,
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
  final String readMoreTextExpanded;
  final String readMoreTextCollapsed;
}
