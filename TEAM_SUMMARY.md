# 📋 TÓM TẮT PHÂN CÔNG - 6 THÀNH VIÊN

## 🎯 PHÂN CHIA CÔNG VIỆC

### 👤 **Tâm: Authentication & Setup**
**Files:**
- `lib/main.dart`
- `lib/screens/login_screen.dart`
- `lib/utils/orientation_helper.dart`

**Nhiệm vụ:**
- Setup app (MaterialApp, theme)
- Tạo màn hình đăng nhập (fake login)
- Quản lý hướng màn hình (landscape)
- Navigation sang betting screen

**Kiến thức:** Flutter basics, Form validation, Navigation

---

### 👤 **Duy: Betting System**
**Files:**
- `lib/models/bet_state.dart`
- `lib/screens/new_betting_screen.dart`

**Nhiệm vụ:**
- Tạo model BetState (quản lý tiền, xe chọn, số tiền cược)
- Tạo màn hình đặt cược
- Validation (chọn xe, số tiền hợp lệ)
- Audio playback (bet_screen.mp3)
- Navigation sang race screen

**Kiến thức:** Dart classes, State management, Input validation, Audio

---

### 👤 **Đan: Game State Model**
**Files:**
- `lib/models/game_state.dart`

**Nhiệm vụ:**
- Tạo model GameState (vị trí, tốc độ, trạng thái đua)
- Quản lý state của 3 xe
- Tính toán leader, rankings
- Kiểm tra finish condition

**Kiến thức:** Dart classes, Data modeling, Immutability

---

### 👤 **Hiếu: Game Engine**
**Files:**
- `lib/services/game_engine.dart`

**Nhiệm vụ:**
- Tạo GameEngine (physics, rubber banding)
- Tính toán tốc độ (base + noise + rubber band)
- Cập nhật vị trí xe
- Cheat code logic
- Game loop logic

**Kiến thức:** Game loop, Physics simulation, Math (sin, cos, clamp)

---

### 👤 **Khoa: Race Screen**
**Files:**
- `lib/screens/new_race_screen.dart`

**Nhiệm vụ:**
- Tạo màn hình đua xe (UI + Animation)
- Game loop 60fps với Timer
- Tích hợp GameEngine và GameState
- Audio playback (race_screen.mp3)
- Keyboard input (cheat code)
- Navigation sang result screen

**Kiến thức:** Game loop, Timer, Animation, Audio, Keyboard input

---

### 👤 **Hậu: Result Screen + UI Components**
**Files:**
- `lib/screens/new_result_screen.dart`
- `lib/constants/game_constants.dart`
- `lib/constants/car_config.dart`
- `lib/components/car_widget.dart`
- `lib/components/track_widget.dart`
- `lib/components/progress_bar_widget.dart`
- `lib/components/car_info_widget.dart`
- `pubspec.yaml` (assets)

**Nhiệm vụ:**
- Tạo màn hình kết quả
- Tính tiền thắng/thua
- Quản lý tiền (cộng/trừ)
- Xử lý hết tiền (game over)
- Audio playback (win_screen.mp3 / lose_creen.mp3)
- Tạo tất cả constants
- Tạo cấu hình xe
- Tạo các widget tái sử dụng
- Setup assets (ảnh xe, audio)
- Navigation (về trang chủ / chơi lại / đăng nhập lại)

**Kiến thức:** Conditional rendering, Navigation, Money calculation, Flutter widgets, CustomPaint, Asset management

---

## 🔄 THỨ TỰ LÀM VIỆC

1. **Người 6** → Làm trước (Components & Constants)
2. **Người 1** → Login & Setup (cần Constants từ người 6)
3. **Người 2** → Betting (cần Constants từ người 6)
4. **Người 3** → GameState Model (độc lập)
5. **Người 4** → GameEngine (cần GameState từ người 3)
6. **Người 5** → Race Screen (cần GameEngine từ người 4, Components từ người 6)
7. **Người 6** → Result Screen (cần tất cả các phần trước)

---

## 📦 DEPENDENCIES

```
Người 6 (Components & Constants)
    ↓
Người 1 (Login) ──┐
Người 2 (Betting) ──┐
Người 3 (GameState) ──┐
    ↓                  ↓
Người 4 (GameEngine) ──┘
    ↓
Người 5 (Race Screen) ──┐
    ↓                    ↓
Người 6 (Result Screen) ─┘
```

---

## ✅ CHECKLIST TỔNG QUAN

- [ ] Người 6: Components & Constants hoàn thành
- [ ] Người 1: Login screen hoàn thành
- [ ] Người 2: Betting screen hoàn thành
- [ ] Người 3: GameState model hoàn thành
- [ ] Người 4: GameEngine hoàn thành
- [ ] Người 5: Race screen hoàn thành
- [ ] Người 6: Result screen hoàn thành
- [ ] Test end-to-end: Login → Bet → Race → Result → Loop

---

## 📚 FILE CHI TIẾT

Xem file **`TEAM_ASSIGNMENT.md`** để biết:
- Code examples chi tiết
- Giải thích từng method
- Checklist cụ thể cho từng người
- Kiến thức cần thiết

---

**Chúc team làm việc tốt! 🚀**
