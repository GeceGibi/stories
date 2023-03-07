import 'package:flutter/material.dart';
import 'package:story/story.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StoryExample(),
    );
  }
}

class StoryExample extends StatefulWidget {
  const StoryExample({super.key});

  @override
  State<StoryExample> createState() => _StoryExampleState();
}

class _StoryExampleState extends State<StoryExample> {
  final pageController = PageController(keepPage: true);
  var _currentPage = 0.0;

  void onCompleteHandler() {
    if ((pageController.page ?? 9) < 9) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutQuart,
      );
    }
  }

  void onGoBackHandler() {
    if ((pageController.page ?? 0) > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutQuart,
      );
    }
  }

  var videos = <Map<String, dynamic>>[
    {
      'url':
          'https://vod-progressive.akamaized.net/exp=1678202424~acl=%2Fvimeo-prod-skyfire-std-us%2F01%2F3133%2F31%2F790665520%2F3538556238.mp4~hmac=d525f218c52b55f3fd63fde48883f976a061f4c3456247169ea13a341496df8c/vimeo-prod-skyfire-std-us/01/3133/31/790665520/3538556238.mp4?filename=file.mp4',
      'duration': 7400,
    },
    {
      'url':
          'https://vod-progressive.akamaized.net/exp=1678204343~acl=%2Fvimeo-prod-skyfire-std-us%2F01%2F1409%2F23%2F582045070%2F2748544864.mp4~hmac=ddc197984f6579ef712aff3cd52bafd04a1f8d0fe01a1ab030173d6aff949bd1/vimeo-prod-skyfire-std-us/01/1409/23/582045070/2748544864.mp4',
      'duration': 15000,
    },
    {
      'url':
          'https://vod-progressive.akamaized.net/exp=1678204629~acl=%2Fvimeo-prod-skyfire-std-us%2F01%2F2604%2F21%2F538024651%2F2548878064.mp4~hmac=1ec46a58b65023648ebcc264d3acd45656f46d98af5f1780946af3b8c33acb01/vimeo-prod-skyfire-std-us/01/2604/21/538024651/2548878064.mp4',
      'duration': 10000,
    }
  ];

  late final imageStories = List.generate(10, (index) {
    return ImageStory(
      image: NetworkImage('https://api.lorem.space/image?t=$index'),
      useImageBlurredEffect: true,
      textPadding: const EdgeInsets.all(20).copyWith(
        bottom: MediaQuery.of(context).padding.bottom,
      ),
      text: Text(
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit.' * index,
        style: const TextStyle(color: Colors.white),
      ),
    );
  });

  late final videoStories = videos.map((e) {
    return Story(
      paused: true,
      duration: Duration(milliseconds: e['duration']),
      builder: (context, controller) {
        return Stack(
          fit: StackFit.expand,
          children: [
            VideoApp(
              onStarted: () => controller.resume(),
              url: e['url'],
            ),
            Positioned.fill(
              child: StoryPagerGestures(
                controller: controller,
                onStateChange: (isHolding) {
                  // if (isHolding) {
                  //   videoController.pause();
                  // } else {
                  //   videoController.play();
                  // }
                },
              ),
            ),
          ],
        );
      },
    );
  }).toList();

  late final textStories = videos.map((e) {
    return Story(
      builder: (context, controller) {
        return ColoredBox(
          color: Colors.blue,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: Center(
                  child: Text(e['url']),
                ),
              ),
              Positioned.fill(
                child: StoryPagerGestures(controller: controller),
              ),
            ],
          ),
        );
      },
    );
  }).toList();

  late final _pages = [
    StoryPage(
      stories: imageStories,
      options: StoryPagerOptions(
        padding: const EdgeInsets.all(12).copyWith(
          top: MediaQuery.of(context).padding.top,
        ),
      ),
    ),
    StoryPage(
      stories: textStories,
      options: StoryPagerOptions(
        padding: const EdgeInsets.all(12).copyWith(
          top: MediaQuery.of(context).padding.top,
        ),
      ),
    ),
    StoryPage(
      stories: videoStories,
      options: StoryPagerOptions(
        padding: const EdgeInsets.all(12).copyWith(
          top: MediaQuery.of(context).padding.top,
        ),
      ),
    )
  ];

  @override
  void initState() {
    super.initState();
    pageController.addListener(() {
      setState(() {
        _currentPage = pageController.page ?? 0.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      itemCount: _pages.length,
      controller: pageController,
      itemBuilder: (BuildContext context, int index) {
        final position = _currentPage - index;

        return Transform(
          transform: Matrix4.identity()
            ..rotateZ(position * 0.1)
            ..invert(),
          alignment: Alignment.bottomCenter,
          child: _pages[index],
        );
      },
    );
  }
}

class VideoApp extends StatefulWidget {
  const VideoApp({
    required this.onStarted,
    required this.url,
    super.key,
  });

  final void Function() onStarted;
  final String url;

  @override
  State<VideoApp> createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  late final controller = VideoPlayerController.network(widget.url);

  Future<void> init() async {
    await controller.initialize();

    controller.play();
    controller.setVolume(1);
    controller.setLooping(false);

    controller.addListener(() {
      if (controller.value.isPlaying) {
        widget.onStarted();
      }
    });

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    if (controller.value.isInitialized) {
      return Center(
        child: AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: VideoPlayer(controller),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
