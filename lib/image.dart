part of story;

class _StoryImage extends StatefulWidget {
  const _StoryImage(
    this.imageProvider, {
    this.fit = BoxFit.contain,
    this.height,
    this.width,
    super.key,
  });

  final ImageProvider imageProvider;
  final BoxFit fit;
  final double? height;
  final double? width;

  @override
  State<_StoryImage> createState() => _StoryImageState();
}

class _StoryImageState extends State<_StoryImage> {
  ImageStream? _imageStream;
  ImageInfo? _imageInfo;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getImage();
  }

  @override
  void didUpdateWidget(_StoryImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageProvider != oldWidget.imageProvider) {
      _getImage();
    }
  }

  void _getImage() {
    final oldImageStream = _imageStream;

    ///
    _imageStream = widget.imageProvider.resolve(
      createLocalImageConfiguration(context),
    );

    ///
    if (_imageStream!.key != oldImageStream?.key) {
      final listener = ImageStreamListener(_updateImage);
      oldImageStream?.removeListener(listener);
      _imageStream!.addListener(listener);
    }
  }

  void _updateImage(ImageInfo imageInfo, bool synchronousCall) {
    setState(() {
      _imageInfo?.dispose();
      _imageInfo = imageInfo;
    });
  }

  @override
  void dispose() {
    _imageStream?.removeListener(ImageStreamListener(_updateImage));
    _imageInfo?.dispose();
    _imageInfo = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawImage(
      image: _imageInfo?.image,
      scale: _imageInfo?.scale ?? 1.0,
      height: widget.height,
      width: widget.width,
      fit: widget.fit,
    );
  }
}
