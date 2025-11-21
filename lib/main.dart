import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:typed_data';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vibration/vibration.dart';

void main() {
  runApp(const PianoApp());
}

class PianoApp extends StatelessWidget {
  const PianoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advanced Interactive Rainbow Piano 88 Keys',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PianoScreen(),
    );
  }
}

//  お金表示エフェクト
class MoneyEffect extends StatefulWidget {
  final int amount;
  final Offset position;
  final VoidCallback? onComplete;

  const MoneyEffect({
    Key? key,
    required this.amount,
    required this.position,
    this.onComplete,
  }) : super(key: key);

  @override
  State<MoneyEffect> createState() => _MoneyEffectState();
}

class _MoneyEffectState extends State<MoneyEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _moveAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _moveAnimation = Tween<double>(
      begin: 0.0,
      end: -100.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
    ));
    
    _controller.forward().then((_) {
      if (widget.onComplete != null) {
        widget.onComplete!();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: widget.position.dx - 40,
          top: widget.position.dy + _moveAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange[700],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.yellow, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.8),
                    blurRadius: 15,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Text(
                '+${widget.amount}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      offset: Offset(2, 2),
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

//  寿司が横に流れるウィジェット（超改良版）
class SushiFlow extends StatefulWidget {
  final String sushiPath;
  final double startY;
  final int? targetKeyIndex;
  final VoidCallback? onComplete;
  final VoidCallback? onTap;
  final String id;
  final int? duration; // ミリ秒

  const SushiFlow({
    Key? key,
    required this.sushiPath,
    required this.startY,
    this.targetKeyIndex,
    this.onComplete,
    this.onTap,
    required this.id,
    this.duration,
  }) : super(key: key);

  @override
  State<SushiFlow> createState() => _SushiFlowState();
}

class _SushiFlowState extends State<SushiFlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _positionAnimation;

  @override
  void initState() {
    super.initState();
    
    final duration = Duration(milliseconds: widget.duration ?? 4000);
    
    _controller = AnimationController(
      duration: duration,
      vsync: this,
    );
    
    _positionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));
    
    _controller.forward().then((_) {
      if (widget.onComplete != null) {
        widget.onComplete!();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final screenWidth = MediaQuery.of(context).size.width;
        final sushiWidth = 180.0;
        final left = screenWidth + sushiWidth - (screenWidth + sushiWidth * 2) * _positionAnimation.value;
        
        return Positioned(
          left: left,
          top: widget.startY,
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Image.asset(
                widget.sushiPath,
                width: sushiWidth,
                height: sushiWidth,
                errorBuilder: (context, error, stackTrace) {
                  return SizedBox(width: sushiWidth, height: sushiWidth);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// 巨大波紋エフェクト
class MegaRippleEffect extends StatefulWidget {
  final Color color;
  final double size;
  final Offset position;
  final VoidCallback? onComplete;

  const MegaRippleEffect({
    Key? key,
    required this.color,
    this.size = 200,
    required this.position,
    this.onComplete,
  }) : super(key: key);

  @override
  State<MegaRippleEffect> createState() => _MegaRippleEffectState();
}

class _MegaRippleEffectState extends State<MegaRippleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuart,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0.9,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));
    
    _controller.forward().then((_) {
      if (widget.onComplete != null) {
        widget.onComplete!();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: widget.position.dx - (widget.size * _scaleAnimation.value / 2),
          top: widget.position.dy - (widget.size * _scaleAnimation.value / 2),
          child: Container(
            width: widget.size * _scaleAnimation.value,
            height: widget.size * _scaleAnimation.value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.color.withOpacity(_opacityAnimation.value),
                width: 4,
              ),
              gradient: RadialGradient(
                colors: [
                  widget.color.withOpacity(_opacityAnimation.value * 0.3),
                  widget.color.withOpacity(_opacityAnimation.value * 0.1),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.7, 1.0],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class PianoScreen extends StatefulWidget {
  const PianoScreen({Key? key}) : super(key: key);

  @override
  State<PianoScreen> createState() => _PianoScreenState();
}

class _PianoScreenState extends State<PianoScreen>
    with TickerProviderStateMixin {
  //  C++ネイティブ音声生成（高速化）
  static const platform = MethodChannel('com.example.piano_app/audio');
  bool _useNativeAudio = true; // trueで高速C++版を使用
  final List<AudioPlayer> _audioPlayers = [];
  final List<Map<String, dynamic>> _pianoKeys = [];
  final Set<String> _pressedKeys = <String>{};
  final Set<String> _sustainedKeys = <String>{};
  final Map<String, DateTime> _keyPressStartTimes = {};
  final Map<String, AudioPlayer> _activePlayingKeys = {};
  final List<Widget> _rippleEffects = [];
  final List<Map<String, dynamic>> _sushiEffects = [];
  final List<Widget> _moneyEffects = [];
  final Random _random = Random();
  
  final List<String> _sushiPaths = [
    'assets/sushi/cyutoro.gif',
    'assets/sushi/ebi.gif',
    'assets/sushi/hotate.gif',
    'assets/sushi/ikanosushi.gif',
    'assets/sushi/ikura-1.gif',
    'assets/sushi/kappa.gif',
    'assets/sushi/ootoro.gif',
    'assets/sushi/sabazushi-1.gif',
    'assets/sushi/takonosushi.gif',
    'assets/sushi/takuan02.gif',
    'assets/sushi/tamagoaruku.gif',
    'assets/sushi/uni-1.gif',
    'assets/sushi/いちゃ-2.gif',
    'assets/sushi/119_kappamaki.png',
  ];
  
  //  有名曲のメロディ（ノート名で定義）
  // 🍣 寿司打コース別曲リスト
  final Map<String, List<Map<String, dynamic>>> _courseSongs = {
    '3000': [
      {
        'name': 'きらきら星',
        'notes': ['C4', 'C4', 'G4', 'G4', 'A4', 'A4', 'G4', 'F4', 'F4', 'E4', 'E4', 'D4', 'D4', 'C4'],
        'durations': [0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.8, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.8],
        'difficulty': 'easy',
      },
      {
        'name': 'カエルの歌',
        'notes': ['C4', 'D4', 'E4', 'F4', 'E4', 'D4', 'C4'],
        'durations': [0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.8],
        'difficulty': 'easy',
      },
      {
        'name': 'ちょうちょう',
        'notes': ['G4', 'E4', 'E4', 'F4', 'D4', 'D4', 'C4', 'D4', 'E4', 'F4', 'G4', 'G4', 'G4'],
        'durations': [0.4, 0.4, 0.8, 0.4, 0.4, 0.8, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.8],
        'difficulty': 'easy',
      },
    ],
    '5000': [
      {
        'name': 'ジングルベル',
        'notes': ['E4', 'E4', 'E4', 'E4', 'E4', 'E4', 'E4', 'G4', 'C4', 'D4', 'E4', 'F4', 'F4', 'F4', 'F4', 'F4', 'E4', 'E4', 'E4', 'E4', 'D4', 'D4', 'E4', 'D4', 'G4'],
        'durations': [0.3, 0.3, 0.6, 0.3, 0.3, 0.6, 0.3, 0.3, 0.3, 0.3, 1.2, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.15, 0.15, 0.3, 0.3, 0.3, 0.3, 0.6],
        'difficulty': 'medium',
      },
      {
        'name': 'ハッピーバースデー',
        'notes': ['C4', 'C4', 'D4', 'C4', 'F4', 'E4', 'C4', 'C4', 'D4', 'C4', 'G4', 'F4'],
        'durations': [0.3, 0.3, 0.6, 0.6, 0.6, 1.2, 0.3, 0.3, 0.6, 0.6, 0.6, 1.2],
        'difficulty': 'medium',
      },
      {
        'name': 'メリーさんの羊',
        'notes': ['E4', 'D4', 'C4', 'D4', 'E4', 'E4', 'E4', 'D4', 'D4', 'D4', 'E4', 'G4', 'G4'],
        'durations': [0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.6, 0.3, 0.3, 0.6, 0.3, 0.3, 0.6],
        'difficulty': 'medium',
      },
      {
        'name': 'エリーゼのために',
        'notes': ['E5', 'D#5', 'E5', 'D#5', 'E5', 'B4', 'D5', 'C5', 'A4', 'C4', 'E4', 'A4', 'B4', 'E4', 'G#4', 'B4', 'C5', 'E4', 'E5', 'D#5', 'E5', 'D#5', 'E5', 'B4', 'D5', 'C5', 'A4'],
        'durations': [0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.4, 0.2, 0.2, 0.2, 0.4, 0.2, 0.2, 0.2, 0.4, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.6],
        'difficulty': 'medium',
      },
    ],
    '10000': [
      {
        'name': 'All I Want for Christmas',
        'notes': ['G4', 'C5', 'C5', 'C5', 'B4', 'B4', 'A4', 'A4', 'G4', 'G4', 'G4', 'A4', 'G4', 'F4', 'E4', 'D4', 'C4', 'C4', 'D4', 'E4', 'F4', 'G4', 'A4', 'G4', 'C5', 'C5', 'C5', 'B4', 'A4', 'G4'],
        'durations': [0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.3, 0.15, 0.15, 0.2, 0.2, 0.2, 0.2, 0.2, 0.4, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.6],
        'difficulty': 'hard',
      },
      {
        'name': '天国と地獄',
        'notes': ['C5', 'C5', 'C5', 'A4', 'B4', 'C5', 'C5', 'C5', 'A4', 'B4', 'C5', 'C5', 'C5', 'A4', 'B4', 'C5', 'D5', 'E5', 'F5', 'G5', 'G5', 'G5', 'E5', 'F5', 'G5', 'G5', 'G5', 'C5', 'D5', 'E5', 'F5', 'G5'],
        'durations': [0.15, 0.15, 0.15, 0.15, 0.15, 0.15, 0.15, 0.15, 0.15, 0.15, 0.15, 0.15, 0.15, 0.15, 0.15, 0.2, 0.2, 0.2, 0.2, 0.15, 0.15, 0.15, 0.15, 0.15, 0.15, 0.15, 0.15, 0.15, 0.15, 0.15, 0.15, 0.4],
        'difficulty': 'hard',
      },
      {
        'name': 'トルコ行進曲',
        'notes': ['B4', 'A4', 'G#4', 'A4', 'B4', 'A4', 'G#4', 'A4', 'C5', 'B4', 'A4', 'B4', 'C5', 'B4', 'A4', 'B4', 'D5', 'C5', 'B4', 'A4', 'C5', 'B4', 'A4', 'G#4', 'B4', 'A4'],
        'durations': [0.15, 0.15, 0.15, 0.15, 0.15, 0.15, 0.15, 0.15, 0.15, 0.15, 0.15, 0.15, 0.15, 0.15, 0.15, 0.15, 0.15, 0.15, 0.15, 0.15, 0.15, 0.15, 0.15, 0.15, 0.15, 0.5],
        'difficulty': 'hard',
      },
      {
        'name': 'ラカンパネラ',
        'notes': ['G#5', 'G#5', 'D#5', 'C#5', 'D#5', 'G#5', 'G#5', 'D#5', 'C#5', 'D#5', 'G#5', 'F#5', 'E5', 'D#5', 'C#5', 'B4', 'C#5', 'D#5', 'E5', 'F#5', 'G#5', 'A#5', 'G#5', 'F#5', 'E5', 'D#5'],
        'durations': [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.15, 0.15, 0.15, 0.15, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.3],
        'difficulty': 'hard',
      },
    ],
  };
  
  // 後方互換性のため従来の_songsも保持
  late List<Map<String, dynamic>> _songs;
  
  int _currentSongIndex = 0;
  int _currentNoteIndex = 0;
  
  //  寿司打コース設定
  String _selectedCourse = '3000'; // '3000', '5000', '10000'
  final Map<String, double> _courseSpeeds = {
    '3000': 4000.0,  // 4秒（遅い）
    '5000': 3000.0,  // 3秒（中速）
    '10000': 2000.0, // 2秒（速い）
  };
  final Map<String, int> _courseIntervals = {
    '3000': 3000,  // 3秒間隔
    '5000': 2000,  // 2秒間隔
    '10000': 1500, // 1.5秒間隔
  };
  
  bool _soundEnabled = true;
  bool _chordMode = true;
  bool _sustainMode = false;
  bool _rippleMode = true;
  bool _randomRippleMode = false;
  bool _sushiMode = false;
  bool _gameMode = false;
  bool _autoPlayMode = false; //  自動演奏モード
  int _autoPlaySongIndex = 0; // 現在の自動演奏曲インデックス
  
  int _totalBill = 0;
  
  int _currentPlayerIndex = 0;
  static const int _maxPlayers = 40;

  @override
  void initState() {
    super.initState();
    _songs = _courseSongs[_selectedCourse]!;
    _initializeAudioPlayers();
    _generateAllPianoKeys();
  }

  void _initializeAudioPlayers() async {
    try {
      for (int i = 0; i < _maxPlayers; i++) {
        final player = AudioPlayer();
        await player.setPlayerMode(PlayerMode.lowLatency);
        await player.setVolume(0.75);
        await player.setReleaseMode(ReleaseMode.stop);
        _audioPlayers.add(player);
      }
      print(' 超低遅延音響システム初期化完了 ($_maxPlayers台)');
    } catch (e) {
      print(' オーディオ初期化エラー: $e');
    }
  }

  void _generateAllPianoKeys() {
    final List<String> allNotes = [];
    final List<bool> allBlackKeys = [];
    final List<double> allFrequencies = [];
    
    double a0Frequency = 27.5;
    final notes = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
    final isBlack = [false, true, false, true, false, false, true, false, true, false, true, false];
    
    int pianoKeyIndex = 0;
    
    allNotes.add('A0');
    allBlackKeys.add(false);
    allFrequencies.add(a0Frequency * pow(2, pianoKeyIndex / 12.0));
    pianoKeyIndex++;
    
    allNotes.add('A#0');
    allBlackKeys.add(true);
    allFrequencies.add(a0Frequency * pow(2, pianoKeyIndex / 12.0));
    pianoKeyIndex++;
    
    allNotes.add('B0');
    allBlackKeys.add(false);
    allFrequencies.add(a0Frequency * pow(2, pianoKeyIndex / 12.0));
    pianoKeyIndex++;
    
    for (int octave = 1; octave <= 8; octave++) {
      int noteLimit = (octave == 8) ? 1 : 12;
      for (int noteIndex = 0; noteIndex < noteLimit; noteIndex++) {
        allNotes.add('${notes[noteIndex]}$octave');
        allBlackKeys.add(isBlack[noteIndex]);
        allFrequencies.add(a0Frequency * pow(2, pianoKeyIndex / 12.0));
        pianoKeyIndex++;
      }
    }
    
    for (int i = 0; i < allNotes.length; i++) {
      _pianoKeys.add({
        'note': allNotes[i],
        'frequency': allFrequencies[i],
        'isBlack': allBlackKeys[i],
        'color': allBlackKeys[i] ? Colors.grey[900]! : _getRainbowColor(i),
      });
    }
    
    print(' フル88鍵配列完成: ${_pianoKeys.length}鍵');
  }

  Color _getRainbowColor(int index) {
    final rainbowColors = [
      Colors.red[400]!,
      Colors.orange[400]!,
      Colors.yellow[400]!,
      Colors.green[400]!,
      Colors.blue[400]!,
      Colors.indigo[400]!,
      Colors.purple[400]!,
    ];
    return rainbowColors[index % rainbowColors.length];
  }

  double _calculateWhiteKeyPosition(String note) {
    final noteName = note.replaceAll(RegExp(r'[0-9]'), '');
    final octaveStr = note.replaceAll(RegExp(r'[A-G#]'), '');
    int octave = int.tryParse(octaveStr) ?? 0;
    
    int basePosition = 0;
    
    if (note == 'A0') return 0.0;
    if (note == 'B0') return 1.0;
    
    if (octave >= 1) {
      basePosition = 2;
      basePosition += (octave - 1) * 7;
      
      switch (noteName) {
        case 'C': basePosition += 0; break;
        case 'D': basePosition += 1; break;
        case 'E': basePosition += 2; break;
        case 'F': basePosition += 3; break;
        case 'G': basePosition += 4; break;
        case 'A': basePosition += 5; break;
        case 'B': basePosition += 6; break;
      }
    }
    
    return basePosition.toDouble();
  }

  //  C++ネイティブ音声生成（超高速）
  Future<Uint8List?> _generateNativeWaveData(List<double> frequencies, double duration) async {
    try {
      final result = await platform.invokeMethod('generateWaveNative', {
        'frequencies': frequencies,
        'duration': duration,
      });
      return result as Uint8List;
    } catch (e) {
      print(' Native audio failed, fallback to Dart: $e');
      return null;
    }
  }

  Future<Uint8List> _generateOptimizedHarmonyWaveData(List<double> frequencies, double duration) async {
    // C++ネイティブ版を試行（失敗時はDart版にフォールバック）
    if (_useNativeAudio) {
      final nativeData = await _generateNativeWaveData(frequencies, duration);
      if (nativeData != null) {
        return nativeData;
      }
    }
    
    // 従来のDart版（フォールバック）
    final int sampleRate = 44100;
    final int samples = (sampleRate * duration).round();
    final List<int> audioData = [];

    for (int i = 0; i < samples; i++) {
      double time = i / sampleRate;
      double mixedWave = 0.0;
      
      for (int f = 0; f < frequencies.length; f++) {
        double frequency = frequencies[f];
        
        double fundamental = sin(2 * pi * frequency * time) * 0.6;
        double harmonic2 = sin(2 * pi * frequency * 2 * time) * 0.2;
        double harmonic3 = sin(2 * pi * frequency * 3 * time) * 0.12;
        double harmonic4 = sin(2 * pi * frequency * 4 * time) * 0.06;
        double harmonic5 = sin(2 * pi * frequency * 5 * time) * 0.03;
        
        double noteVolume = 1.0 / sqrt(frequencies.length);
        
        mixedWave += (fundamental + harmonic2 + harmonic3 + harmonic4 + harmonic5) * noteVolume;
      }
      
      double envelope;
      double attackTime = min(0.03, duration * 0.02);
      double decayTime = min(0.10, duration * 0.06);
      double sustainLevel = 0.85;
      double releaseTime = min(0.3, duration * 0.15);
      
      if (time < attackTime) {
        envelope = time / attackTime;
      } else if (time < attackTime + decayTime) {
        envelope = 1.0 - (time - attackTime) / decayTime * (1.0 - sustainLevel);
      } else if (time < duration - releaseTime) {
        envelope = sustainLevel;
      } else {
        envelope = sustainLevel * (1.0 - (time - (duration - releaseTime)) / releaseTime);
      }
      
      if (duration > 2.0) {
        envelope *= 1.2;
      }
      
      mixedWave *= envelope;
      
      if (mixedWave > 0.8) {
        mixedWave = 0.8 + (mixedWave - 0.8) * 0.3;
      } else if (mixedWave < -0.8) {
        mixedWave = -0.8 + (mixedWave + 0.8) * 0.3;
      }
      mixedWave *= 0.9;
      
      int sample = (mixedWave * 32767).round().clamp(-32767, 32767);
      
      audioData.add(sample & 0xFF);
      audioData.add((sample >> 8) & 0xFF);
      audioData.add(sample & 0xFF);
      audioData.add((sample >> 8) & 0xFF);
    }

    final int dataSize = audioData.length;
    final int fileSize = 36 + dataSize;
    
    final header = [
      0x52, 0x49, 0x46, 0x46,
      fileSize & 0xFF, (fileSize >> 8) & 0xFF, (fileSize >> 16) & 0xFF, (fileSize >> 24) & 0xFF,
      0x57, 0x41, 0x56, 0x45,
      0x66, 0x6D, 0x74, 0x20,
      0x10, 0x00, 0x00, 0x00,
      0x01, 0x00,
      0x02, 0x00,
      0x44, 0xAC, 0x00, 0x00,
      0x10, 0xB1, 0x02, 0x00,
      0x04, 0x00,
      0x10, 0x00,
      0x64, 0x61, 0x74, 0x61,
      dataSize & 0xFF, (dataSize >> 8) & 0xFF, (dataSize >> 16) & 0xFF, (dataSize >> 24) & 0xFF,
    ];

    return Uint8List.fromList([...header, ...audioData]);
  }

  void _addMoneyEffect(Offset position) {
    final amounts = [100, 150, 200];
    final amount = amounts[_random.nextInt(amounts.length)];
    
    setState(() {
      _totalBill += amount;
      _moneyEffects.add(
        MoneyEffect(
          amount: amount,
          position: position,
          onComplete: () {
            if (mounted) {
              setState(() {
                _moneyEffects.removeWhere((widget) => widget is MoneyEffect);
              });
            }
          },
        ),
      );
    });
    
    print(' +$amount (合計: $_totalBill)');
  }

  //  寿司タップで曲を再生
  Future<void> _playSongNote(String sushiId) async {
    if (!_soundEnabled) {
      _removeSushi(sushiId);
      return;
    }
    
    final song = _songs[_currentSongIndex];
    final notes = song['notes'] as List<String>;
    final durations = song['durations'] as List<double>;
    
    final noteName = notes[_currentNoteIndex];
    final duration = durations[_currentNoteIndex];
    
    // ノート名から周波数を取得
    final keyData = _pianoKeys.firstWhere(
      (key) => key['note'] == noteName,
      orElse: () => _pianoKeys[40], // デフォルトでC4
    );
    final frequency = keyData['frequency'] as double;
    
    final wavData = await _generateOptimizedHarmonyWaveData([frequency], duration);
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/sushi_${DateTime.now().millisecondsSinceEpoch}.wav');
    await file.writeAsBytes(wavData);
    
    final player = _audioPlayers[_currentPlayerIndex];
    _currentPlayerIndex = (_currentPlayerIndex + 1) % _maxPlayers;
    await player.stop();
    await player.play(DeviceFileSource(file.path));
    
    print(' ${song['name']}: $noteName (${_currentNoteIndex + 1}/${notes.length})');
    
    // 次の音符へ
    _currentNoteIndex++;
    if (_currentNoteIndex >= notes.length) {
      _currentNoteIndex = 0;
      _currentSongIndex = (_currentSongIndex + 1) % _songs.length;
      print(' 曲完了！次: ${_songs[_currentSongIndex]['name']}');
    }
    
    _removeSushi(sushiId);
  }

  void _addSushiEffect(Offset position, {int? targetKeyIndex}) {
    if (!_sushiMode) return;
    
    final sushiPath = _sushiPaths[_random.nextInt(_sushiPaths.length)];
    final sushiId = DateTime.now().millisecondsSinceEpoch.toString() + _random.nextInt(10000).toString();
    
    final screenHeight = MediaQuery.of(context).size.height;
    final startY = screenHeight * (0.25 + _random.nextDouble() * 0.5) - 90;
    
    setState(() {
      _sushiEffects.add({
        'id': sushiId,
        'widget': SushiFlow(
          id: sushiId,
          sushiPath: sushiPath,
          startY: startY,
          targetKeyIndex: targetKeyIndex,
          duration: _courseSpeeds[_selectedCourse]!.toInt(),
          onTap: () async {
            final RenderBox box = context.findRenderObject() as RenderBox;
            _addMoneyEffect(Offset(box.size.width / 2, box.size.height / 2));
            await _playSongNote(sushiId);
          },
          onComplete: () {
            if (mounted) {
              _removeSushi(sushiId);
            }
          },
        ),
      });
    });
  }

  void _removeSushi(String sushiId) {
    setState(() {
      _sushiEffects.removeWhere((item) => item['id'] == sushiId);
    });
  }

  void _addMegaRippleEffect(Color color, Offset position) {
    if (!_rippleMode) return;
    
    Offset effectPosition;
    if (_randomRippleMode) {
      final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final size = renderBox.size;
        effectPosition = Offset(
          _random.nextDouble() * size.width,
          _random.nextDouble() * size.height,
        );
      } else {
        effectPosition = position;
      }
    } else {
      effectPosition = position;
    }
    
    setState(() {
      _rippleEffects.add(
        MegaRippleEffect(
          color: color,
          size: 250,
          position: effectPosition,
          onComplete: () {
            if (mounted) {
              setState(() {
                _rippleEffects.removeWhere((widget) => widget is MegaRippleEffect);
              });
            }
          },
        ),
      );
      
      if (_randomRippleMode && _random.nextBool()) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            setState(() {
              _rippleEffects.add(
                MegaRippleEffect(
                  color: color.withOpacity(0.6),
                  size: 180,
                  position: Offset(
                    effectPosition.dx + _random.nextDouble() * 200 - 100,
                    effectPosition.dy + _random.nextDouble() * 200 - 100,
                  ),
                  onComplete: () {
                    if (mounted) {
                      setState(() {
                        _rippleEffects.removeWhere((widget) => widget is MegaRippleEffect);
                      });
                    }
                  },
                ),
              );
            });
          }
        });
      }
    });
  }

  void _onKeyDown(String note, Offset position) async {
    try {
      final keyData = _pianoKeys.firstWhere((key) => key['note'] == note);
      
      setState(() {
        _pressedKeys.add(note);
        _keyPressStartTimes[note] = DateTime.now();
        if (_sustainMode) {
          _sustainedKeys.add(note);
        }
      });

      if (!_gameMode) {
        _addSushiEffect(position);
      }
      
      _addMegaRippleEffect(keyData['color'], position);

      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 25);
      }
      
      print(' キー押下: $note');
    } catch (e) {
      print(' キー押下エラー: $e');
    }
  }

  void _onKeyUp(String note) async {
    try {
      if (!_keyPressStartTimes.containsKey(note)) return;
      
      final startTime = _keyPressStartTimes[note]!;
      final duration = DateTime.now().difference(startTime).inMilliseconds / 1000.0;
      final adjustedDuration = max(0.25, min(duration, 5.0));
      
      setState(() {
        _pressedKeys.remove(note);
        if (!_sustainMode) {
          _sustainedKeys.remove(note);
        }
        _keyPressStartTimes.remove(note);
      });

      if (_soundEnabled) {
        final activeNotes = _chordMode 
            ? (_sustainMode ? _sustainedKeys.union(_pressedKeys) : _pressedKeys).union({note})
            : {note};
        
        final frequencies = activeNotes.map((n) {
          final keyData = _pianoKeys.firstWhere((key) => key['note'] == n);
          return keyData['frequency'] as double;
        }).toList();

        bool isLongPress = duration > 1.5;
        String durationText = isLongPress ? "長押し" : "通常";
        
        print(' $durationText: ${adjustedDuration.toStringAsFixed(2)}秒, ${frequencies.length}音');
        
        final wavData = await _generateOptimizedHarmonyWaveData(frequencies, adjustedDuration);
        
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/piano_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(10000)}.wav');
        await file.writeAsBytes(wavData);
        
        final player = _audioPlayers[_currentPlayerIndex];
        _currentPlayerIndex = (_currentPlayerIndex + 1) % _maxPlayers;
        
        await player.stop();
        await player.play(DeviceFileSource(file.path));
        
        print(' 再生完了: ${note}');
      }
      
    } catch (e) {
      print(' 再生エラー: $e');
    }
  }

  void _stopAllSounds() async {
    for (final player in _audioPlayers) {
      await player.stop();
    }
    setState(() {
      _pressedKeys.clear();
      _sustainedKeys.clear();
      _keyPressStartTimes.clear();
      _activePlayingKeys.clear();
      _rippleEffects.clear();
      _sushiEffects.clear();
      _moneyEffects.clear();
    });
    print(' 全音停止');
  }

  void _resetBill() {
    setState(() {
      _totalBill = 0;
      _currentNoteIndex = 0;
      _currentSongIndex = 0;
    });
    print(' 会計&曲リセット');
  }

  //  コース変更
  void _changeCourse(String course) {
    setState(() {
      _selectedCourse = course;
      _songs = _courseSongs[course]!;
      _currentSongIndex = 0;
      _currentNoteIndex = 0;
      _totalBill = 0;
      _sushiEffects.clear();
    });
    print('🍣 コース変更: ${course}円コース');
  }

  //  全曲リストを取得
  List<Map<String, dynamic>> _getAllSongs() {
    List<Map<String, dynamic>> allSongs = [];
    _courseSongs.forEach((course, songs) {
      allSongs.addAll(songs);
    });
    return allSongs;
  }

  //  自動演奏開始
  void _startAutoPlay() async {
    if (!_autoPlayMode) return;
    
    final allSongs = _getAllSongs();
    final song = allSongs[_autoPlaySongIndex];
    final notes = song['notes'] as List<String>;
    final durations = song['durations'] as List<double>;
    
    print('🎼 自動演奏: ${song['name']}');
    
    setState(() {
      _currentNoteIndex = 0;
    });
    
    // 各音符を順番に演奏
    for (int i = 0; i < notes.length; i++) {
      if (!_autoPlayMode || !mounted) break;
      
      setState(() {
        _currentNoteIndex = i;
      });
      
      final noteName = notes[i];
      final duration = durations[i];
      
      //  寿司エフェクト
      if (_sushiMode && mounted) {
        final sushiPath = _sushiPaths[_random.nextInt(_sushiPaths.length)];
        final sushiId = DateTime.now().millisecondsSinceEpoch.toString() + _random.nextInt(10000).toString();
        final screenHeight = MediaQuery.of(context).size.height;
        final startY = screenHeight * (0.25 + _random.nextDouble() * 0.5) - 90;
        
        setState(() {
          _sushiEffects.add({
            'id': sushiId,
            'widget': SushiFlow(
              id: sushiId,
              sushiPath: sushiPath,
              startY: startY,
              duration: 3000,
              onTap: () {
                _removeSushi(sushiId);
              },
              onComplete: () {
                if (mounted) {
                  _removeSushi(sushiId);
                }
              },
            ),
          });
        });
      }
      
      // 音符を再生
      if (_soundEnabled && mounted) {
        final keyData = _pianoKeys.firstWhere(
          (key) => key['note'] == noteName,
          orElse: () => _pianoKeys[40],
        );
        final frequency = keyData['frequency'] as double;
        
        try {
          final wavData = await _generateOptimizedHarmonyWaveData([frequency], duration);
          final tempDir = await getTemporaryDirectory();
          final file = File('${tempDir.path}/auto_${DateTime.now().millisecondsSinceEpoch}.wav');
          await file.writeAsBytes(wavData);
          
          final player = _audioPlayers[_currentPlayerIndex];
          _currentPlayerIndex = (_currentPlayerIndex + 1) % _maxPlayers;
          await player.stop();
          await player.play(DeviceFileSource(file.path));
        } catch (e) {
          print(' 自動演奏エラー: $e');
        }
      }
      
      // 音符の長さだけ待機
      await Future.delayed(Duration(milliseconds: (duration * 1000).toInt()));
    }
    
    // 曲終了後、自動的に停止
    if (mounted && _autoPlayMode) {
      setState(() {
        _autoPlayMode = false;
        _currentNoteIndex = 0;
      });
      print(' 演奏完了: ${song['name']}');
    }
  }

  //  自動演奏曲切り替え
  void _switchAutoPlaySong() {
    final allSongs = _getAllSongs();
    setState(() {
      _autoPlaySongIndex = (_autoPlaySongIndex + 1) % allSongs.length;
      _autoPlayMode = false;
      _currentNoteIndex = 0;
      _sushiEffects.clear();
    });
    print(' 選択曲: ${allSongs[_autoPlaySongIndex]['name']}');
  }

  @override
  Widget build(BuildContext context) {
    final whiteKeys = _pianoKeys.where((key) => !key['isBlack']).toList();
    final currentSong = _songs[_currentSongIndex];
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(' 超高度インタラクティブピアノ 88鍵'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          // 自動演奏ボタン
          IconButton(
            icon: Icon(_autoPlayMode ? Icons.pause : Icons.play_arrow, size: 28),
            tooltip: _autoPlayMode ? '自動演奏停止' : '自動演奏開始',
            onPressed: () {
              setState(() {
                _autoPlayMode = !_autoPlayMode;
                if (_autoPlayMode) {
                  _startAutoPlay();
                } else {
                  _currentNoteIndex = 0;
                }
              });
            },
          ),
          // 曲切り替えボタン
          IconButton(
            icon: Icon(Icons.skip_next, size: 28),
            tooltip: '次の曲へ',
            onPressed: _switchAutoPlaySong,
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.restaurant, size: 28, color: _sushiMode ? Colors.yellow : Colors.white),
            tooltip: ' 寿司打コース選択',
            onSelected: (value) {
              if (value == 'toggle') {
                setState(() {
                  _sushiMode = !_sushiMode;
                  if (_sushiMode) _gameMode = false;
                });
                print(_sushiMode ? ' 寿司モードON' : ' 寿司モードOFF');
              } else {
                _changeCourse(value);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle',
                child: Row(
                  children: [
                    Icon(_sushiMode ? Icons.check_box : Icons.check_box_outline_blank, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('寿司モード ${_sushiMode ? "ON" : "OFF"}'),
                  ],
                ),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                value: '3000',
                child: Row(
                  children: [
                    Icon(Icons.star, color: _selectedCourse == '3000' ? Colors.yellow : Colors.grey),
                    SizedBox(width: 8),
                    Text('3,000円コース（やさしい）', style: TextStyle(fontWeight: _selectedCourse == '3000' ? FontWeight.bold : FontWeight.normal)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: '5000',
                child: Row(
                  children: [
                    Icon(Icons.star_half, color: _selectedCourse == '5000' ? Colors.orange : Colors.grey),
                    SizedBox(width: 8),
                    Text('5,000円コース（ふつう）', style: TextStyle(fontWeight: _selectedCourse == '5000' ? FontWeight.bold : FontWeight.normal)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: '10000',
                child: Row(
                  children: [
                    Icon(Icons.whatshot, color: _selectedCourse == '10000' ? Colors.red : Colors.grey),
                    SizedBox(width: 8),
                    Text('10,000円コース（むずかしい）', style: TextStyle(fontWeight: _selectedCourse == '10000' ? FontWeight.bold : FontWeight.normal)),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.videogame_asset, size: 28),
            color: _gameMode ? Colors.green : Colors.white,
            onPressed: () {
              setState(() {
                _gameMode = !_gameMode;
                if (_gameMode) {
                  _sushiMode = true;
                  _startGameMode();
                }
              });
              print(_gameMode ? ' 音ゲーモードON' : ' 音ゲーモードOFF');
            },
            tooltip: ' 音ゲーモード',
          ),
          IconButton(
            icon: const Icon(Icons.restart_alt, size: 28),
            onPressed: _resetBill,
            tooltip: ' 会計&曲リセット',
          ),
          IconButton(
            icon: Icon(_randomRippleMode ? Icons.shuffle : Icons.shuffle_outlined),
            onPressed: () {
              setState(() {
                _randomRippleMode = !_randomRippleMode;
              });
              print(_randomRippleMode ? ' ランダム波紋ON' : ' ランダム波紋OFF');
            },
            tooltip: 'ランダム波紋',
          ),
          IconButton(
            icon: Icon(_rippleMode ? Icons.water_drop : Icons.water_drop_outlined),
            onPressed: () {
              setState(() {
                _rippleMode = !_rippleMode;
              });
              print(_rippleMode ? ' 巨大波紋ON' : ' 巨大波紋OFF');
            },
            tooltip: '巨大波紋',
          ),
          IconButton(
            icon: Icon(_sustainMode ? Icons.piano : Icons.piano_outlined),
            onPressed: () {
              setState(() {
                _sustainMode = !_sustainMode;
                if (!_sustainMode) {
                  _sustainedKeys.clear();
                }
              });
              print(_sustainMode ? ' サステインON' : ' サステインOFF');
            },
            tooltip: 'サステイン',
          ),
          IconButton(
            icon: const Icon(Icons.stop),
            onPressed: _stopAllSounds,
            tooltip: '全停止',
          ),
          IconButton(
            icon: Icon(_soundEnabled ? Icons.volume_up : Icons.volume_off),
            onPressed: () {
              setState(() {
                _soundEnabled = !_soundEnabled;
              });
              print(_soundEnabled ? ' 音声ON' : ' 音声OFF');
            },
            tooltip: '音量',
          ),
          IconButton(
            icon: Icon(_useNativeAudio ? Icons.flash_on : Icons.flash_off, size: 28),
            color: _useNativeAudio ? Colors.yellow : Colors.white,
            onPressed: () {
              setState(() {
                _useNativeAudio = !_useNativeAudio;
              });
              print(_useNativeAudio ? ' C++高速モードON' : ' Dart通常モードON');
            },
            tooltip: _useNativeAudio ? ' C++高速モード' : ' 通常モード',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple[100]!, Colors.blue[100]!],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.restaurant, color: Colors.orange, size: 24),
                const SizedBox(width: 8),
                Text(
                  _sushiMode ? (_gameMode ? ' 音ゲー: \円コース' : ' 寿司打: \円コース') : ' 寿司OFF',
                  style: TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.bold,
                    color: _sushiMode ? Colors.orange : Colors.grey,
                  ),
                ),
                const SizedBox(width: 20),
                //  現在の曲表示
                if (_sushiMode) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.purple[700],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.pink, width: 2),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.music_note, color: Colors.yellow, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          currentSong['name'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange[700],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.yellow, width: 2),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.paid, color: Colors.yellow, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '$_totalBill',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Icon(Icons.queue_music, color: Colors.purple),
                const SizedBox(width: 8),
                const Text(
                  ' 美しい和音',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 20),
                const Text(
                  '演奏中: ',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${(_sustainedKeys.isNotEmpty ? _sustainedKeys : _pressedKeys).length}音',
                  style: const TextStyle(fontSize: 14, color: Colors.red),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: whiteKeys.length * 80.0,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final availableHeight = constraints.maxHeight;
                        
                        return Stack(
                          children: [
                            _buildWhiteKeysLayer(availableHeight),
                            _buildBlackKeysOverlay(availableHeight),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                ...(_sushiMode ? _sushiEffects.map((item) => item['widget'] as Widget).toList() : []),
                ..._moneyEffects,
                ...(_rippleMode ? _rippleEffects : []),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _startGameMode() {
    final interval = _courseIntervals[_selectedCourse] ?? 3000;
    Future.delayed(Duration(milliseconds: interval), () {
      if (_gameMode && mounted) {
        final randomKeyIndex = _random.nextInt(_pianoKeys.length);
        _addSushiEffect(Offset(0, 0), targetKeyIndex: randomKeyIndex);
        _startGameMode();
      }
    });
  }

  Widget _buildWhiteKeysLayer(double availableHeight) {
    final whiteKeys = _pianoKeys.where((key) => !key['isBlack']).toList();
    final List<Widget> whiteKeyWidgets = [];
    
    for (int i = 0; i < whiteKeys.length; i++) {
      final keyData = whiteKeys[i];
      final position = _calculateWhiteKeyPosition(keyData['note']);
      
      whiteKeyWidgets.add(
        Positioned(
          left: position * 80.0,
          child: _buildWhiteKey(keyData, availableHeight),
        ),
      );
    }
    
    return Stack(children: whiteKeyWidgets);
  }

  Widget _buildWhiteKey(Map<String, dynamic> keyData, double availableHeight) {
    final isPressed = _pressedKeys.contains(keyData['note']);
    final isSustained = _sustainedKeys.contains(keyData['note']);
    final keyHeight = availableHeight - 10;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      width: 75,
      height: isPressed ? keyHeight - 20 : keyHeight,
      margin: const EdgeInsets.all(2),
      child: GestureDetector(
        onTapDown: (details) {
          final RenderBox box = context.findRenderObject() as RenderBox;
          final localPosition = box.globalToLocal(details.globalPosition);
          _onKeyDown(keyData['note'], localPosition);
        },
        onTapUp: (_) => _onKeyUp(keyData['note']),
        onTapCancel: () => _onKeyUp(keyData['note']),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          transform: Matrix4.translationValues(0, isPressed ? 10 : 0, 0),
          decoration: BoxDecoration(
            color: isPressed 
                ? keyData['color'].withOpacity(1.0)
                : isSustained 
                    ? keyData['color'].withOpacity(0.9)
                    : keyData['color'],
            border: Border.all(
              color: isSustained ? Colors.orange : Colors.black,
              width: isSustained ? 3 : 2
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: isPressed ? Colors.black38 : Colors.black26,
                offset: Offset(0, isPressed ? 2 : 6),
                blurRadius: isPressed ? 2 : 8,
                spreadRadius: isPressed ? 0 : 1,
              ),
              if (isPressed)
                BoxShadow(
                  color: keyData['color'].withOpacity(0.9),
                  offset: const Offset(0, 0),
                  blurRadius: 30,
                  spreadRadius: 8,
                ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                isPressed 
                    ? keyData['color']
                    : keyData['color'],
                isPressed 
                    ? keyData['color'].withOpacity(0.9)
                    : keyData['color'].withOpacity(0.8),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isPressed || isSustained) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.queue_music,
                        color: Colors.white,
                        size: 24,
                      ),
                      Text(
                        '${keyData['frequency'].toStringAsFixed(0)}Hz',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  keyData['note'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isPressed || isSustained ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBlackKeysOverlay(double availableHeight) {
    final List<Widget> blackKeyWidgets = [];
    final whiteKeys = _pianoKeys.where((key) => !key['isBlack']).toList();

    for (int i = 0; i < whiteKeys.length; i++) {
      final whiteKeyNote = whiteKeys[i]['note'];
      final noteName = whiteKeyNote.replaceAll(RegExp(r'[0-9]'), '');
      final whiteKeyPosition = _calculateWhiteKeyPosition(whiteKeyNote);
      
      String? blackKeyNote;
      double blackKeyOffset = 0.55;
      
      switch (noteName) {
        case 'C':
          blackKeyNote = whiteKeyNote.replaceFirst('C', 'C#');
          break;
        case 'D':
          blackKeyNote = whiteKeyNote.replaceFirst('D', 'D#');
          break;
        case 'F':
          blackKeyNote = whiteKeyNote.replaceFirst('F', 'F#');
          break;
        case 'G':
          blackKeyNote = whiteKeyNote.replaceFirst('G', 'G#');
          break;
        case 'A':
          blackKeyNote = whiteKeyNote.replaceFirst('A', 'A#');
          break;
        default:
          blackKeyNote = null;
      }
      
      if (blackKeyNote != null) {
        final blackKey = _pianoKeys.firstWhere(
          (key) => key['note'] == blackKeyNote,
          orElse: () => {},
        );
        
        if (blackKey.isNotEmpty) {
          blackKeyWidgets.add(
            Positioned(
              left: (whiteKeyPosition + blackKeyOffset) * 80.0,
              child: _buildBlackKey(blackKey, availableHeight),
            ),
          );
        }
      }
    }

    return Stack(children: blackKeyWidgets);
  }

  Widget _buildBlackKey(Map<String, dynamic> keyData, double availableHeight) {
    final isPressed = _pressedKeys.contains(keyData['note']);
    final isSustained = _sustainedKeys.contains(keyData['note']);
    final keyHeight = (availableHeight * 0.6);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      width: 45,
      height: isPressed ? keyHeight - 15 : keyHeight,
      child: GestureDetector(
        onTapDown: (details) {
          final RenderBox box = context.findRenderObject() as RenderBox;
          final localPosition = box.globalToLocal(details.globalPosition);
          _onKeyDown(keyData['note'], localPosition);
        },
        onTapUp: (_) => _onKeyUp(keyData['note']),
        onTapCancel: () => _onKeyUp(keyData['note']),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          transform: Matrix4.translationValues(0, isPressed ? 8 : 0, 0),
          decoration: BoxDecoration(
            color: isPressed ? Colors.grey[400] : keyData['color'],
            border: Border.all(
              color: isSustained ? Colors.orange : Colors.black,
              width: isSustained ? 3 : 2
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: isPressed ? Colors.black54 : Colors.black87,
                offset: Offset(0, isPressed ? 2 : 8),
                blurRadius: isPressed ? 3 : 10,
                spreadRadius: isPressed ? 0 : 2,
              ),
              if (isPressed)
                BoxShadow(
                  color: Colors.grey.withOpacity(0.8),
                  offset: const Offset(0, 0),
                  blurRadius: 25,
                  spreadRadius: 6,
                ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                isPressed ? Colors.grey[400]! : keyData['color'],
                isPressed ? Colors.grey[600]! : keyData['color'].withOpacity(0.8),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isPressed || isSustained) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.queue_music,
                        color: Colors.yellow,
                        size: 20,
                      ),
                      Text(
                        '${keyData['frequency'].toStringAsFixed(0)}Hz',
                        style: const TextStyle(
                          fontSize: 8,
                          color: Colors.yellow,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Text(
                  keyData['note'],
                  style: TextStyle(
                    fontSize: 12,
                    color: isPressed || isSustained ? Colors.yellow : Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (final player in _audioPlayers) {
      player.dispose();
    }
    super.dispose();
  }
}





