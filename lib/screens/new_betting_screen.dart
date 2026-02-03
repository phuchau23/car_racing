import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/bet_state.dart';
import '../constants/game_constants.dart';
import '../constants/car_config.dart';
import '../utils/orientation_helper.dart';
import 'new_race_screen.dart';

class NewBettingScreen extends StatefulWidget {
  final BetState? initialBetState;

  const NewBettingScreen({super.key, this.initialBetState});

  @override
  State<NewBettingScreen> createState() => _NewBettingScreenState();
}

class _NewBettingScreenState extends State<NewBettingScreen> {
  late BetState _betState;
  final TextEditingController _betAmountController = TextEditingController();
  int? _selectedCar;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    OrientationHelper.setLandscape();
    _betState =
        widget.initialBetState ??
        BetState(totalMoney: GameConstants.initialMoney);
    _betAmountController.text = '0';
    _playBackgroundMusic();
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    _betAmountController.dispose();
    super.dispose();
  }

  Future<void> _playBackgroundMusic() async {
    try {
      await _audioPlayer.setPlayerMode(PlayerMode.mediaPlayer);
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('audio/bet_screen.mp3'));
      print('🎵 Betting screen music started');
    } catch (e) {
      print('❌ Error playing betting music: $e');
    }
  }

  void _selectCar(int carIndex) {
    setState(() {
      _selectedCar = carIndex;
    });
  }

  void _updateBetAmount(String value) {
    if (value.isEmpty || value.trim().isEmpty) {
      setState(() {
        _betState = _betState.copyWith(betAmount: 0.0);
      });
      _betAmountController.text = '0';
      return;
    }

    final amount = double.tryParse(value.trim()) ?? 0.0;
    final clampedAmount = amount.clamp(0.0, _betState.totalMoney);

    setState(() {
      _betState = _betState.copyWith(betAmount: clampedAmount);
    });

    // Update controller if amount was clamped or invalid
    if (amount > _betState.totalMoney) {
      _betAmountController.text = _betState.totalMoney.toStringAsFixed(0);
      _betState = _betState.copyWith(betAmount: _betState.totalMoney);
    } else if (amount < 0) {
      _betAmountController.text = '0';
      _betState = _betState.copyWith(betAmount: 0.0);
    }
  }

  void _startRace() {
    // Validate car selection first
    if (_selectedCar == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn xe để cược!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Get current bet amount from controller
    final controllerValue = _betAmountController.text.trim();
    if (controllerValue.isEmpty || controllerValue == '0') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập số tiền cược lớn hơn 0!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final betAmountFromController = double.tryParse(controllerValue);
    if (betAmountFromController == null || betAmountFromController <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Số tiền cược không hợp lệ! Vui lòng nhập số lớn hơn 0.',
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (betAmountFromController > _betState.totalMoney) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Số tiền cược không được vượt quá ${_betState.totalMoney.toStringAsFixed(0)} VNĐ!',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // Create bet state with selected car and final bet amount
    final tempBetState = _betState.copyWith(
      selectedCar: _selectedCar,
      betAmount: betAmountFromController,
    );

    // Stop betting music before navigating to race screen
    _audioPlayer.stop();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewRaceScreen(betState: tempBetState),
      ),
    ).then((result) {
      if (result != null && result is BetState) {
        setState(() {
          _betState = result;
          _selectedCar = null;
          _betAmountController.text = '0';
        });
        // Resume betting music when returning from race
        _playBackgroundMusic();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đặt Cược'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.deepPurple.shade300, Colors.indigo.shade400],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Left side - Money display and car selection
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Money display
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade400,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Số Tiền Hiện Có',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${_betState.totalMoney.toStringAsFixed(0)} VNĐ',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Car selection
                      const Text(
                        'Chọn Xe Để Cược',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: List.generate(3, (index) {
                          final isSelected = _selectedCar == index;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6.0,
                              ),
                              child: GestureDetector(
                                onTap: () => _selectCar(index),
                                child: Container(
                                  padding: const EdgeInsets.all(12.0),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? CarConfig.getCarColor(index)
                                        : CarConfig.getCarColor(
                                            index,
                                          ).withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.transparent,
                                      width: 3,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.directions_car,
                                        size: 36,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        CarConfig.getCarName(index),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // Right side - Bet input and button
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Số Tiền Cược',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _betAmountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          hintText: 'Nhập số tiền',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixText: 'VNĐ',
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                        ),
                        onChanged: _updateBetAmount,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Còn lại: ${(_betState.totalMoney - _betState.betAmount).toStringAsFixed(0)} VNĐ',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _startRace,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'BẮT ĐẦU ĐUA',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
