import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/bet_state.dart';
import '../utils/game_constants.dart';
import '../utils/orientation_helper.dart';
import 'new_race_screen.dart';

class NewBettingScreen extends StatefulWidget {
  const NewBettingScreen({super.key});

  @override
  State<NewBettingScreen> createState() => _NewBettingScreenState();
}

class _NewBettingScreenState extends State<NewBettingScreen> {
  late BetState _betState;
  final TextEditingController _betAmountController = TextEditingController();
  int? _selectedCar;

  @override
  void initState() {
    super.initState();
    OrientationHelper.setLandscape();
    _betState = BetState(totalCoins: GameConstants.initialCoins);
    _betAmountController.text = '0';
  }

  @override
  void dispose() {
    _betAmountController.dispose();
    super.dispose();
  }

  void _selectCar(int carIndex) {
    setState(() {
      _selectedCar = carIndex;
    });
  }

  void _updateBetAmount(String value) {
    final amount = double.tryParse(value) ?? 0.0;
    setState(() {
      _betState = _betState.copyWith(
        betAmount: amount.clamp(0.0, _betState.totalCoins),
      );
    });
    if (amount > _betState.totalCoins) {
      _betAmountController.text = _betState.totalCoins.toStringAsFixed(0);
    }
  }

  void _startRace() {
    // Create temporary bet state with selected car for validation
    final tempBetState = _betState.copyWith(selectedCar: _selectedCar);
    
    if (!tempBetState.canPlaceBet()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn xe và nhập số coin cược hợp lệ!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewRaceScreen(
          betState: tempBetState,
        ),
      ),
    ).then((result) {
      if (result != null && result is BetState) {
        setState(() {
          _betState = result;
          _selectedCar = null;
          _betAmountController.text = '0';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final carColors = [Colors.red, Colors.blue, Colors.green];
    final carNames = ['Car 1', 'Car 2', 'Car 3'];

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
            colors: [
              Colors.deepPurple.shade300,
              Colors.indigo.shade400,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Coins display
                Container(
                  padding: const EdgeInsets.all(20.0),
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
                        'Số Coin Hiện Có',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_betState.totalCoins.toStringAsFixed(0)} coins',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Car selection
                const Text(
                  'Chọn Xe Để Cược',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: List.generate(3, (index) {
                    final isSelected = _selectedCar == index;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: GestureDetector(
                          onTap: () => _selectCar(index),
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? carColors[index]
                                  : carColors[index].withOpacity(0.3),
                              borderRadius: BorderRadius.circular(16),
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
                                  size: 48,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  carNames[index],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
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
                const SizedBox(height: 32),

                // Bet amount input
                const Text(
                  'Số Coin Cược',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _betAmountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: 'Nhập số coin',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixText: 'coins',
                  ),
                  onChanged: _updateBetAmount,
                ),
                const SizedBox(height: 8),
                Text(
                  'Còn lại: ${(_betState.totalCoins - _betState.betAmount).toStringAsFixed(0)} coins',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),

                // Start button
                SizedBox(
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _startRace,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'BẮT ĐẦU ĐUA',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
