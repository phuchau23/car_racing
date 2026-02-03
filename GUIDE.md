# 📚 HƯỚNG DẪN CHI TIẾT CODE - MINI RACING GAME

## 📋 MỤC LỤC
1. [Tổng quan dự án](#tổng-quan-dự-án)
2. [Cấu trúc thư mục](#cấu-trúc-thư-mục)
3. [Entry Point - main.dart](#entry-point---maindart)
4. [Models - Data Structures](#models---data-structures)
5. [Services - Business Logic](#services---business-logic)
6. [Constants - Cấu hình](#constants---cấu-hình)
7. [Utils - Tiện ích](#utils---tiện-ích)
8. [Screens - Màn hình](#screens---màn-hình)
9. [Components - Widgets](#components---widgets)
10. [Luồng hoạt động](#luồng-hoạt-động)

---

## 🎯 TỔNG QUAN DỰ ÁN

**Mini Racing Game** là một game đua xe đơn giản với hệ thống cược:
- Người chơi đăng nhập (fake login)
- Bắt đầu với 100,000 VNĐ
- Chọn xe và đặt cược
- Xem đua và nhận kết quả
- Thắng/thua dựa trên xe được chọn

---

## 📁 CẤU TRÚC THƯ MỤC

```
lib/
├── main.dart                    # Entry point
├── models/                     # Data models
│   ├── bet_state.dart          # State đặt cược
│   └── game_state.dart         # State game đua
├── services/                   # Business logic
│   └── game_engine.dart        # Engine xử lý game
├── constants/                  # Constants
│   ├── game_constants.dart     # Hằng số game
│   └── car_config.dart         # Cấu hình xe
├── utils/                      # Utilities
│   └── orientation_helper.dart # Helper quản lý hướng màn hình
├── screens/                    # Màn hình
│   ├── login_screen.dart       # Màn hình đăng nhập
│   ├── new_betting_screen.dart # Màn hình đặt cược
│   ├── new_race_screen.dart    # Màn hình đua xe
│   └── new_result_screen.dart  # Màn hình kết quả
└── components/                 # Widgets tái sử dụng
    ├── car_widget.dart         # Widget hiển thị xe
    ├── track_widget.dart       # Widget đường đua
    ├── progress_bar_widget.dart # Widget thanh tiến trình
    └── car_info_widget.dart    # Widget thông tin xe
```

---

## 🚀 ENTRY POINT - main.dart

### File: `lib/main.dart`

**Mục đích**: Điểm khởi đầu của ứng dụng, khởi tạo app và set orientation.

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Set landscape orientation from the start
  OrientationHelper.setLandscape();
  runApp(const MyApp());
}
```

**Giải thích từng dòng:**
- `WidgetsFlutterBinding.ensureInitialized()`: Đảm bảo Flutter binding đã được khởi tạo trước khi chạy app
- `OrientationHelper.setLandscape()`: Set màn hình ngang ngay từ đầu
- `runApp(const MyApp())`: Khởi chạy ứng dụng với widget MyApp

**Class MyApp:**
```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini Racing Game',
      debugShowCheckedModeBanner: false,  // Ẩn banner "DEBUG"
      theme: ThemeData(...),              // Theme của app
      home: const LoginScreen(),           // Màn hình đầu tiên
    );
  }
}
```

---

## 📊 MODELS - DATA STRUCTURES

### 1. File: `lib/models/bet_state.dart`

**Mục đích**: Quản lý state đặt cược của người chơi.

#### Class BetState

```dart
class BetState {
  final double totalMoney;    // Tổng tiền hiện có (VNĐ)
  final int? selectedCar;     // Xe được chọn (0, 1, hoặc 2)
  final double betAmount;     // Số tiền cược (VNĐ)
}
```

**Giải thích:**
- `totalMoney`: Số tiền người chơi có, mặc định 100,000 VNĐ
- `selectedCar`: Index của xe được chọn (null nếu chưa chọn)
- `betAmount`: Số tiền đặt cược

#### Method: `copyWith()`
```dart
BetState copyWith({double? totalMoney, int? selectedCar, double? betAmount}) {
  return BetState(
    totalMoney: totalMoney ?? this.totalMoney,  // Nếu null thì giữ giá trị cũ
    selectedCar: selectedCar ?? this.selectedCar,
    betAmount: betAmount ?? this.betAmount,
  );
}
```
**Mục đích**: Tạo bản copy với các giá trị mới (immutable pattern)

#### Method: `canPlaceBet()`
```dart
bool canPlaceBet() {
  return selectedCar != null &&           // Đã chọn xe
      betAmount > 0.0 &&                   // Số tiền > 0
      betAmount <= totalMoney &&           // Không vượt quá số tiền có
      (totalMoney - betAmount) >= 0.0;     // Còn lại >= 0
}
```
**Mục đích**: Kiểm tra xem có thể đặt cược không

#### Method: `calculateWinnings()`
```dart
double calculateWinnings(int winner) {
  if (selectedCar == null || betAmount == 0) return 0.0;
  if (selectedCar == winner) {
    return betAmount * 2.0;  // Thắng: nhận gấp đôi
  }
  return 0.0;  // Thua: mất hết
}
```
**Mục đích**: Tính số tiền thắng (2x nếu thắng, 0 nếu thua)

#### Method: `isBroke()`
```dart
bool isBroke() {
  return totalMoney <= 0;  // Hết tiền
}
```

---

### 2. File: `lib/models/game_state.dart`

**Mục đích**: Quản lý state của game đua (vị trí, tốc độ xe, v.v.)

#### Class GameState

```dart
class GameState {
  final List<double> positions;      // Vị trí X của 3 xe (0 đến finishDistance)
  final List<double> speeds;          // Tốc độ hiện tại của 3 xe (pixels/second)
  final List<double> baseSpeeds;      // Tốc độ cơ bản của 3 xe
  final List<double> noisePhases;     // Phase cho tính toán noise (sin wave)
  final List<double> laneY;           // Vị trí Y của 3 làn đường
  final double finishDistance;        // Khoảng cách đến đích (2000 pixels)
  final double elapsedTime;           // Thời gian đã trôi qua (seconds)
  final bool isFinished;              // Đã kết thúc chưa
  final int? winner;                 // Index xe thắng (null nếu chưa xong)
  final int seed;                     // Seed cho random
  final List<int> leadHistory;       // Lịch sử thay đổi người dẫn đầu
  final int currentLeader;            // Index xe đang dẫn đầu
}
```

#### Factory: `GameState.initial()`
```dart
factory GameState.initial({int? seed}) {
  final random = Random(seed ?? DateTime.now().millisecondsSinceEpoch);
  final gameSeed = seed ?? random.nextInt(1000000);
  final rng = Random(gameSeed);

  // Tạo tốc độ cơ bản ngẫu nhiên cho 3 xe
  final baseSpeeds = List.generate(3, (i) {
    return GameConstants.baseSpeedMin +
        rng.nextDouble() * (GameConstants.baseSpeedMax - GameConstants.baseSpeedMin);
  });

  // Tạo phase ngẫu nhiên cho noise
  final noisePhases = List.generate(3, (i) => rng.nextDouble() * 2 * pi);

  // Tính vị trí Y của 3 làn đường
  final laneY = List.generate(3, (i) {
    return GameConstants.topLaneY + (i * GameConstants.laneSpacing);
  });

  return GameState(
    positions: [0.0, 0.0, 0.0],  // Bắt đầu từ 0
    speeds: List.from(baseSpeeds),
    baseSpeeds: baseSpeeds,
    noisePhases: noisePhases,
    laneY: laneY,
    finishDistance: GameConstants.finishDistance,
    seed: gameSeed,
    currentLeader: 0,
  );
}
```
**Giải thích:**
- Tạo seed ngẫu nhiên hoặc dùng seed được truyền vào
- Tạo tốc độ cơ bản cho 3 xe (80-120 pixels/second)
- Tạo phase cho noise (để tạo biến thiên tốc độ mượt)
- Tính vị trí Y của 3 làn đường

#### Method: `getLeader()`
```dart
int getLeader() {
  int leader = 0;
  double maxPos = positions[0];
  for (int i = 1; i < positions.length; i++) {
    if (positions[i] > maxPos) {
      maxPos = positions[i];
      leader = i;
    }
  }
  return leader;  // Trả về index xe có vị trí cao nhất
}
```

---

## ⚙️ SERVICES - BUSINESS LOGIC

### File: `lib/services/game_engine.dart`

**Mục đích**: Xử lý logic game, tính toán tốc độ, vị trí xe.

#### Class GameEngine

```dart
class GameEngine {
  GameState _state;  // State hiện tại của game

  GameEngine({GameState? initialState, int? seed})
      : _state = initialState ?? GameState.initial(seed: seed);
}
```

#### Method: `update(double deltaTime)`

**Mục đích**: Cập nhật game state mỗi frame (60fps = 16ms/frame)

**Luồng xử lý:**

1. **Kiểm tra đã kết thúc chưa:**
```dart
if (_state.isFinished) return;  // Nếu đã kết thúc thì không update nữa
```

2. **Tạo bản copy của state:**
```dart
final newPositions = List<double>.from(_state.positions);
final newSpeeds = List<double>.from(_state.speeds);
final newElapsedTime = _state.elapsedTime + deltaTime;
```

3. **Tính tốc độ cho từng xe (3 bước):**

**Bước 1: Base Speed**
```dart
double speed = _state.baseSpeeds[i];  // Tốc độ cơ bản
```

**Bước 2: Noise (Biến thiên mượt)**
```dart
final noiseValue = sin(
  newElapsedTime * GameConstants.noiseFrequency * 2 * pi +
      _state.noisePhases[i],
);
speed += GameConstants.noiseAmplitude * noiseValue;
```
**Giải thích:**
- Dùng sin wave để tạo biến thiên mượt
- `noiseFrequency = 0.2 Hz` → thay đổi mỗi ~5 giây
- `noiseAmplitude = 20` → biến thiên ±20 pixels/second

**Bước 3: Rubber Banding (Hiệu ứng đuổi kịp)**
```dart
final leader = _state.getLeader();
if (leader == i) {
  // Xe dẫn đầu: chậm lại một chút
  final distanceAhead = _state.positions[i] - _state.positions[(i + 1) % 3];
  // ... tính toán và giảm tốc độ
  speed -= GameConstants.rubberBandStrength * rubberFactor;
} else {
  // Xe phía sau: tăng tốc để đuổi kịp
  final distanceBehind = _state.positions[leader] - _state.positions[i];
  if (distanceBehind < GameConstants.maxDistanceForRubberBand) {
    speed += GameConstants.rubberBandStrength * rubberFactor;
  }
}
```
**Giải thích:**
- Xe dẫn đầu quá xa → chậm lại
- Xe phía sau → tăng tốc để đuổi kịp
- Tạo hiệu ứng "chasing" thú vị

4. **Giới hạn tốc độ:**
```dart
speed = speed.clamp(30.0, 200.0);  // Tốc độ từ 30-200 pixels/second
```

5. **Cập nhật vị trí:**
```dart
newPositions[i] += speed * deltaTime;  // Vị trí mới = vị trí cũ + tốc độ * thời gian
newPositions[i] = newPositions[i].clamp(0.0, _state.finishDistance);
```

6. **Theo dõi thay đổi người dẫn đầu:**
```dart
final newLeader = _getLeader(newPositions);
if (newLeader != newCurrentLeader) {
  newLeadHistory.add(newLeader);  // Ghi lại lịch sử
  newCurrentLeader = newLeader;
}
```

7. **Kiểm tra kết thúc:**
```dart
for (int i = 0; i < newPositions.length; i++) {
  if (newPositions[i] >= _state.finishDistance) {
    isFinished = true;
    winner = i;  // Xe đầu tiên về đích
    break;
  }
}
```

#### Method: `getProgress(int carIndex)`
```dart
double getProgress(int carIndex) {
  return (_state.positions[carIndex] / _state.finishDistance).clamp(0.0, 1.0);
}
```
**Mục đích**: Trả về tiến trình (0.0 = bắt đầu, 1.0 = về đích)

#### Method: `getRankings()`
```dart
List<int> getRankings() {
  final positions = List<double>.from(_state.positions);
  final sorted = List<int>.generate(3, (i) => i);
  sorted.sort((a, b) => positions[b].compareTo(positions[a]));  // Sắp xếp giảm dần
  final rankings = List<int>.filled(3, 0);
  for (int i = 0; i < sorted.length; i++) {
    rankings[sorted[i]] = i + 1;  // Xe sorted[0] = hạng 1, sorted[1] = hạng 2, ...
  }
  return rankings;
}
```
**Mục đích**: Trả về hạng của từng xe (1, 2, 3)

---

## 🔧 CONSTANTS - CẤU HÌNH

### 1. File: `lib/constants/game_constants.dart`

**Mục đích**: Chứa tất cả hằng số của game.

```dart
class GameConstants {
  // Race settings
  static const double finishDistance = 2000.0;  // Khoảng cách đích (pixels)
  static const double raceTimeMin = 25.0;       // Thời gian đua tối thiểu (seconds)
  static const double raceTimeMax = 40.0;        // Thời gian đua tối đa (seconds)

  // Speed settings
  static const double baseSpeedMin = 80.0;       // Tốc độ cơ bản tối thiểu
  static const double baseSpeedMax = 120.0;     // Tốc độ cơ bản tối đa
  static const double noiseAmplitude = 20.0;     // Biên độ noise
  static const double noiseFrequency = 0.2;      // Tần số noise (Hz)

  // Rubber banding
  static const double rubberBandStrength = 15.0;        // Độ mạnh rubber band
  static const double maxDistanceForRubberBand = 250.0; // Khoảng cách tối đa để áp dụng

  // Lane settings
  static const double laneSpacing = 100.0;  // Khoảng cách giữa các làn
  static const double topLaneY = 150.0;     // Vị trí Y của làn trên cùng
  static const double carWidth = 80.0;       // Chiều rộng xe
  static const double carHeight = 60.0;     // Chiều cao xe

  // Betting
  static const double betOdds = 2.0;              // Tỷ lệ cược (2x nếu thắng)
  static const double initialMoney = 100000.0;    // Số tiền ban đầu (VNĐ)
}
```

### 2. File: `lib/constants/car_config.dart`

**Mục đích**: Cấu hình về xe (ảnh, màu, tên).

```dart
class CarConfig {
  // Đường dẫn ảnh xe
  static const List<String> carImagePaths = [
    'assets/images/red_car.png',
    'assets/images/blue_car.png',
    'assets/images/yellow_car.png',
  ];

  // Màu xe (fallback nếu ảnh không load)
  static const List<Color> carColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
  ];

  // Tên xe
  static const List<String> carNames = [
    'Xe Đỏ',
    'Xe Xanh',
    'Xe Vàng',
  ];

  // Methods để lấy thông tin theo index
  static String getCarImagePath(int index) { ... }
  static Color getCarColor(int index) { ... }
  static String getCarName(int index) { ... }
}
```

---

## 🛠️ UTILS - TIỆN ÍCH

### File: `lib/utils/orientation_helper.dart`

**Mục đích**: Helper để quản lý hướng màn hình.

```dart
class OrientationHelper {
  static void setLandscape() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  static void setPortrait() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
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
- `setLandscape()`: Chỉ cho phép màn hình ngang
- `setPortrait()`: Chỉ cho phép màn hình dọc
- `setAll()`: Cho phép tất cả hướng

---

## 📱 SCREENS - MÀN HÌNH

### 1. File: `lib/screens/login_screen.dart`

**Mục đích**: Màn hình đăng nhập (fake login).

#### State Variables:
```dart
final TextEditingController _usernameController;  // Controller cho input username
final TextEditingController _passwordController;  // Controller cho input password
final _formKey = GlobalKey<FormState>();         // Key để validate form
```

#### Method: `_handleLogin()`
```dart
void _handleLogin() {
  if (_formKey.currentState!.validate()) {  // Validate form
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

**Layout:**
- Bên trái: Logo + Title
- Bên phải: Form đăng nhập (username, password, button)

---

### 2. File: `lib/screens/new_betting_screen.dart`

**Mục đích**: Màn hình đặt cược - chọn xe và nhập số tiền.

#### State Variables:
```dart
late BetState _betState;                        // State đặt cược
final TextEditingController _betAmountController; // Controller cho input số tiền
int? _selectedCar;                              // Xe được chọn (null nếu chưa chọn)
```

#### Method: `_selectCar(int carIndex)`
```dart
void _selectCar(int carIndex) {
  setState(() {
    _selectedCar = carIndex;  // Lưu index xe được chọn
  });
}
```

#### Method: `_updateBetAmount(String value)`
```dart
void _updateBetAmount(String value) {
  if (value.isEmpty) {
    _betState = _betState.copyWith(betAmount: 0.0);
    return;
  }

  final amount = double.tryParse(value.trim()) ?? 0.0;
  final clampedAmount = amount.clamp(0.0, _betState.totalMoney);  // Giới hạn trong khoảng 0-totalMoney

  setState(() {
    _betState = _betState.copyWith(betAmount: clampedAmount);
  });
}
```

#### Method: `_startRace()`
```dart
void _startRace() {
  // Validate
  if (_selectedCar == null) {
    // Hiển thị lỗi: chưa chọn xe
    return;
  }

  final betAmountFromController = double.tryParse(_betAmountController.text.trim());
  if (betAmountFromController == null || betAmountFromController <= 0) {
    // Hiển thị lỗi: số tiền không hợp lệ
    return;
  }

  if (betAmountFromController > _betState.totalMoney) {
    // Hiển thị lỗi: vượt quá số tiền có
    return;
  }

  // Tạo bet state với xe và số tiền đã chọn
  final tempBetState = _betState.copyWith(
    selectedCar: _selectedCar,
    betAmount: betAmountFromController,
  );

  // Chuyển sang màn hình đua
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => NewRaceScreen(betState: tempBetState),
    ),
  ).then((result) {
    // Nhận kết quả từ màn hình đua (updated bet state)
    if (result != null && result is BetState) {
      setState(() {
        _betState = result;  // Cập nhật số tiền
        _selectedCar = null;
        _betAmountController.text = '0';
      });
    }
  });
}
```

**Layout:**
- Bên trái: Hiển thị số tiền + 3 xe để chọn
- Bên phải: Input số tiền cược + nút "BẮT ĐẦU ĐUA"

---

### 3. File: `lib/screens/new_race_screen.dart`

**Mục đích**: Màn hình đua xe - hiển thị game và xử lý game loop.

#### State Variables:
```dart
late GameEngine _engine;    // Game engine
Timer? _gameLoop;            // Timer cho game loop (60fps)
bool _isRacing = false;      // Đang đua hay chưa
```

#### Method: `_startRace()`
```dart
void _startRace() {
  if (_isRacing) return;  // Nếu đang đua rồi thì không làm gì

  setState(() {
    _isRacing = true;
  });

  // Game loop chạy 60fps (mỗi 16ms)
  _gameLoop = Timer.periodic(
    const Duration(milliseconds: 16),
    (timer) {
      if (!mounted) {
        timer.cancel();  // Nếu widget đã bị dispose thì dừng
        return;
      }

      _engine.update(16 / 1000.0);  // Update game (deltaTime = 0.016s)
      setState(() {});  // Rebuild UI

      // Kiểm tra đã kết thúc chưa
      if (_engine.state.isFinished) {
        timer.cancel();
        _onRaceFinished();
      }
    },
  );
}
```

**Giải thích:**
- `Timer.periodic`: Tạo timer chạy định kỳ mỗi 16ms (≈60fps)
- `_engine.update()`: Cập nhật game state (tốc độ, vị trí xe)
- `setState()`: Rebuild UI để hiển thị vị trí mới
- Khi kết thúc → gọi `_onRaceFinished()`

#### Method: `_onRaceFinished()`
```dart
void _onRaceFinished() {
  final winner = _engine.state.winner;
  if (winner == null) return;

  Future.delayed(const Duration(milliseconds: 500), () {
    if (!mounted) return;
    // Chuyển sang màn hình kết quả
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
- Header: Trạng thái + nút "BẮT ĐẦU"
- Track: Stack chứa:
  - `TrackWidget`: Đường đua + vạch kẻ
  - `CarWidget`: 3 xe (Positioned)
  - Progress bars: Thanh tiến trình bên phải
- Info Panel: Thông tin 3 xe (tên, hạng, tốc độ)

#### Tính toán vị trí xe:
```dart
final progress = _engine.getProgress(index);  // 0.0 - 1.0
final availableWidth = trackWidth - 40;
final carX = (availableWidth * progress).clamp(0.0, availableWidth - GameConstants.carWidth);
final carY = laneYPositions[index] - GameConstants.carHeight / 2;
```

---

### 4. File: `lib/screens/new_result_screen.dart`

**Mục đích**: Màn hình kết quả - hiển thị thắng/thua và cập nhật số tiền.

#### Method: `_calculateWinnings()`
```dart
double _calculateWinnings() {
  return betState.calculateWinnings(winner);  // Gọi method từ BetState
}
```

#### Method: `_getUpdatedBetState()`
```dart
BetState _getUpdatedBetState() {
  final winnings = _calculateWinnings();
  // Số tiền mới = Số tiền cũ - Số tiền cược + Số tiền thắng
  final newTotal = betState.totalMoney - betState.betAmount + winnings;
  return betState.copyWith(totalMoney: newTotal);
}
```

#### Method: `_buildActionButtons()`
```dart
Widget _buildActionButtons(BuildContext context, BetState updatedState) {
  if (updatedState.isBroke()) {
    // Nếu hết tiền: hiển thị thông báo + nút "Đăng Nhập Lại"
    return Column(
      children: [
        // Thông báo "Oops bạn đã thua rồi"
        // Nút "Đăng Nhập Lại" → quay về LoginScreen
      ],
    );
  }

  // Nếu còn tiền: hiển thị 2 nút
  return Row(
    children: [
      // Nút "Về Trang Chủ" → quay về BettingScreen với updatedState
      // Nút "Chơi Lại" → quay về BettingScreen với updatedState
    ],
  );
}
```

**Layout:**
- Bên trái: Thông báo thắng + kết quả cược
- Bên phải: Tổng tiền + thống kê + nút hành động

---

## 🧩 COMPONENTS - WIDGETS

### 1. File: `lib/components/car_widget.dart`

**Mục đích**: Widget hiển thị một xe.

```dart
class CarWidget extends StatelessWidget {
  final int carIndex;      // Index xe (0, 1, 2)
  final double progress;    // Tiến trình (0.0 - 1.0)
  final double x;           // Vị trí X
  final double y;           // Vị trí Y

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: x,
      top: y,
      child: Image.asset(
        CarConfig.getCarImagePath(carIndex),  // Lấy đường dẫn ảnh
        width: GameConstants.carWidth,
        height: GameConstants.carHeight,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Nếu ảnh không load được → hiển thị icon fallback
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

---

### 2. File: `lib/components/track_widget.dart`

**Mục đích**: Widget hiển thị đường đua.

```dart
class TrackWidget extends StatelessWidget {
  final double trackWidth;
  final double trackHeight;
  final List<double> laneYPositions;  // Vị trí Y của 3 làn

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background đường đua (gradient xám)
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(...),
            child: CustomPaint(
              painter: RoadLinesPainter(...),  // Vẽ vạch kẻ đường
            ),
          ),
        ),
        // Vạch xuất phát (màu xanh)
        Positioned(left: 0, ...),
        // Vạch đích (màu đỏ)
        Positioned(right: 0, ...),
      ],
    );
  }
}
```

#### Class: `RoadLinesPainter`
```dart
class RoadLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Vẽ vạch kẻ đường dạng dashed (nét đứt)
    const dashLength = 30.0;
    const dashSpace = 20.0;
    double currentX = 20;

    while (currentX < trackWidth - 20) {
      // Vẽ 2 vạch ngang (giữa làn 1-2 và làn 2-3)
      canvas.drawLine(Offset(currentX, laneY1), Offset(currentX + dashLength, laneY1), paint);
      canvas.drawLine(Offset(currentX, laneY2), Offset(currentX + dashLength, laneY2), paint);
      currentX += dashLength + dashSpace;
    }
  }
}
```

---

### 3. File: `lib/components/progress_bar_widget.dart`

**Mục đích**: Widget thanh tiến trình cho mỗi xe.

```dart
class ProgressBarWidget extends StatelessWidget {
  final int carIndex;
  final double progress;      // 0.0 - 1.0
  final double laneSpacing;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: GameConstants.carHeight,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,  // Background xám
        borderRadius: BorderRadius.circular(4),
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: 8,
          height: GameConstants.carHeight * progress,  // Chiều cao = progress
          decoration: BoxDecoration(
            color: CarConfig.getCarColor(carIndex),  // Màu theo xe
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
```

---

### 4. File: `lib/components/car_info_widget.dart`

**Mục đích**: Widget hiển thị thông tin xe (tên, hạng, tốc độ).

```dart
class CarInfoWidget extends StatelessWidget {
  final int carIndex;
  final int ranking;      // Hạng (1, 2, 3)
  final double speed;     // Tốc độ (pixels/second)

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(CarConfig.getCarName(carIndex)),  // Tên xe
        Text('$ranking'),                      // Hạng
        Text('${speed.toStringAsFixed(0)} px/s'), // Tốc độ
      ],
    );
  }
}
```

---

## 🔄 LUỒNG HOẠT ĐỘNG

### 1. Khởi động App
```
main() 
  → MyApp 
    → LoginScreen
```

### 2. Đăng nhập
```
User nhập username/password
  → _handleLogin()
    → Tạo BetState với 100,000 VNĐ
      → Navigator.pushReplacement()
        → NewBettingScreen
```

### 3. Đặt cược
```
User chọn xe (1, 2, hoặc 3)
  → _selectCar(carIndex)
    → setState() → UI update

User nhập số tiền
  → _updateBetAmount(value)
    → Validate và clamp
      → setState() → UI update

User bấm "BẮT ĐẦU ĐUA"
  → _startRace()
    → Validate (xe đã chọn? số tiền hợp lệ?)
      → Tạo BetState với selectedCar và betAmount
        → Navigator.push()
          → NewRaceScreen
```

### 4. Đua xe
```
NewRaceScreen initState()
  → Tạo GameEngine
    → GameEngine tạo GameState.initial()

User bấm "BẮT ĐẦU"
  → _startRace()
    → setState(_isRacing = true)
      → Timer.periodic(16ms)
        → Mỗi 16ms:
          → _engine.update(0.016)
            → Tính tốc độ mới (base + noise + rubber band)
            → Cập nhật vị trí (position += speed * deltaTime)
            → Kiểm tra kết thúc
          → setState() → UI rebuild
            → Vị trí xe được cập nhật

Khi có xe về đích
  → _onRaceFinished()
    → Navigator.pushReplacement()
      → NewResultScreen
```

### 5. Kết quả
```
NewResultScreen build()
  → _calculateWinnings()
    → betState.calculateWinnings(winner)
      → Nếu thắng: return betAmount * 2.0
      → Nếu thua: return 0.0

  → _getUpdatedBetState()
    → newTotal = totalMoney - betAmount + winnings
      → return BetState với totalMoney mới

  → _buildActionButtons()
    → Nếu hết tiền (isBroke()):
      → Hiển thị thông báo
      → Nút "Đăng Nhập Lại" → LoginScreen
    → Nếu còn tiền:
      → Nút "Về Trang Chủ" → NewBettingScreen(updatedState)
      → Nút "Chơi Lại" → NewBettingScreen(updatedState)
```

---

## 🎮 CÁC TÍNH NĂNG CHÍNH

### 1. Game Loop (60fps)
- Chạy mỗi 16ms
- Update tốc độ và vị trí xe
- Rebuild UI để hiển thị animation

### 2. Physics System
- **Base Speed**: Tốc độ cơ bản (80-120 px/s)
- **Noise**: Biến thiên mượt dùng sin wave
- **Rubber Banding**: Xe phía sau đuổi kịp, xe dẫn đầu chậm lại

### 3. Betting System
- Chọn xe (1, 2, 3)
- Nhập số tiền cược
- Validate: không vượt quá số tiền có
- Tính thắng/thua: thắng = x2, thua = mất hết

### 4. Money Management
- Bắt đầu: 100,000 VNĐ
- Thắng: +betAmount * 2
- Thua: -betAmount
- Hết tiền → quay về login

---

## 📝 LƯU Ý QUAN TRỌNG

1. **Immutable Pattern**: Tất cả state đều dùng `copyWith()` để tạo bản copy mới
2. **Game Loop**: Phải cancel timer trong `dispose()` để tránh memory leak
3. **Mounted Check**: Luôn check `mounted` trước khi `setState()` trong async
4. **Orientation**: Tất cả màn hình đều set landscape, reset về all khi dispose
5. **Navigation**: Dùng `pushReplacement` để không thể quay lại màn hình trước

---

## 🔍 DEBUGGING TIPS

1. **Xe không hiển thị**: Kiểm tra assets trong `pubspec.yaml`
2. **Game loop không chạy**: Kiểm tra `_isRacing` và timer
3. **Tốc độ không đúng**: Kiểm tra `GameConstants` và logic trong `update()`
4. **Navigation lỗi**: Kiểm tra context và mounted state

---

**Chúc bạn code vui vẻ! 🚀**
