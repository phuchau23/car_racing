# 📋 PHÂN CÔNG CÔNG VIỆC CHO 6 THÀNH VIÊN

## 🎯 TỔNG QUAN

Dự án **Mini Racing Game** được chia thành **6 flow** độc lập, mỗi người phụ trách 1 flow. Mỗi flow có thể làm song song và ít phụ thuộc lẫn nhau.

---

## 👤 Tâm: AUTHENTICATION & APP SETUP

### 📦 **Files cần làm:**
- `lib/main.dart` - Entry point của app
- `lib/screens/login_screen.dart` - Màn hình đăng nhập
- `lib/utils/orientation_helper.dart` - Helper quản lý hướng màn hình

### 🎯 **Nhiệm vụ:**

#### 1. **Setup App (`main.dart`)**
```dart
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'utils/orientation_helper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  OrientationHelper.setLandscape(); // Set màn hình ngang từ đầu
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini Racing Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginScreen(), // Bắt đầu từ LoginScreen
    );
  }
}
```

**Giải thích:**
- `main()`: Khởi tạo app, set landscape mode
- `MyApp`: Widget root, định nghĩa theme và home screen

#### 2. **Orientation Helper (`orientation_helper.dart`)**
```dart
import 'package:flutter/services.dart';

class OrientationHelper {
  static void setLandscape() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  static void setAll() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
}
```

**Giải thích:**
- `setLandscape()`: Khóa màn hình ngang
- `setAll()`: Cho phép tất cả hướng (dùng khi dispose)

#### 3. **Login Screen (`login_screen.dart`)**

**State Variables:**
```dart
final TextEditingController _usernameController = TextEditingController();
final TextEditingController _passwordController = TextEditingController();
final _formKey = GlobalKey<FormState>();
```

**Layout:**
- **Bên trái**: Logo + Title + Mô tả
- **Bên phải**: Form đăng nhập (username, password, button)

**Logic:**
```dart
void _handleLogin() {
  if (_formKey.currentState!.validate()) {
    // Fake login - chấp nhận bất kỳ username/password nào
    final initialBetState = BetState(totalMoney: GameConstants.initialMoney);
    
    // Chuyển sang màn hình đặt cược
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => NewBettingScreen(initialBetState: initialBetState),
      ),
    );
  }
}
```

**Validation:**
- Username: không được rỗng
- Password: không được rỗng

### 🔗 **Dependencies:**
- Cần import `BetState` từ `models/bet_state.dart` (người 2 làm)
- Cần import `GameConstants` từ `constants/game_constants.dart` (người 6 làm)
- Cần import `NewBettingScreen` từ `screens/new_betting_screen.dart` (người 2 làm)

### ✅ **Checklist:**
- [ ] App khởi động được
- [ ] Màn hình tự động chuyển sang ngang
- [ ] Login screen hiển thị đẹp (gradient, shadow, responsive)
- [ ] Validation form hoạt động
- [ ] Bấm đăng nhập chuyển sang betting screen
- [ ] Dispose controllers đúng cách

### 📚 **Kiến thức cần:**
- Flutter Widget basics (StatefulWidget, StatelessWidget)
- Form validation
- Navigation (Navigator.pushReplacement)
- TextEditingController
- Layout (Row, Column, Expanded)
- Styling (Container, BoxDecoration, Gradient)

---

## 👤 Duy: BETTING SYSTEM

### 📦 **Files cần làm:**
- `lib/models/bet_state.dart` - Model quản lý state đặt cược
- `lib/screens/new_betting_screen.dart` - Màn hình đặt cược

### 🎯 **Nhiệm vụ:**

#### 1. **BetState Model (`bet_state.dart`)**

```dart
class BetState {
  final double totalMoney; // VNĐ
  final int? selectedCar; // 0, 1, or 2
  final double betAmount; // VNĐ

  BetState({
    this.totalMoney = 100000.0,
    this.selectedCar,
    this.betAmount = 0.0,
  });

  // Copy với thay đổi một số field
  BetState copyWith({double? totalMoney, int? selectedCar, double? betAmount}) {
    return BetState(
      totalMoney: totalMoney ?? this.totalMoney,
      selectedCar: selectedCar ?? this.selectedCar,
      betAmount: betAmount ?? this.betAmount,
    );
  }

  // Kiểm tra có thể đặt cược không
  bool canPlaceBet() {
    return selectedCar != null &&
        betAmount > 0.0 &&
        betAmount <= totalMoney &&
        (totalMoney - betAmount) >= 0.0;
  }

  // Tính tiền thắng
  double calculateWinnings(int winner) {
    if (selectedCar == null || betAmount == 0) return 0.0;
    if (selectedCar == winner) {
      return betAmount * 2.0; // 2x odds
    }
    return 0.0;
  }

  // Kiểm tra hết tiền
  bool isBroke() {
    return totalMoney <= 0;
  }
}
```

**Giải thích:**
- `totalMoney`: Tổng tiền hiện có (bắt đầu 100,000 VNĐ)
- `selectedCar`: Xe được chọn (0, 1, hoặc 2)
- `betAmount`: Số tiền cược
- `copyWith()`: Tạo state mới với một số field thay đổi
- `canPlaceBet()`: Validate có thể đặt cược không
- `calculateWinnings()`: Tính tiền thắng (2x nếu đúng xe)
- `isBroke()`: Kiểm tra hết tiền

#### 2. **Betting Screen (`new_betting_screen.dart`)**

**State Variables:**
```dart
late BetState _betState;
final TextEditingController _betAmountController = TextEditingController();
int? _selectedCar;
final AudioPlayer _audioPlayer = AudioPlayer();
```

**Layout (Landscape - Row):**
- **Bên trái (Expanded flex: 2)**:
  - Hiển thị số tiền hiện có
  - 3 nút chọn xe (Xe Đỏ, Xe Xanh, Xe Vàng)
- **Bên phải (Expanded flex: 1)**:
  - Input số tiền cược
  - Hiển thị số tiền còn lại
  - Nút "BẮT ĐẦU ĐUA"

**Logic chính:**

```dart
void _selectCar(int carIndex) {
  setState(() {
    _selectedCar = carIndex;
    _betState = _betState.copyWith(selectedCar: carIndex);
  });
}

void _updateBetAmount(String value) {
  if (value.isEmpty) {
    setState(() {
      _betState = _betState.copyWith(betAmount: 0.0);
    });
    return;
  }

  final amount = double.tryParse(value.trim()) ?? 0.0;
  final clampedAmount = amount.clamp(0.0, _betState.totalMoney);

  setState(() {
    _betState = _betState.copyWith(betAmount: clampedAmount);
  });

  // Update controller nếu bị clamp
  if (amount > _betState.totalMoney) {
    _betAmountController.text = _betState.totalMoney.toStringAsFixed(0);
  }
}

void _startRace() {
  // Validate
  if (_selectedCar == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vui lòng chọn xe để cược')),
    );
    return;
  }

  final betAmount = double.tryParse(_betAmountController.text.trim()) ?? 0.0;
  
  if (betAmount <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Số tiền cược phải lớn hơn 0')),
    );
    return;
  }

  if (betAmount > _betState.totalMoney) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Số tiền cược không được vượt quá số tiền hiện có')),
    );
    return;
  }

  // Tạo BetState với selectedCar và betAmount
  final finalBetState = _betState.copyWith(
    selectedCar: _selectedCar,
    betAmount: betAmount,
  );

  // Dừng nhạc betting trước khi chuyển màn hình
  _audioPlayer.stop();

  // Chuyển sang màn hình đua
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => NewRaceScreen(betState: finalBetState),
    ),
  );
}

Future<void> _playBackgroundMusic() async {
  try {
    await _audioPlayer.setPlayerMode(PlayerMode.mediaPlayer);
    await _audioPlayer.setVolume(1.0);
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(AssetSource('audio/bet_screen.mp3'));
  } catch (e) {
    print('❌ Error playing betting music: $e');
  }
}
```

**Validation:**
1. Phải chọn xe
2. Số tiền > 0
3. Số tiền <= totalMoney
4. Hiển thị SnackBar khi lỗi

### 🔗 **Dependencies:**
- Cần import `GameConstants` từ `constants/game_constants.dart` (người 6)
- Cần import `CarConfig` từ `constants/car_config.dart` (người 6 làm) - để lấy tên xe
- Cần import `NewRaceScreen` từ `screens/new_race_screen.dart` (người 5 làm)
- Cần import `audioplayers` package

### ✅ **Checklist:**
- [ ] BetState model hoạt động đúng
- [ ] UI hiển thị đẹp, responsive landscape
- [ ] Chọn xe hoạt động (highlight khi chọn)
- [ ] Input số tiền validate đúng
- [ ] Clamp số tiền không vượt quá totalMoney
- [ ] Hiển thị số tiền còn lại real-time
- [ ] Validation đầy đủ (xe, tiền)
- [ ] SnackBar hiển thị khi lỗi
- [ ] Audio phát khi vào màn hình (bet_screen.mp3)
- [ ] Audio dừng khi chuyển sang race screen
- [ ] Navigation sang race screen với BetState đúng

### 📚 **Kiến thức cần:**
- Dart classes và immutability
- State management (setState)
- TextEditingController
- Input validation
- Number parsing (double.tryParse)
- Clamping values
- Navigation (Navigator.push)
- Audio playback (audioplayers package)

---

## 👤 Đan: GAME STATE MODEL

### 📦 **Files cần làm:**
- `lib/models/game_state.dart` - Model quản lý state game đua

### 🎯 **Nhiệm vụ:**

#### **GameState Model (`game_state.dart`)**

```dart
import 'dart:math';
import '../constants/game_constants.dart';

class GameState {
  final List<double> positions; // Vị trí X của 3 xe (0 đến finishDistance)
  final List<double> speeds; // Tốc độ hiện tại (px/s)
  final List<double> baseSpeeds; // Tốc độ cơ bản
  final List<double> noisePhases; // Phase cho noise calculation
  final List<double> laneY; // Vị trí Y của các lane
  final double finishDistance; // Khoảng cách đích
  final double elapsedTime; // Thời gian đã trôi qua
  final bool isFinished; // Đã kết thúc chưa
  final int? winner; // Xe thắng (0, 1, hoặc 2)
  final int seed; // Seed cho random
  final List<int> leadHistory; // Lịch sử thay đổi lead
  final int currentLeader; // Leader hiện tại

  GameState({
    required this.positions,
    required this.speeds,
    required this.baseSpeeds,
    required this.noisePhases,
    required this.laneY,
    required this.finishDistance,
    this.elapsedTime = 0.0,
    this.isFinished = false,
    this.winner,
    this.seed = 0,
    List<int>? leadHistory,
    this.currentLeader = 0,
  }) : leadHistory = leadHistory ?? [];

  /// Create initial game state
  factory GameState.initial({int? seed}) {
    final random = Random(seed ?? DateTime.now().millisecondsSinceEpoch);
    final gameSeed = seed ?? random.nextInt(1000000);
    final rng = Random(gameSeed);

    // Initialize 3 cars
    final baseSpeeds = List.generate(3, (i) {
      return GameConstants.baseSpeedMin +
          rng.nextDouble() * (GameConstants.baseSpeedMax - GameConstants.baseSpeedMin);
    });

    final noisePhases = List.generate(3, (i) => rng.nextDouble() * 2 * pi);

    // Lane Y positions (top, middle, bottom)
    final laneY = List.generate(3, (i) {
      return GameConstants.topLaneY + (i * GameConstants.laneSpacing);
    });

    return GameState(
      positions: [0.0, 0.0, 0.0],
      speeds: List.from(baseSpeeds),
      baseSpeeds: baseSpeeds,
      noisePhases: noisePhases,
      laneY: laneY,
      finishDistance: GameConstants.finishDistance,
      seed: gameSeed,
      currentLeader: 0,
    );
  }

  /// Copy with updated values
  GameState copyWith({
    List<double>? positions,
    List<double>? speeds,
    double? elapsedTime,
    bool? isFinished,
    int? winner,
    List<int>? leadHistory,
    int? currentLeader,
  }) {
    return GameState(
      positions: positions ?? List.from(this.positions),
      speeds: speeds ?? List.from(this.speeds),
      baseSpeeds: baseSpeeds,
      noisePhases: noisePhases,
      laneY: laneY,
      finishDistance: finishDistance,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      isFinished: isFinished ?? this.isFinished,
      winner: winner ?? this.winner,
      seed: seed,
      leadHistory: leadHistory ?? List.from(this.leadHistory),
      currentLeader: currentLeader ?? this.currentLeader,
    );
  }

  /// Get current leader index
  int getLeader() {
    int leader = 0;
    double maxPos = positions[0];
    for (int i = 1; i < positions.length; i++) {
      if (positions[i] > maxPos) {
        maxPos = positions[i];
        leader = i;
      }
    }
    return leader;
  }

  /// Check if any car finished
  bool checkFinish() {
    for (int i = 0; i < positions.length; i++) {
      if (positions[i] >= finishDistance) {
        return true;
      }
    }
    return false;
  }

  /// Get winner index
  int? getWinner() {
    if (!isFinished) return null;
    int winner = 0;
    double maxPos = positions[0];
    for (int i = 1; i < positions.length; i++) {
      if (positions[i] > maxPos) {
        maxPos = positions[i];
        winner = i;
      }
    }
    return winner;
  }
}
```

**Giải thích:**
- `positions`: Vị trí X của 3 xe (0 = start, finishDistance = đích)
- `speeds`: Tốc độ hiện tại (pixels/second)
- `baseSpeeds`: Tốc độ cơ bản (random 80-120 px/s)
- `noisePhases`: Phase cho sin wave (tạo biến thiên mượt)
- `laneY`: Vị trí Y của các lane (cố định)
- `finishDistance`: Khoảng cách đích (ví dụ: 2000px)
- `elapsedTime`: Thời gian đã trôi qua (giây)
- `isFinished`: Flag đã kết thúc
- `winner`: Xe thắng (0, 1, hoặc 2)
- `seed`: Seed cho random (để replay)
- `leadHistory`: Lịch sử thay đổi lead (để thống kê)
- `currentLeader`: Leader hiện tại

**Methods:**
- `GameState.initial()`: Tạo state ban đầu với random speeds
- `copyWith()`: Tạo state mới với một số field thay đổi
- `getLeader()`: Lấy xe đang dẫn đầu
- `checkFinish()`: Kiểm tra đã về đích chưa
- `getWinner()`: Lấy xe thắng

### 🔗 **Dependencies:**
- Cần import `GameConstants` từ `constants/game_constants.dart` (người 6 làm)

### ✅ **Checklist:**
- [ ] GameState model hoạt động đúng
- [ ] Factory `initial()` tạo state đúng
- [ ] `copyWith()` tạo state mới đúng
- [ ] `getLeader()` trả về leader đúng
- [ ] `checkFinish()` kiểm tra finish đúng
- [ ] `getWinner()` trả về winner đúng
- [ ] Immutability được đảm bảo (không thay đổi state cũ)

### 📚 **Kiến thức cần:**
- Dart classes và immutability
- Factory constructors
- Random number generation
- List operations
- Data modeling

---

## 👤 Hiếu: GAME ENGINE

### 📦 **Files cần làm:**
- `lib/services/game_engine.dart` - Engine xử lý logic game

### 🎯 **Nhiệm vụ:**

#### **GameEngine (`game_engine.dart`)**

```dart
import 'dart:math';
import '../models/game_state.dart';
import '../constants/game_constants.dart';

/// Game engine that handles game loop and physics
class GameEngine {
  GameState _state;

  GameEngine({GameState? initialState, int? seed})
      : _state = initialState ?? GameState.initial(seed: seed);

  GameState get state => _state;

  /// Update game state by deltaTime (in seconds)
  void update(double deltaTime) {
    if (_state.isFinished) return;

    final newPositions = List<double>.from(_state.positions);
    final newSpeeds = List<double>.from(_state.speeds);
    final newElapsedTime = _state.elapsedTime + deltaTime;
    final newLeadHistory = List<int>.from(_state.leadHistory);
    int newCurrentLeader = _state.currentLeader;

    // Calculate speeds for each car
    for (int i = 0; i < 3; i++) {
      // 1. Base speed
      double speed = _state.baseSpeeds[i];

      // 2. Noise speed (smooth variation using sine wave)
      final noiseValue = sin(
        newElapsedTime * GameConstants.noiseFrequency * 2 * pi +
            _state.noisePhases[i],
      );
      speed += GameConstants.noiseAmplitude * noiseValue;

      // 3. Rubber banding
      final leader = _state.getLeader();
      if (leader == i) {
        // Leader: slow down slightly
        final distanceAhead = _state.positions[i] -
            _state.positions[(i + 1) % 3]
                .clamp(0, _state.positions[i]);
        final distanceAhead2 = _state.positions[i] -
            _state.positions[(i + 2) % 3]
                .clamp(0, _state.positions[i]);
        final maxDistance = max(distanceAhead, distanceAhead2);
        if (maxDistance > 0) {
          final rubberFactor = (maxDistance / GameConstants.maxDistanceForRubberBand)
              .clamp(0.0, 1.0);
          speed -= GameConstants.rubberBandStrength * rubberFactor;
        }
      } else {
        // Behind: speed up slightly
        final distanceBehind = _state.positions[leader] - _state.positions[i];
        if (distanceBehind > 0 && distanceBehind < GameConstants.maxDistanceForRubberBand) {
          final rubberFactor =
              (1.0 - distanceBehind / GameConstants.maxDistanceForRubberBand);
          speed += GameConstants.rubberBandStrength * rubberFactor;
        }
      }

      // Clamp speed to reasonable values
      speed = speed.clamp(30.0, 200.0);
      newSpeeds[i] = speed;

      // Update position
      newPositions[i] += speed * deltaTime;
      newPositions[i] = newPositions[i].clamp(0.0, _state.finishDistance);
    }

    // Track lead changes
    final newLeader = _getLeader(newPositions);
    if (newLeader != newCurrentLeader) {
      newLeadHistory.add(newLeader);
      newCurrentLeader = newLeader;
    }

    // Check finish
    bool isFinished = false;
    int? winner;
    for (int i = 0; i < newPositions.length; i++) {
      if (newPositions[i] >= _state.finishDistance) {
        isFinished = true;
        if (winner == null || newPositions[i] > newPositions[winner]) {
          winner = i;
        }
      }
    }

    // Update state
    _state = _state.copyWith(
      positions: newPositions,
      speeds: newSpeeds,
      elapsedTime: newElapsedTime,
      isFinished: isFinished,
      winner: winner,
      leadHistory: newLeadHistory,
      currentLeader: newCurrentLeader,
    );
  }

  /// Get current leader index
  int _getLeader(List<double> positions) {
    int leader = 0;
    double maxPos = positions[0];
    for (int i = 1; i < positions.length; i++) {
      if (positions[i] > maxPos) {
        maxPos = positions[i];
        leader = i;
      }
    }
    return leader;
  }

  /// Reset game state
  void reset({int? seed}) {
    _state = GameState.initial(seed: seed);
  }

  /// Get progress percentage (0.0 to 1.0) for a car
  double getProgress(int carIndex) {
    return (_state.positions[carIndex] / _state.finishDistance).clamp(0.0, 1.0);
  }

  /// Get current ranking (1st, 2nd, 3rd) for each car
  List<int> getRankings() {
    final positions = List<double>.from(_state.positions);
    final sorted = List<int>.generate(3, (i) => i);
    sorted.sort((a, b) => positions[b].compareTo(positions[a]));
    final rankings = List<int>.filled(3, 0);
    for (int i = 0; i < sorted.length; i++) {
      rankings[sorted[i]] = i + 1;
    }
    return rankings;
  }
}
```

**Giải thích:**
- `update(deltaTime)`: Cập nhật game state mỗi frame
  - Tính tốc độ mới (base + noise + rubber band)
  - Cập nhật vị trí (position += speed * deltaTime)
  - Track lead changes
  - Kiểm tra finish
- `reset()`: Reset game state
- `getProgress()`: Lấy progress (0.0 đến 1.0)
- `getRankings()`: Lấy thứ hạng (1st, 2nd, 3rd)

**Physics:**
1. **Base Speed**: Tốc độ cơ bản (80-120 px/s, random)
2. **Noise**: Biến thiên mượt dùng sin wave (±10 px/s)
3. **Rubber Banding**: 
   - Leader chậm lại nếu dẫn đầu quá xa
   - Follower tăng tốc nếu bị tụt lại
   - Tạo hiệu ứng "rượt đuổi"

### 🔗 **Dependencies:**
- Cần import `GameState` từ `models/game_state.dart` (người 3 làm)
- Cần import `GameConstants` từ `constants/game_constants.dart` (người 6 làm)

### ✅ **Checklist:**
- [ ] GameEngine tính toán physics đúng
- [ ] Base speed được áp dụng đúng
- [ ] Noise speed tạo biến thiên mượt
- [ ] Rubber banding hoạt động (xe đuổi kịp)
- [ ] Lead tracking đúng
- [ ] Finish detection đúng
- [ ] getProgress() trả về đúng (0.0 đến 1.0)
- [ ] getRankings() trả về đúng (1st, 2nd, 3rd)

### 📚 **Kiến thức cần:**
- Game loop và deltaTime
- Physics simulation (speed, position)
- Math (sin, cos, clamp, max)
- List operations và sorting

---

## 👤 Khoa: RACE SCREEN

### 📦 **Files cần làm:**
- `lib/screens/new_race_screen.dart` - Màn hình đua xe

### 🎯 **Nhiệm vụ:**

#### **Race Screen (`new_race_screen.dart`)**

**State Variables:**
```dart
late GameEngine _engine;
Timer? _gameLoop;
bool _isRacing = false;
final AudioPlayer _audioPlayer = AudioPlayer();
```

**Game Loop (60fps):**
```dart
void _startRace() async {
  if (_isRacing) return;

  setState(() {
    _isRacing = true;
  });

  // Phát nhạc nền
  _playBackgroundMusic();

  // Game loop at 60fps (16ms per frame)
  _gameLoop = Timer.periodic(
    const Duration(milliseconds: 16), // ~60fps
    (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      _engine.update(16 / 1000.0); // deltaTime in seconds
      setState(() {}); // Rebuild UI

      // Check if race finished
      if (_engine.state.isFinished) {
        timer.cancel();
        _onRaceFinished();
      }
    },
  );
}

Future<void> _playBackgroundMusic() async {
  try {
    await _audioPlayer.setPlayerMode(PlayerMode.mediaPlayer);
    await _audioPlayer.setVolume(1.0);
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(AssetSource('audio/race_screen.mp3'));
  } catch (e) {
    print('❌ Error playing race music: $e');
  }
}

void _onRaceFinished() async {
  final winner = _engine.state.winner;
  if (winner == null) return;

  // Dừng nhạc nền khi race kết thúc
  try {
    await _audioPlayer.stop();
  } catch (e) {
    print('❌ Error stopping audio: $e');
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
```

**Layout:**
- Header: Title + Start button
- Track: Stack với TrackWidget, CarWidget, ProgressBarWidget
- Info Panel: Rankings, speeds, elapsed time (dùng CarInfoWidget)

**UI Components:**
- Dùng `LayoutBuilder` để responsive
- Dùng `Stack` để overlay các widget
- Dùng `Positioned` để đặt xe
- Dùng `AnimatedPositioned` hoặc `setState` để animation

### 🔗 **Dependencies:**
- Cần import `GameEngine` từ `services/game_engine.dart` (người 4 làm)
- Cần import `GameState` từ `models/game_state.dart` (người 3 làm)
- Cần import `BetState` từ `models/bet_state.dart` (người 2 làm)
- Cần import `CarWidget`, `TrackWidget`, `ProgressBarWidget`, `CarInfoWidget` từ `components/` (người 6 làm)
- Cần import `GameConstants` từ `constants/game_constants.dart` (người 6 làm)
- Cần import `NewResultScreen` từ `screens/new_result_screen.dart` (người 6 làm)
- Cần import `audioplayers` package

### ✅ **Checklist:**
- [ ] Game loop chạy 60fps
- [ ] Cars di chuyển mượt
- [ ] UI hiển thị đúng (track, cars, progress bars)
- [ ] Rankings hiển thị real-time
- [ ] Speeds hiển thị real-time
- [ ] Elapsed time hiển thị
- [ ] Audio phát khi bắt đầu (race_screen.mp3)
- [ ] Audio dừng khi kết thúc
- [ ] Navigation sang result screen với winner đúng
- [ ] Dispose đúng cách (Timer, AudioPlayer)

### 📚 **Kiến thức cần:**
- Game loop và Timer.periodic
- State management (setState trong game loop)
- Layout (Stack, Positioned, LayoutBuilder)
- Animation (setState để update UI)
- Audio playback (audioplayers package)
- Navigation (Navigator.pushReplacement)

---

## 👤 Hậu: RESULT SCREEN + UI COMPONENTS + ASSETS

### 📦 **Files cần làm:**
- `lib/screens/new_result_screen.dart` - Màn hình kết quả
- `lib/constants/game_constants.dart` - Tất cả constants
- `lib/constants/car_config.dart` - Cấu hình xe
- `lib/components/car_widget.dart` - Widget hiển thị xe
- `lib/components/track_widget.dart` - Widget hiển thị đường đua
- `lib/components/progress_bar_widget.dart` - Widget progress bar
- `lib/components/car_info_widget.dart` - Widget thông tin xe
- `assets/images/` - Ảnh xe (red_car.png, blue_car.png, yellow_car.png)
- `assets/audio/` - Nhạc nền (bet_screen.mp3, race_screen.mp3, win_screen.mp3, lose_creen.mp3)
- `pubspec.yaml` - Khai báo assets

### 🎯 **Nhiệm vụ:**

#### 1. **Result Screen (`new_result_screen.dart`)**

**Input:**
- `BetState betState` - State đặt cược (từ betting screen)
- `int winner` - Xe thắng (0, 1, hoặc 2)
- `GameEngine engine` - Engine để lấy stats

**Logic chính:**

```dart
// Tính tiền thắng
double _calculateWinnings() {
  return betState.calculateWinnings(winner);
}

// Tính BetState mới sau khi race
BetState _getUpdatedBetState() {
  final winnings = _calculateWinnings();
  final newTotal = betState.totalMoney - betState.betAmount + winnings;
  return betState.copyWith(totalMoney: newTotal);
}

Future<void> _playResultMusic() async {
  try {
    final isWin = betState.selectedCar == winner;
    final audioFile = isWin ? 'audio/win_screen.mp3' : 'audio/lose_creen.mp3';
    
    await _audioPlayer.setPlayerMode(PlayerMode.mediaPlayer);
    await _audioPlayer.setVolume(1.0);
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(AssetSource(audioFile));
  } catch (e) {
    print('❌ Error playing result music: $e');
  }
}

// Build action buttons
Widget _buildActionButtons(BuildContext context, BetState updatedState) {
  if (updatedState.isBroke()) {
    // Hết tiền: hiển thị thông báo và nút đăng nhập lại
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.shade300, width: 1.5),
          ),
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 28, color: Colors.red.shade700),
              const SizedBox(height: 6),
              const Text(
                'Oops bạn đã thua rồi',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Hãy nhớ người không chơi là người thắng',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.red,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Đăng Nhập Lại'),
          ),
        ),
      ],
    );
  }

  // Còn tiền: hiển thị 2 nút
  return Row(
    children: [
      Expanded(
        child: OutlinedButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => NewBettingScreen(initialBetState: updatedState),
              ),
              (route) => false,
            );
          },
          child: const Text('Về Trang Chủ'),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => NewBettingScreen(initialBetState: updatedState),
              ),
            );
          },
          child: const Text('Chơi Lại'),
        ),
      ),
    ],
  );
}
```

**Layout (Landscape - Row):**
- **Bên trái (Expanded flex: 3)**:
  - Card hiển thị xe thắng (với icon trophy)
  - Card hiển thị kết quả (Thắng/Thua, số tiền cược, số tiền thắng/mất)
- **Bên phải (Expanded flex: 2)**:
  - Card hiển thị tổng tiền sau race
  - Card thống kê (thời gian, lead changes, seed)
  - Action buttons (Về Trang Chủ / Chơi Lại hoặc Đăng Nhập Lại)

#### 2. **Game Constants (`game_constants.dart`)**

```dart
class GameConstants {
  // Car dimensions
  static const double carWidth = 80.0;
  static const double carHeight = 60.0;

  // Track
  static const double topLaneY = 100.0;
  static const double laneSpacing = 120.0;
  static const double finishDistance = 2000.0;

  // Speed
  static const double baseSpeedMin = 80.0; // px/s
  static const double baseSpeedMax = 120.0; // px/s
  static const double noiseAmplitude = 10.0; // px/s
  static const double noiseFrequency = 0.5; // Hz

  // Rubber banding
  static const double rubberBandStrength = 15.0; // px/s
  static const double maxDistanceForRubberBand = 200.0; // px

  // Betting
  static const double betOdds = 2.0; // 2x multiplier if win
  static const double initialMoney = 100000.0; // 100,000 VNĐ
}
```

#### 3. **Car Config (`car_config.dart`)**

```dart
import 'package:flutter/material.dart';

class CarConfig {
  static const List<String> carImagePaths = [
    'assets/images/red_car.png',
    'assets/images/blue_car.png',
    'assets/images/yellow_car.png',
  ];

  static const List<Color> carColors = [
    Colors.red,
    Colors.blue,
    Colors.yellow,
  ];

  static const List<String> carNames = [
    'Xe Đỏ',
    'Xe Xanh',
    'Xe Vàng',
  ];

  static String getCarImagePath(int index) {
    if (index < 0 || index >= carImagePaths.length) {
      return carImagePaths[0];
    }
    return carImagePaths[index];
  }

  static Color getCarColor(int index) {
    if (index < 0 || index >= carColors.length) {
      return carColors[0];
    }
    return carColors[index];
  }

  static String getCarName(int index) {
    if (index < 0 || index >= carNames.length) {
      return carNames[0];
    }
    return carNames[index];
  }
}
```

#### 4. **Car Widget (`car_widget.dart`)**

```dart
import 'package:flutter/material.dart';
import '../constants/game_constants.dart';
import '../constants/car_config.dart';

class CarWidget extends StatelessWidget {
  final int carIndex;
  final double progress;
  final double x;
  final double y;

  const CarWidget({
    super.key,
    required this.carIndex,
    required this.progress,
    required this.x,
    required this.y,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: x,
      top: y,
      child: Image.asset(
        CarConfig.getCarImagePath(carIndex),
        width: GameConstants.carWidth,
        height: GameConstants.carHeight,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: GameConstants.carWidth,
            height: GameConstants.carHeight,
            decoration: BoxDecoration(
              color: CarConfig.getCarColor(carIndex),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.directions_car, color: Colors.white, size: 40),
          );
        },
      ),
    );
  }
}
```

#### 5. **Track Widget (`track_widget.dart`)**

```dart
import 'package:flutter/material.dart';

class TrackWidget extends StatelessWidget {
  final double trackWidth;
  final double trackHeight;
  final List<double> laneYPositions;

  const TrackWidget({
    super.key,
    required this.trackWidth,
    required this.trackHeight,
    required this.laneYPositions,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Track background
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.grey.shade400,
                  Colors.grey.shade600,
                ],
              ),
              border: Border.all(
                color: Colors.grey.shade800,
                width: 4,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: CustomPaint(
              painter: RoadLinesPainter(
                laneY1: laneYPositions[0],
                laneY2: laneYPositions[1],
                trackWidth: trackWidth,
              ),
            ),
          ),
        ),
        // Start line (green)
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: Container(
            width: 6,
            decoration: BoxDecoration(
              color: Colors.green,
              border: Border.symmetric(
                vertical: BorderSide(color: Colors.white, width: 2),
              ),
            ),
          ),
        ),
        // Finish line (red)
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          child: Container(
            width: 6,
            decoration: BoxDecoration(
              color: Colors.red,
              border: Border.symmetric(
                vertical: BorderSide(color: Colors.white, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Custom painter cho đường kẻ
class RoadLinesPainter extends CustomPainter {
  final double laneY1;
  final double laneY2;
  final double trackWidth;

  RoadLinesPainter({
    required this.laneY1,
    required this.laneY2,
    required this.trackWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.yellow.shade700
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    const dashLength = 30.0;
    const dashSpace = 20.0;
    double currentX = 20;

    // Vẽ đường kẻ ngang (dashed lines)
    while (currentX < trackWidth - 20) {
      canvas.drawLine(
        Offset(currentX, laneY1),
        Offset(currentX + dashLength, laneY1),
        paint,
      );
      canvas.drawLine(
        Offset(currentX, laneY2),
        Offset(currentX + dashLength, laneY2),
        paint,
      );
      currentX += dashLength + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant RoadLinesPainter oldDelegate) =>
      oldDelegate.laneY1 != laneY1 ||
      oldDelegate.laneY2 != laneY2 ||
      oldDelegate.trackWidth != trackWidth;
}
```

#### 6. **Progress Bar Widget (`progress_bar_widget.dart`)**

```dart
import 'package:flutter/material.dart';
import '../constants/game_constants.dart';
import '../constants/car_config.dart';

class ProgressBarWidget extends StatelessWidget {
  final int carIndex;
  final double progress; // 0.0 to 1.0
  final double laneSpacing;
  final bool isLast;

  const ProgressBarWidget({
    super.key,
    required this.carIndex,
    required this.progress,
    required this.laneSpacing,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        bottom: isLast ? 0 : laneSpacing - GameConstants.carHeight,
      ),
      width: 8,
      height: GameConstants.carHeight,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: 8,
          height: GameConstants.carHeight * progress,
          decoration: BoxDecoration(
            color: CarConfig.getCarColor(carIndex),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
```

#### 7. **Car Info Widget (`car_info_widget.dart`)**

```dart
import 'package:flutter/material.dart';
import '../constants/car_config.dart';

class CarInfoWidget extends StatelessWidget {
  final int carIndex;
  final int ranking;
  final double speed;

  const CarInfoWidget({
    super.key,
    required this.carIndex,
    required this.ranking,
    required this.speed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          CarConfig.getCarName(carIndex),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: CarConfig.getCarColor(carIndex),
          ),
        ),
        Text(
          '$ranking',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          '${speed.toStringAsFixed(0)} px/s',
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
```

#### 8. **Assets Setup (`pubspec.yaml`)**

```yaml
flutter:
  uses-material-design: true

  assets:
    - assets/images/red_car.png
    - assets/images/blue_car.png
    - assets/images/yellow_car.png
    - assets/audio/
```

### 🔗 **Dependencies:**
- Không phụ thuộc vào code của người khác (chỉ constants và config)
- Tất cả người khác sẽ import các file này

### ✅ **Checklist:**
- [ ] Result screen hiển thị đúng
- [ ] Tính tiền thắng đúng (2x nếu đúng xe)
- [ ] Tính tổng tiền sau race đúng
- [ ] Audio phát đúng (win_screen.mp3 nếu thắng, lose_creen.mp3 nếu thua)
- [ ] GameConstants đầy đủ và đúng
- [ ] CarConfig có đủ 3 xe
- [ ] CarWidget hiển thị ảnh xe đúng
- [ ] TrackWidget vẽ đường đua đẹp
- [ ] ProgressBarWidget hiển thị progress đúng
- [ ] CarInfoWidget hiển thị thông tin đúng
- [ ] Assets được khai báo trong pubspec.yaml
- [ ] Ảnh xe tồn tại trong assets/images/
- [ ] Audio tồn tại trong assets/audio/
- [ ] Error handling (errorBuilder cho Image.asset)

### 📚 **Kiến thức cần:**
- Conditional rendering (if-else trong build)
- Navigation (pushReplacement, pushAndRemoveUntil)
- State management (truyền state qua navigation)
- Money calculation
- Flutter Widget basics
- CustomPaint và Canvas
- Image.asset và error handling
- Constants và configuration
- Asset management (pubspec.yaml)
- Layout (Positioned, Stack, Align)
- Styling (Container, BoxDecoration, Gradient)
- Audio playback (audioplayers package)

---

## 🔄 WORKFLOW & INTEGRATION

### **Thứ tự làm việc:**

1. **Người 6** làm trước (Components & Constants) - không phụ thuộc ai
2. **Người 1** làm tiếp (Login & Setup) - cần Constants từ người 6
3. **Người 2** làm tiếp (Betting) - cần Constants từ người 6
4. **Người 3** làm tiếp (GameState Model) - cần Constants từ người 6
5. **Người 4** làm tiếp (GameEngine) - cần GameState từ người 3, Constants từ người 6
6. **Người 5** làm tiếp (Race Screen) - cần GameEngine từ người 4, Components từ người 6, BetState từ người 2
7. **Người 6** làm cuối (Result Screen) - cần tất cả các phần trước

### **Integration Checklist:**

- [ ] Người 6: Push code Components & Constants
- [ ] Người 1: Pull code, làm Login Screen
- [ ] Người 2: Pull code, làm Betting Screen
- [ ] Người 3: Pull code, làm GameState Model
- [ ] Người 4: Pull code, làm GameEngine
- [ ] Người 5: Pull code, làm Race Screen
- [ ] Người 6: Pull code, làm Result Screen
- [ ] Test end-to-end: Login → Bet → Race → Result → Betting (loop)

### **Git Workflow:**

```bash
# Mỗi người tạo branch riêng
git checkout -b feature/person1-login
git checkout -b feature/person2-betting
git checkout -b feature/person3-gamestate
git checkout -b feature/person4-engine
git checkout -b feature/person5-race
git checkout -b feature/person6-components-result

# Sau khi xong, merge vào main
git checkout main
git merge feature/person6-components-result
git merge feature/person1-login
# ... tiếp tục
```

---

## 📝 NOTES

- **Communication**: Mỗi người cần thông báo khi hoàn thành phần của mình
- **Testing**: Test riêng phần của mình trước khi push
- **Code Style**: Follow Flutter/Dart conventions
- **Comments**: Comment code phức tạp
- **Error Handling**: Luôn có error handling (try-catch, errorBuilder, etc.)

---

## 🎓 TÀI LIỆU THAM KHẢO

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Flutter Widget Catalog](https://docs.flutter.dev/ui/widgets)
- [State Management](https://docs.flutter.dev/data-and-backend/state-mgmt)

---

**Chúc team làm việc tốt! 🚀**
