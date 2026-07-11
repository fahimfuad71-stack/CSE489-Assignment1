import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const MyApp());
}

const MethodChannel broadcastChannel = MethodChannel(
  'cse489_assignment_2_23141013/broadcast',
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CSE 489 Assignment 2',
      theme: ThemeData(
        useMaterial3: false,
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFFFCF9FF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
      ),
      home: const HomePage(),
    );
  }
}

// ============================================================
// HOME PAGE AND DRAWER
// ============================================================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedPage = 0;

  final List<Widget> pages = const [
    BroadcastSelectionPage(),
    ImageScalePage(),
    VideoPage(),
    AudioPage(),
  ];

  void openPage(int index) {
    setState(() {
      selectedPage = index;
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App')),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.only(top: 20),
            children: [
              ListTile(
                title: const Text('Broadcast Receiver'),
                onTap: () => openPage(0),
              ),
              ListTile(
                title: const Text('Image Scale'),
                onTap: () => openPage(1),
              ),
              ListTile(title: const Text('Video'), onTap: () => openPage(2)),
              ListTile(title: const Text('Audio'), onTap: () => openPage(3)),
            ],
          ),
        ),
      ),
      body: pages[selectedPage],
    );
  }
}

// ============================================================
// BROADCAST SELECTION
// ============================================================

class BroadcastSelectionPage extends StatefulWidget {
  const BroadcastSelectionPage({super.key});

  @override
  State<BroadcastSelectionPage> createState() => _BroadcastSelectionPageState();
}

class _BroadcastSelectionPageState extends State<BroadcastSelectionPage> {
  String selectedType = 'Custom broadcast receiver';

  final List<String> broadcastTypes = [
    'Custom broadcast receiver',
    'System battery notification receiver',
  ];

  void proceed() {
    final Widget nextPage = selectedType == 'Custom broadcast receiver'
        ? const CustomInputPage()
        : const BatteryPage();

    Navigator.push(context, MaterialPageRoute(builder: (context) => nextPage));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          const SizedBox(height: 30),
          const Text('Select a broadcast type', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 20),
          DropdownButton<String>(
            value: selectedType,
            isExpanded: true,
            items: broadcastTypes.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedType = value;
                });
              }
            },
          ),
          const SizedBox(height: 40),
          ElevatedButton(onPressed: proceed, child: const Text('Proceed')),
        ],
      ),
    );
  }
}

// ============================================================
// CUSTOM BROADCAST INPUT
// ============================================================

class CustomInputPage extends StatefulWidget {
  const CustomInputPage({super.key});

  @override
  State<CustomInputPage> createState() => _CustomInputPageState();
}

class _CustomInputPageState extends State<CustomInputPage> {
  final TextEditingController messageController = TextEditingController();

  void sendMessage() {
    final String message = messageController.text.trim();

    if (message.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a message.')));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomResultPage(message: message),
      ),
    );
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Broadcast')),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const SizedBox(height: 30),
            const Text('Enter a text message', style: TextStyle(fontSize: 17)),
            const SizedBox(height: 25),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(onPressed: sendMessage, child: const Text('Send')),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// CUSTOM BROADCAST RESULT
// ============================================================

class CustomResultPage extends StatefulWidget {
  final String message;

  const CustomResultPage({super.key, required this.message});

  @override
  State<CustomResultPage> createState() => _CustomResultPageState();
}

class _CustomResultPageState extends State<CustomResultPage> {
  late final Future<String?> result;

  @override
  void initState() {
    super.initState();

    result = broadcastChannel.invokeMethod<String>('sendCustomBroadcast', {
      'message': widget.message,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Receiver')),
      body: Center(
        child: FutureBuilder<String?>(
          future: result,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(25),
                child: Text(
                  'Error: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Message received:', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 15),
                Text(
                  snapshot.data ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ============================================================
// BATTERY BROADCAST
// ============================================================

class BatteryPage extends StatefulWidget {
  const BatteryPage({super.key});

  @override
  State<BatteryPage> createState() => _BatteryPageState();
}

class _BatteryPageState extends State<BatteryPage> {
  late final Future<int?> batteryResult;

  @override
  void initState() {
    super.initState();

    batteryResult = broadcastChannel.invokeMethod<int>('getBatteryPercentage');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Battery Receiver')),
      body: Center(
        child: FutureBuilder<int?>(
          future: batteryResult,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (snapshot.hasError) {
              return Text(
                'Error: ${snapshot.error}',
                textAlign: TextAlign.center,
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.battery_full, size: 80, color: Colors.green),
                const SizedBox(height: 15),
                const Text(
                  'Current battery percentage',
                  style: TextStyle(fontSize: 17),
                ),
                const SizedBox(height: 10),
                Text(
                  '${snapshot.data ?? 0}%',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ============================================================
// IMAGE SCALE
// ============================================================

class ImageScalePage extends StatelessWidget {
  const ImageScalePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Use two fingers to zoom the image',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: Image.network(
                'https://picsum.photos/id/10/1000/700',
                fit: BoxFit.contain,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) {
                    return child;
                  }

                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Text(
                      'Image could not be loaded.\n'
                      'Check the internet connection.',
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// VIDEO
// ============================================================

class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late final VideoPlayerController videoController;
  late final Future<void> initializeVideo;

  @override
  void initState() {
    super.initState();

    videoController = VideoPlayerController.asset(
      'assets/video/sample_video.mp4',
    );

    initializeVideo = videoController.initialize();
  }

  Future<void> playOrPause() async {
    if (videoController.value.isPlaying) {
      await videoController.pause();
    } else {
      await videoController.play();
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: initializeVideo,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Video could not be loaded.'));
        }

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AspectRatio(
                aspectRatio: videoController.value.aspectRatio,
                child: VideoPlayer(videoController),
              ),
              const SizedBox(height: 25),
              ElevatedButton.icon(
                onPressed: playOrPause,
                icon: Icon(
                  videoController.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                ),
                label: Text(videoController.value.isPlaying ? 'Pause' : 'Play'),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================
// AUDIO
// ============================================================

class AudioPage extends StatefulWidget {
  const AudioPage({super.key});

  @override
  State<AudioPage> createState() => _AudioPageState();
}

class _AudioPageState extends State<AudioPage> {
  final AudioPlayer audioPlayer = AudioPlayer();

  PlayerState playerState = PlayerState.stopped;
  StreamSubscription<PlayerState>? stateSubscription;

  @override
  void initState() {
    super.initState();

    stateSubscription = audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          playerState = state;
        });
      }
    });
  }

  Future<void> playOrPause() async {
    if (playerState == PlayerState.playing) {
      await audioPlayer.pause();
    } else if (playerState == PlayerState.paused) {
      await audioPlayer.resume();
    } else {
      await audioPlayer.play(AssetSource('audio/sample_audio.mp3'));
    }
  }

  Future<void> stopAudio() async {
    await audioPlayer.stop();
  }

  @override
  void dispose() {
    stateSubscription?.cancel();
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isPlaying = playerState == PlayerState.playing;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.music_note, size: 90, color: Colors.deepPurple),
        const SizedBox(height: 20),
        const Text(
          'Sample Audio',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: playOrPause,
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              label: Text(isPlaying ? 'Pause' : 'Play'),
            ),
            const SizedBox(width: 15),
            ElevatedButton.icon(
              onPressed: stopAudio,
              icon: const Icon(Icons.stop),
              label: const Text('Stop'),
            ),
          ],
        ),
      ],
    );
  }
}
