// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// // ------------------ DATA MODELS ------------------

// class Session {
//   final Metadata metadata;
//   final Assets assets;
//   final List<Sequence> sequence;

//   Session(
//       {required this.metadata, required this.assets, required this.sequence});

//   factory Session.fromJson(Map<String, dynamic> json) {
//     return Session(
//       metadata: Metadata.fromJson(json['metadata']),
//       assets: Assets.fromJson(json['assets']),
//       sequence:
//           (json['sequence'] as List).map((s) => Sequence.fromJson(s)).toList(),
//     );
//   }
// }

// class Metadata {
//   final String id, title, category, tempo;
//   final int defaultLoopCount;

//   Metadata({
//     required this.id,
//     required this.title,
//     required this.category,
//     required this.defaultLoopCount,
//     required this.tempo,
//   });

//   factory Metadata.fromJson(Map<String, dynamic> json) {
//     return Metadata(
//       id: json['id'],
//       title: json['title'],
//       category: json['category'],
//       defaultLoopCount: json['defaultLoopCount'],
//       tempo: json['tempo'],
//     );
//   }
// }

// class Assets {
//   final Map<String, String> images;
//   final Map<String, String> audio;

//   Assets({required this.images, required this.audio});

//   factory Assets.fromJson(Map<String, dynamic> json) {
//     return Assets(
//       images: Map<String, String>.from(json['images']),
//       audio: Map<String, String>.from(json['audio']),
//     );
//   }
// }

// class Sequence {
//   final String type, name, audioRef;
//   final int durationSec;
//   final int? iterations;
//   final bool? loopable;
//   final List<ScriptEntry> script;

//   Sequence({
//     required this.type,
//     required this.name,
//     required this.audioRef,
//     required this.durationSec,
//     this.iterations,
//     this.loopable,
//     required this.script,
//   });

//   factory Sequence.fromJson(Map<String, dynamic> json) {
//     return Sequence(
//       type: json['type'],
//       name: json['name'],
//       audioRef: json['audioRef'],
//       durationSec: json['durationSec'],
//       iterations: json['iterations'] is String ? null : json['iterations'],
//       loopable: json['loopable'],
//       script:
//           (json['script'] as List).map((s) => ScriptEntry.fromJson(s)).toList(),
//     );
//   }
// }

// class ScriptEntry {
//   final String text, imageRef;
//   final int startSec, endSec;

//   ScriptEntry({
//     required this.text,
//     required this.imageRef,
//     required this.startSec,
//     required this.endSec,
//   });

//   factory ScriptEntry.fromJson(Map<String, dynamic> json) {
//     return ScriptEntry(
//       text: json['text'],
//       imageRef: json['imageRef'],
//       startSec: json['startSec'],
//       endSec: json['endSec'],
//     );
//   }
// }

// // ------------------ MAIN APP ------------------

// void main() {
//   runApp(const YogaApp());
// }

// class YogaApp extends StatelessWidget {
//   const YogaApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Modular Yoga Session',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: const SessionLoader(),
//     );
//   }
// }

// // ------------------ LOAD JSON ------------------

// class SessionLoader extends StatefulWidget {
//   const SessionLoader({super.key});

//   @override
//   State<SessionLoader> createState() => _SessionLoaderState();
// }

// class _SessionLoaderState extends State<SessionLoader> {
//   Session? session;
//   bool loading = true;

//   @override
//   void initState() {
//     super.initState();
//     loadSession();
//   }

//   Future<void> loadSession() async {
//     final jsonStr = await rootBundle.loadString('assets/poses/CatCowJson.json');
//     final jsonData = jsonDecode(jsonStr);
//     // Handle {{loopCount}} replacement
//     for (var seq in jsonData['sequence']) {
//       if (seq['iterations'] is String &&
//           seq['iterations'].contains('{{loopCount}}')) {
//         seq['iterations'] = jsonData['metadata']['defaultLoopCount'];
//       }
//     }
//     setState(() {
//       session = Session.fromJson(jsonData);
//       loading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (loading) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }
//     return PosePreviewPage(session: session!);
//   }
// }

// // ------------------ PREVIEW PAGE ------------------

// class PosePreviewPage extends StatelessWidget {
//   final Session session;
//   const PosePreviewPage({super.key, required this.session});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(session.metadata.title)),
//       body: ListView.builder(
//         itemCount: session.sequence.length,
//         itemBuilder: (context, index) {
//           final seq = session.sequence[index];
//           return ListTile(
//             title: Text(seq.name),
//             subtitle: Text("${seq.durationSec} sec"),
//             leading: Image.asset(
//               'assets/images/${session.assets.images[seq.script.first.imageRef]}',
//               width: 50,
//             ),
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => YogaHomePage(session: session),
//             ),
//           );
//         },
//         label: const Text("Start Session"),
//         icon: const Icon(Icons.play_arrow),
//       ),
//     );
//   }
// }

// // ------------------ YOGA PLAYER PAGE ------------------

// class YogaHomePage extends StatefulWidget {
//   final Session session;
//   const YogaHomePage({super.key, required this.session});

//   @override
//   State<YogaHomePage> createState() => _YogaHomePageState();
// }

// class _YogaHomePageState extends State<YogaHomePage> {
//   late AudioPlayer _player;
//   int seqIndex = 0;
//   int loopCounter = 0;
//   Duration currentPos = Duration.zero;
//   bool isPlaying = false;
//   StreamSubscription<Duration>? _posSub;

//   @override
//   void initState() {
//     super.initState();
//     _player = AudioPlayer();
//   }

//   @override
//   void dispose() {
//     _posSub?.cancel();
//     _player.dispose();
//     super.dispose();
//   }

//   Future<void> startSession() async {
//     seqIndex = 0;
//     loopCounter = 0;
//     isPlaying = true;
//     await playSequence();
//   }

//   Future<void> playSequence() async {
//     if (seqIndex >= widget.session.sequence.length) {
//       isPlaying = false;
//       saveStreak();
//       setState(() {});
//       return;
//     }

//     final seq = widget.session.sequence[seqIndex];
//     final audioFile = widget.session.assets.audio[seq.audioRef] ?? seq.audioRef;

//     await _player.stop();
//     await _player.play(AssetSource('audio/$audioFile'));

//     _posSub?.cancel();
//     _posSub = _player.onPositionChanged.listen((pos) {
//       setState(() => currentPos = pos);
//     });

//     _player.onPlayerComplete.listen((_) async {
//       if (seq.type == "loop") {
//         loopCounter++;
//         if (loopCounter < (seq.iterations ?? 1)) {
//           await playSequence();
//           return;
//         }
//       }
//       loopCounter = 0;
//       seqIndex++;
//       if (seqIndex < widget.session.sequence.length) {
//         await playSequence();
//       } else {
//         isPlaying = false;
//         saveStreak();
//         setState(() {});
//       }
//     });
//   }

//   void togglePlayPause() {
//     if (isPlaying) {
//       _player.pause();
//     } else {
//       _player.resume();
//     }
//     setState(() => isPlaying = !isPlaying);
//   }

//   Future<void> saveStreak() async {
//     final prefs = await SharedPreferences.getInstance();
//     final today = DateTime.now();
//     final lastDateStr = prefs.getString('lastSessionDate');

//     if (lastDateStr != null) {
//       final lastDate = DateTime.parse(lastDateStr);
//       if (today.difference(lastDate).inDays == 1) {
//         prefs.setInt('streak', (prefs.getInt('streak') ?? 0) + 1);
//       } else if (today.difference(lastDate).inDays > 1) {
//         prefs.setInt('streak', 1);
//       }
//     } else {
//       prefs.setInt('streak', 1);
//     }
//     prefs.setString('lastSessionDate', today.toIso8601String());
//   }

//   double getTotalProgress() {
//     final totalDuration = widget.session.sequence
//         .map(
//             (s) => s.durationSec * (s.type == "loop" ? (s.iterations ?? 1) : 1))
//         .reduce((a, b) => a + b);
//     int elapsedBefore = 0;
//     for (var i = 0; i < seqIndex; i++) {
//       final s = widget.session.sequence[i];
//       elapsedBefore +=
//           s.durationSec * (s.type == "loop" ? (s.iterations ?? 1) : 1);
//     }
//     final elapsedNow = currentPos.inSeconds;
//     return (elapsedBefore + elapsedNow) / totalDuration;
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (seqIndex >= widget.session.sequence.length) {
//       return Scaffold(
//         appBar: AppBar(title: Text(widget.session.metadata.title)),
//         body: const Center(
//           child: Text(
//             "Session Complete 🎉",
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//         ),
//       );
//     }

//     final seq = widget.session.sequence[seqIndex];
//     final scriptEntry = seq.script.firstWhere(
//       (s) =>
//           currentPos.inSeconds >= s.startSec && currentPos.inSeconds < s.endSec,
//       orElse: () => seq.script.first,
//     );
//     final imageFile = widget.session.assets.images[scriptEntry.imageRef] ??
//         scriptEntry.imageRef;

//     return Scaffold(
//       appBar: AppBar(title: Text(widget.session.metadata.title)),
//       body: Column(
//         children: [
//           Expanded(
//               child:
//                   Image.asset('assets/images/$imageFile', fit: BoxFit.contain)),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Text(scriptEntry.text,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(fontSize: 18)),
//           ),
//           const SizedBox(height: 10),
//           LinearProgressIndicator(value: getTotalProgress()),
//           const SizedBox(height: 5),
//           LinearProgressIndicator(
//               value: currentPos.inSeconds / seq.durationSec),
//           const SizedBox(height: 20),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               ElevatedButton.icon(
//                 onPressed: togglePlayPause,
//                 icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
//                 label: Text(isPlaying ? "Pause" : "Play"),
//               ),
//               const SizedBox(width: 20),
//               ElevatedButton(
//                 onPressed: startSession,
//                 child: const Text("Restart"),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ------------------ DATA MODELS ------------------

class Session {
  final Metadata metadata;
  final Assets assets;
  final List<Sequence> sequence;

  Session(
      {required this.metadata, required this.assets, required this.sequence});

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      metadata: Metadata.fromJson(json['metadata']),
      assets: Assets.fromJson(json['assets']),
      sequence:
          (json['sequence'] as List).map((s) => Sequence.fromJson(s)).toList(),
    );
  }
}

class Metadata {
  final String id, title, category, tempo;
  final int defaultLoopCount;

  Metadata({
    required this.id,
    required this.title,
    required this.category,
    required this.defaultLoopCount,
    required this.tempo,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) {
    return Metadata(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      defaultLoopCount: json['defaultLoopCount'],
      tempo: json['tempo'],
    );
  }
}

class Assets {
  final Map<String, String> images;
  final Map<String, String> audio;

  Assets({required this.images, required this.audio});

  factory Assets.fromJson(Map<String, dynamic> json) {
    return Assets(
      images: Map<String, String>.from(json['images']),
      audio: Map<String, String>.from(json['audio']),
    );
  }
}

class Sequence {
  final String type, name, audioRef;
  final int durationSec;
  final int? iterations;
  final bool? loopable;
  final List<ScriptEntry> script;

  Sequence({
    required this.type,
    required this.name,
    required this.audioRef,
    required this.durationSec,
    this.iterations,
    this.loopable,
    required this.script,
  });

  factory Sequence.fromJson(Map<String, dynamic> json) {
    return Sequence(
      type: json['type'],
      name: json['name'],
      audioRef: json['audioRef'],
      durationSec: json['durationSec'],
      iterations: json['iterations'] is String ? null : json['iterations'],
      loopable: json['loopable'],
      script:
          (json['script'] as List).map((s) => ScriptEntry.fromJson(s)).toList(),
    );
  }
}

class ScriptEntry {
  final String text, imageRef;
  final int startSec, endSec;

  ScriptEntry({
    required this.text,
    required this.imageRef,
    required this.startSec,
    required this.endSec,
  });

  factory ScriptEntry.fromJson(Map<String, dynamic> json) {
    return ScriptEntry(
      text: json['text'],
      imageRef: json['imageRef'],
      startSec: json['startSec'],
      endSec: json['endSec'],
    );
  }
}

// ------------------ MAIN APP ------------------

void main() {
  runApp(const YogaApp());
}

class YogaApp extends StatelessWidget {
  const YogaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Modular Yoga Session',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SessionLoader(),
    );
  }
}

// ------------------ LOAD JSON ------------------

class SessionLoader extends StatefulWidget {
  const SessionLoader({super.key});

  @override
  State<SessionLoader> createState() => _SessionLoaderState();
}

class _SessionLoaderState extends State<SessionLoader> {
  Session? session;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadSession();
  }

  Future<void> loadSession() async {
    final jsonStr = await rootBundle.loadString('assets/poses/CatCowJson.json');
    final jsonData = jsonDecode(jsonStr);

    // Replace {{loopCount}} with defaultLoopCount from metadata
    for (var seq in jsonData['sequence']) {
      if (seq['iterations'] is String &&
          seq['iterations'].contains('{{loopCount}}')) {
        seq['iterations'] = jsonData['metadata']['defaultLoopCount'];
      }
    }

    setState(() {
      session = Session.fromJson(jsonData);
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return PosePreviewPage(session: session!);
  }
}

// ------------------ PREVIEW PAGE ------------------

class PosePreviewPage extends StatelessWidget {
  final Session session;
  const PosePreviewPage({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(session.metadata.title)),
      body: ListView.builder(
        itemCount: session.sequence.length,
        itemBuilder: (context, index) {
          final seq = session.sequence[index];
          return ListTile(
            title: Text(seq.name),
            subtitle: Text("${seq.durationSec} sec"),
            leading: Image.asset(
              'assets/images/${session.assets.images[seq.script.first.imageRef]}',
              width: 50,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.image_not_supported),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate and start session immediately inside YogaHomePage
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => YogaHomePage(session: session),
            ),
          );
        },
        label: const Text("Start Session"),
        icon: const Icon(Icons.play_arrow),
      ),
    );
  }
}

// ------------------ YOGA PLAYER PAGE ------------------

class YogaHomePage extends StatefulWidget {
  final Session session;
  const YogaHomePage({super.key, required this.session});

  @override
  State<YogaHomePage> createState() => _YogaHomePageState();
}

class _YogaHomePageState extends State<YogaHomePage> {
  late AudioPlayer _player;
  int seqIndex = 0;
  int loopCounter = 0;
  Duration currentPos = Duration.zero;
  bool isPlaying = false;
  bool isSequencePlaying = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();

    _player.onPlayerComplete.listen((_) async {
      if (!isSequencePlaying) return;
      isSequencePlaying = false;

      final seq = widget.session.sequence[seqIndex];

      if (seq.type == "loop") {
        loopCounter++;
        if (loopCounter < (seq.iterations ?? 1)) {
          await playCurrentSequence();
          return;
        }
      }

      loopCounter = 0;
      seqIndex++;
      if (seqIndex < widget.session.sequence.length) {
        await playCurrentSequence();
      } else {
        // Session complete
        isPlaying = false;
        _timer?.cancel();
        await saveStreak();
        setState(() {});
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      startSession();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> startSession() async {
    seqIndex = 0;
    loopCounter = 0;
    isPlaying = true;
    await playCurrentSequence();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) async {
      final pos = await _player.getCurrentPosition();
      if (pos != null) {
        setState(() {
          currentPos = Duration(milliseconds: pos.inMilliseconds);
        });
      }
    });
  }

  Future<void> playCurrentSequence() async {
    final seq = widget.session.sequence[seqIndex];
    final audioFile = widget.session.assets.audio[seq.audioRef] ?? seq.audioRef;

    await _player.stop();
    isSequencePlaying = true;
    await _player.play(AssetSource('audio/$audioFile'));

    setState(() {
      currentPos = Duration.zero;
      isPlaying = true;
    });
  }

  void togglePlayPause() async {
    if (isPlaying) {
      await _player.pause();
      setState(() => isPlaying = false);
    } else {
      await _player.resume();
      setState(() => isPlaying = true);
    }
  }

  Future<void> saveStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final lastDateStr = prefs.getString('lastSessionDate');

    if (lastDateStr != null) {
      final lastDate = DateTime.parse(lastDateStr);
      if (today.difference(lastDate).inDays == 1) {
        prefs.setInt('streak', (prefs.getInt('streak') ?? 0) + 1);
      } else if (today.difference(lastDate).inDays > 1) {
        prefs.setInt('streak', 1);
      }
    } else {
      prefs.setInt('streak', 1);
    }
    prefs.setString('lastSessionDate', today.toIso8601String());
  }

  double getTotalProgress() {
    final totalDuration = widget.session.sequence.fold<int>(0, (sum, s) {
      final iter = s.type == "loop" ? (s.iterations ?? 1) : 1;
      return sum + s.durationSec * iter;
    });

    int elapsedBefore = 0;
    for (var i = 0; i < seqIndex; i++) {
      final s = widget.session.sequence[i];
      final iter = s.type == "loop" ? (s.iterations ?? 1) : 1;
      elapsedBefore += s.durationSec * iter;
    }

    final elapsedNow = currentPos.inSeconds;
    return (elapsedBefore + elapsedNow) / totalDuration;
  }

  @override
  Widget build(BuildContext context) {
    if (seqIndex >= widget.session.sequence.length) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.session.metadata.title)),
        body: const Center(
          child: Text(
            "Session Complete 🎉",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    final seq = widget.session.sequence[seqIndex];

    final scriptEntry = seq.script.firstWhere(
      (s) =>
          currentPos.inSeconds >= s.startSec && currentPos.inSeconds < s.endSec,
      orElse: () => seq.script.first,
    );

    final imageFile = widget.session.assets.images[scriptEntry.imageRef] ??
        scriptEntry.imageRef;

    return Scaffold(
      appBar: AppBar(title: Text(widget.session.metadata.title)),
      body: Column(
        children: [
          Expanded(
            child: Image.asset(
              'assets/images/$imageFile',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Center(child: Text('Image not found')),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              scriptEntry.text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(value: getTotalProgress()),
          const SizedBox(height: 5),
          LinearProgressIndicator(
              value: currentPos.inSeconds / seq.durationSec),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: togglePlayPause,
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                label: Text(isPlaying ? "Pause" : "Play"),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () => startSession(),
                child: const Text("Restart"),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
