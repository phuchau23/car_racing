# Hướng Dẫn Tinh Chỉnh Gameplay

## Cách Tinh Chỉnh Thông Số

Tất cả thông số có thể chỉnh trong file `lib/utils/game_constants.dart`:

### 1. **baseSpeedMin / baseSpeedMax** (80-120 pixels/second)
```dart
static const double baseSpeedMin = 80.0;
static const double baseSpeedMax = 120.0;
```

**Tăng (ví dụ: 100-140):**
- Race nhanh hơn
- Ít thời gian quan sát
- Phù hợp cho game "nhanh tay nhanh mắt"

**Giảm (ví dụ: 60-100):**
- Race chậm hơn, dễ theo dõi
- Nhiều thời gian để quan sát chiến thuật
- Phù hợp cho game "chiến thuật"

### 2. **noiseAmplitude** (15-25 pixels/second)
```dart
static const double noiseAmplitude = 20.0;
```

**Tăng (ví dụ: 30):**
- Nhiều biến động tốc độ
- Nhiều lead changes (vượt mặt)
- Gameplay "hỗn loạn" hơn, kịch tính hơn

**Giảm (ví dụ: 10):**
- Ổn định hơn, ít lead changes
- Dễ dự đoán kết quả hơn
- Phù hợp cho game "cân bằng"

### 3. **rubberBandStrength** (10-20 pixels/second)
```dart
static const double rubberBandStrength = 15.0;
```

**Tăng (ví dụ: 25):**
- Các xe "dính" nhau hơn
- Nhiều kịch tính, ít khoảng cách lớn
- Luôn có cảm giác "sát nút"

**Giảm (ví dụ: 5):**
- Tự nhiên hơn, có thể có khoảng cách lớn
- Ít "giả tạo" hơn
- Phù hợp cho game "thực tế"

### 4. **noiseFrequency** (0.1-0.3 Hz)
```dart
static const double noiseFrequency = 0.2; // Hz
```

**Tăng (ví dụ: 0.4):**
- Thay đổi tốc độ nhanh hơn (mỗi 2.5 giây)
- Nhiều lead changes
- Gameplay "nhanh" hơn

**Giảm (ví dụ: 0.1):**
- Thay đổi tốc độ chậm hơn (mỗi 10 giây)
- Mượt mà hơn, ít lead changes
- Gameplay "ổn định" hơn

### 5. **finishDistance** (2000 pixels)
```dart
static const double finishDistance = 2000.0;
```

**Tăng (ví dụ: 3000):**
- Race lâu hơn (~40-60 giây)
- Nhiều thời gian để quan sát
- Nhiều lead changes hơn

**Giảm (ví dụ: 1500):**
- Race nhanh hơn (~20-30 giây)
- Gameplay nhanh, không kéo dài
- Ít lead changes hơn

### 6. **maxDistanceForRubberBand** (250 pixels)
```dart
static const double maxDistanceForRubberBand = 250.0;
```

**Tăng (ví dụ: 400):**
- Rubber banding hoạt động ở khoảng cách xa hơn
- Các xe luôn "kéo" nhau lại gần
- Ít khi có khoảng cách lớn

**Giảm (ví dụ: 150):**
- Rubber banding chỉ hoạt động khi rất gần
- Có thể có khoảng cách lớn
- Tự nhiên hơn

## Công Thức Tổng Quát

### Để Game "Căng" Hơn (Nhiều Kịch Tính):
```dart
baseSpeedMin = 90.0;
baseSpeedMax = 110.0;  // Ít spread → gần nhau hơn
noiseAmplitude = 25.0;  // Tăng
rubberBandStrength = 20.0;  // Tăng
noiseFrequency = 0.3;  // Tăng
```

### Để Game "Dễ" Hơn (Ổn Định):
```dart
baseSpeedMin = 70.0;
baseSpeedMax = 130.0;  // Nhiều spread → có thể có khoảng cách
noiseAmplitude = 15.0;  // Giảm
rubberBandStrength = 10.0;  // Giảm
noiseFrequency = 0.15;  // Giảm
```

### Để Có Nhiều Lead Changes (6-12 lần):
```dart
baseSpeedMin = 85.0;
baseSpeedMax = 115.0;  // Spread vừa phải
noiseAmplitude = 22.0;  // Cao
rubberBandStrength = 18.0;  // Cao
noiseFrequency = 0.25;  // Cao
```

## Kiểm Tra Lead Changes

Sau mỗi race, kiểm tra trong Result Screen:
- `Lead changes: X` - số lần vượt mặt
- Mục tiêu: 6-12 lần là lý tưởng

Nếu quá ít (< 4):
- Tăng `noiseAmplitude`
- Tăng `rubberBandStrength`
- Giảm spread giữa `baseSpeedMin` và `baseSpeedMax`

Nếu quá nhiều (> 15):
- Giảm `noiseAmplitude`
- Giảm `rubberBandStrength`
- Tăng spread giữa `baseSpeedMin` và `baseSpeedMax`
