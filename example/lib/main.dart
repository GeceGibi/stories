import 'package:flutter/material.dart';
import 'package:story/story.dart';

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
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return StoryPage(
      items: List.generate(10, (index) {
        return StoryPagePayload(
          useImageBlurredEffect: true,
          text: const Text(
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque eleifend eget nulla ut ultricies. Aenean et pretium tortor, quis vulputate erat. Suspendisse dignissim euismod tristique.',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          image: NetworkImage('https://api.lorem.space/image?t=$index'),
        );
      }).toList(),
    );
  }
}
