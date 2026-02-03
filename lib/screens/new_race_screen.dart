import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/bet_state.dart';
import '../models/game_state.dart';
import '../services/game_engine.dart';
import '../constants/game_constants.dart';
import '../utils/orientation_helper.dart';
import '../components/car_widget.dart';
import '../components/track_widget.dart';
import '../components/progress_bar_widget.dart';
import '../components/car_info_widget.dart';
import 'new_result_screen.dart';

/// Race screen - displays the racing game
class NewRaceScreen extends StatefulWidget {
  final BetState betState;

  const NewRaceScreen({super.key, required this.betState});

  @override
  State<NewRaceScreen> createState() => _NewRaceScreenState();
}

class _NewRaceScreenState extends State<NewRaceScreen> {
  late GameEngine _engine;
  Timer? _gameLoop;
  bool _isRacing = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    OrientationHelper.setLandscape();
    _engine = GameEngine();
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    // Listen to audio player state changes
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      print('🎵 Audio player state: $state');
      if (state == PlayerState.playing) {
        print('✅ Audio is now playing!');
      } else if (state == PlayerState.paused) {
        print('⏸️ Audio is paused');
      } else if (state == PlayerState.stopped) {
        print('⏹️ Audio is stopped');
      } else if (state == PlayerState.completed) {
        print('✅ Audio completed');
      }
    });

    // Listen to errors
    _audioPlayer.onLog.listen((String message) {
      print('🎵 Audio log: $message');
    });

    // Listen to duration changes
    _audioPlayer.onDurationChanged.listen((Duration duration) {
      print('🎵 Audio duration: ${duration.inSeconds}s');
    });

    // Listen to position changes
    _audioPlayer.onPositionChanged.listen((Duration position) {
      if (position.inSeconds % 5 == 0) {
        print('🎵 Audio position: ${position.inSeconds}s');
      }
    });
  }

  Future<void> _playBackgroundMusic() async {
    try {
      print('🎵 ===== Starting audio playback =====');

      // Set player mode để phát qua loa (không bị mute)
      await _audioPlayer.setPlayerMode(PlayerMode.mediaPlayer);
      print('🎵 Player mode set to mediaPlayer');

      // Set volume và loop mode
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      print('🎵 Volume set to 1.0, Loop mode enabled');

      // Thử phát audio
      final source = AssetSource('audio/race_screen.mp3');
      print('🎵 Source: $source');
      print('🎵 Attempting to play...');

      // Phát trực tiếp
      await _audioPlayer.play(source);
      print('🎵 Play command executed');

      // Đợi và kiểm tra state nhiều lần
      for (int i = 0; i < 3; i++) {
        await Future.delayed(const Duration(milliseconds: 500));
        final state = _audioPlayer.state;
        print('🎵 Check ${i + 1}: State = $state');

        if (state == PlayerState.playing) {
          print('✅ SUCCESS: Audio is playing!');
          final duration = await _audioPlayer.getDuration();
          print('🎵 Audio duration: ${duration?.inSeconds ?? 'unknown'}s');

          // Nếu đang chạy trên emulator, cảnh báo
          print('⚠️ NOTE: Nếu bạn đang dùng Android Emulator:');
          print('   - Emulator có thể không phát âm thanh');
          print('   - Hãy test trên thiết bị thật để nghe nhạc');
          print('   - Hoặc kiểm tra Settings > Extended Controls > Audio');

          return; // Thành công, thoát
        }
      }

      // Nếu vẫn không playing, thử lại
      print('⚠️ WARNING: Audio not playing after 3 checks');
      print('⚠️ Trying alternative method...');

      await _audioPlayer.stop();
      await Future.delayed(const Duration(milliseconds: 300));
      await _audioPlayer.play(source);

      await Future.delayed(const Duration(milliseconds: 1000));
      final finalState = _audioPlayer.state;
      print('🎵 Final state: $finalState');

      if (finalState == PlayerState.playing) {
        print('✅ SUCCESS after retry!');
      } else {
        print('❌ Still not playing.');
        print('❌ Please check:');
        print('   1. Device volume is turned up');
        print('   2. Device is not in silent/Do Not Disturb mode');
        print('   3. Audio file exists and is valid');
      }
    } catch (e, stackTrace) {
      print('❌ ERROR playing audio: $e');
      print('❌ Stack trace: $stackTrace');
    }
  }

  @override
  void dispose() {
    _gameLoop?.cancel();
    _audioPlayer.dispose(); // Dừng và giải phóng audio player
    OrientationHelper.setAll();
    super.dispose();
  }

  void _startRace() async {
    if (_isRacing) return;

    setState(() {
      _isRacing = true;
    });

    // Phát nhạc nền khi bắt đầu đua
    _playBackgroundMusic();

    // Game loop at 60fps
    _gameLoop = Timer.periodic(
      const Duration(milliseconds: 16), // ~60fps
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        _engine.update(16 / 1000.0); // deltaTime in seconds

        setState(() {});

        // Check if race finished
        if (_engine.state.isFinished) {
          timer.cancel();
          _onRaceFinished();
        }
      },
    );
  }

  void _onRaceFinished() async {
    final winner = _engine.state.winner;
    if (winner == null) return;

    // Dừng nhạc nền khi race kết thúc
    try {
      await _audioPlayer.stop();
    } catch (e) {
      print('Error stopping audio: $e');
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => NewResultScreen(
            betState: widget.betState,
            winner: winner,
            engine: _engine,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = _engine.state;
    final rankings = _engine.getRankings();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade200, Colors.green.shade100],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // Race track
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final trackHeight = constraints.maxHeight;
                    final trackWidth = constraints.maxWidth;
                    final laneSpacing = trackHeight / 3;
                    final laneYPositions = List.generate(3, (index) {
                      return (index + 0.5) * laneSpacing;
                    });

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: Stack(
                        children: [
                          // Track background with lines
                          TrackWidget(
                            trackWidth: trackWidth,
                            trackHeight: trackHeight,
                            laneYPositions: laneYPositions,
                          ),

                          // Cars
                          ...List.generate(3, (index) {
                            final progress = _engine.getProgress(index);
                            final availableWidth = trackWidth - 40;
                            final carX = (availableWidth * progress).clamp(
                              0.0,
                              availableWidth - GameConstants.carWidth,
                            );
                            final carY =
                                laneYPositions[index] -
                                GameConstants.carHeight / 2;

                            return CarWidget(
                              carIndex: index,
                              progress: progress,
                              x: carX,
                              y: carY,
                            );
                          }),

                          // Progress bars on the side
                          Positioned(
                            right: 8,
                            top:
                                laneYPositions[0] - GameConstants.carHeight / 2,
                            child: Column(
                              children: List.generate(3, (index) {
                                return ProgressBarWidget(
                                  carIndex: index,
                                  progress: _engine.getProgress(index),
                                  laneSpacing: laneSpacing,
                                  isLast: index == 2,
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Info panel
              _buildInfoPanel(state, rankings),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _isRacing ? 'Đang đua...' : 'Sẵn sàng',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          if (!_isRacing)
            ElevatedButton(
              onPressed: _startRace,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('BẮT ĐẦU'),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoPanel(GameState state, List<int> rankings) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white.withOpacity(0.9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(3, (index) {
          return CarInfoWidget(
            carIndex: index,
            ranking: rankings[index],
            speed: state.speeds[index],
          );
        }),
      ),
    );
  }
}
