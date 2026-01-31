# Tóm Tắt Implementation - Racing Game

## Kiến Trúc Code

### 1. Models
- **`GameState`**: Quản lý state của race (positions, speeds, time, winner, etc.)
- **`BetState`**: Quản lý state của betting (coins, selected car, bet amount)

### 2. Engine
- **`GameEngine`**: Game loop và physics logic
  - Update positions dựa trên speeds
  - Tính toán noise speed (smooth variation)
  - Tính toán rubber banding
  - Track lead changes
  - Check finish condition

### 3. Screens
- **`NewBettingScreen`**: Màn hình đặt cược
- **`NewRaceScreen`**: Màn hình đua (landscape, 3 lanes)
- **`NewResultScreen`**: Màn hình kết quả và tính thưởng

### 4. Utils
- **`GameConstants`**: Tất cả thông số có thể tinh chỉnh
- **`OrientationHelper`**: Quản lý orientation

## Game Loop

Game loop chạy ở **60fps** (16ms mỗi frame):

```dart
Timer.periodic(Duration(milliseconds: 16), (timer) {
  _engine.update(16 / 1000.0); // deltaTime in seconds
  setState(() {}); // Update UI
});
```

## Công Thức Tốc Độ

Mỗi xe có tốc độ được tính:

```
speed[i] = baseSpeed[i] + noiseSpeed[i] + rubberBanding[i]
```

### 1. Base Speed
- Random trong khoảng `baseSpeedMin` đến `baseSpeedMax`
- Mỗi xe có base speed khác nhau

### 2. Noise Speed
- Sử dụng sine wave: `amplitude * sin(time * frequency + phase)`
- Tạo biến thiên mượt mà, không giật

### 3. Rubber Banding
- **Xe dẫn đầu**: Giảm tốc độ nhẹ khi dẫn xa
- **Xe sau**: Tăng tốc độ nhẹ khi bị tụt lại
- Đảm bảo các xe luôn "sát nút"

## UI Features

### Race Screen
- 3 lanes (trên-giữa-dưới) cố định
- Xe chạy từ trái sang phải
- Real-time ranking badges (1st, 2nd, 3rd)
- Progress bars bên phải
- Speed display
- Lead change tracking

### Betting Screen
- Chọn 1 trong 3 xe
- Nhập số coin cược
- Validation: không được vượt quá số coin hiện có

### Result Screen
- Hiển thị winner
- Tính thưởng (2x nếu thắng)
- Cập nhật coin
- Thống kê race (time, lead changes, seed)

## Cách Chạy

1. App tự động mở `NewBettingScreen`
2. Chọn xe và đặt cược
3. Nhấn "BẮT ĐẦU ĐUA"
4. Xem race với 3 lanes
5. Xem kết quả và nhận thưởng

## Tinh Chỉnh

Xem file `docs/TUNING_GUIDE.md` để biết cách tinh chỉnh:
- Tốc độ race
- Số lượng lead changes
- Độ "căng" của gameplay
- Thời gian race

## Performance

- Game loop: 60fps
- Update mượt mà với deltaTime
- Không dùng asset, chỉ dùng Container/CustomPaint
- Tối ưu cho mobile
