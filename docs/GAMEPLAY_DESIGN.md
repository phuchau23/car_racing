# Gameplay Design - Racing Game

## 1. Thiết kế Gameplay

### Công thức Tốc độ

Mỗi xe có tốc độ được tính như sau:

```
speed[i] = baseSpeed + noiseSpeed[i] + rubberBanding[i]
```

**1. Base Speed (Tốc độ cơ bản)**
- Mỗi xe có baseSpeed khác nhau: `baseSpeed[i] = 80 + random(0, 40)` pixels/second
- Đảm bảo race time ~25-40 giây với finishLine = 2000 pixels

**2. Noise Speed (Biến thiên ngẫu nhiên mượt)**
- Sử dụng Perlin noise hoặc smooth random walk
- `noiseSpeed[i] = amplitude * sin(time * frequency + phase[i])`
- amplitude: 15-25 pixels/second
- frequency: 0.1-0.3 Hz (thay đổi mỗi 3-10 giây)
- Tạo cảm giác "có lúc nhanh, có lúc chậm" tự nhiên

**3. Rubber Banding (Hiệu ứng đàn hồi)**
- Xe dẫn đầu: `rubberBanding[leader] = -rubberStrength * (distanceAhead / maxDistance)`
- Xe sau: `rubberBanding[behind] = +rubberStrength * (distanceBehind / maxDistance)`
- rubberStrength: 10-20 pixels/second
- maxDistance: 200-300 pixels
- Đảm bảo các xe luôn "sát nút" nhau

### Công thức Vị trí

```
position[i] += speed[i] * deltaTime
laneY[i] = topLaneY + (i * laneSpacing)  // 3 lane cố định
```

### Lead Changes (Vượt mặt)

- Theo dõi vị trí X của mỗi xe
- Khi `position[i] > position[j]` và trước đó `position[i] <= position[j]` → lead change
- Mục tiêu: 6-12 lần lead changes trong 1 race
- Điều chỉnh bằng cách:
  - Tăng noise amplitude → nhiều lead changes hơn
  - Tăng rubber banding → nhiều lead changes hơn
  - Giảm base speed spread → nhiều lead changes hơn

## 2. Thông số Có thể Tinh chỉnh

### baseSpeed (80-120 pixels/second)
- **Tăng**: Race nhanh hơn, ít thời gian quan sát
- **Giảm**: Race chậm hơn, dễ theo dõi hơn

### noiseAmplitude (15-25 pixels/second)
- **Tăng**: Nhiều biến động tốc độ, nhiều lead changes
- **Giảm**: Ổn định hơn, ít lead changes

### rubberBandStrength (10-20 pixels/second)
- **Tăng**: Các xe "dính" nhau hơn, nhiều kịch tính
- **Giảm**: Tự nhiên hơn, có thể có khoảng cách lớn

### finishDistance (2000 pixels)
- **Tăng**: Race lâu hơn
- **Giảm**: Race nhanh hơn

### frequency (0.1-0.3 Hz)
- **Tăng**: Thay đổi tốc độ nhanh hơn
- **Giảm**: Thay đổi tốc độ chậm hơn, mượt hơn

## 3. Cơ chế Cược

- Người chơi chọn 1 trong 3 xe
- Nhập số coin cược (1-100)
- Odds cố định: 2x (nếu thắng nhận 2x số cược)
- Sau race: tính thưởng và cập nhật coin

## 4. Kiến trúc Code

```
lib/
├── models/
│   ├── game_state.dart      # GameState (positions, speeds, time, etc.)
│   └── bet_state.dart      # BetState (selected car, amount)
├── engine/
│   └── game_engine.dart    # GameEngine (game loop, update logic)
├── screens/
│   ├── betting_screen.dart # Màn hình cược
│   ├── race_screen.dart    # Màn hình đua (landscape)
│   └── result_screen.dart  # Màn hình kết quả
└── utils/
    └── constants.dart      # Constants (baseSpeed, rubberStrength, etc.)
```
