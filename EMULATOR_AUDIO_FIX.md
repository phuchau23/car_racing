# Hướng Dẫn Sửa Lỗi Không Có Tiếng Trên Android Emulator

## Vấn Đề
Log hiển thị audio đang chạy (`Audio position: 0s`, `5s`) nhưng không có tiếng. Đây là vấn đề phổ biến với Android Emulator.

## Giải Pháp

### 1. Kiểm Tra Cài Đặt Emulator Audio

**Cách 1: Qua Extended Controls**
1. Trong Android Emulator, click vào nút **"..."** (3 chấm) ở thanh công cụ bên phải
2. Chọn **"Settings"** hoặc **"Extended Controls"**
3. Vào tab **"Audio"**
4. Đảm bảo:
   - ✅ **"Host audio backend"** được bật
   - ✅ **"Play audio"** được bật
   - ✅ Volume slider được kéo lên cao

**Cách 2: Qua Command Line**
```bash
# Kiểm tra emulator đang chạy
adb devices

# Bật audio cho emulator (nếu có thể)
emulator -avd <AVD_NAME> -audio <audio_backend>
```

### 2. Kiểm Tra Volume Windows/Mac

- **Windows**: 
  - Kiểm tra Volume Mixer (click chuột phải vào icon volume)
  - Đảm bảo volume của Android Emulator không bị tắt
  
- **Mac**:
  - Kiểm tra System Preferences > Sound
  - Đảm bảo volume không bị mute

### 3. Test Trên Thiết Bị Thật (Khuyến Nghị)

**Cách tốt nhất là test trên điện thoại thật:**

```bash
# Kết nối điện thoại qua USB
adb devices

# Chạy app trên thiết bị thật
flutter run
```

### 4. Kiểm Tra File Audio

Đảm bảo file `assets/audio/race_screen.mp3`:
- ✅ Tồn tại và có kích thước > 0
- ✅ Định dạng đúng (.mp3, không phải .mp4)
- ✅ Có thể phát được bằng media player trên máy tính

### 5. Thử Package Khác (Nếu Vẫn Không Được)

Nếu `audioplayers` không hoạt động trên emulator, có thể thử:

```yaml
# pubspec.yaml
dependencies:
  just_audio: ^0.9.36  # Thay thế audioplayers
```

## Kết Luận

**Nếu log hiển thị `PlayerState.playing` nhưng không có tiếng:**
- ✅ Code đang hoạt động đúng
- ⚠️ Vấn đề là do Android Emulator không phát âm thanh
- ✅ **Giải pháp tốt nhất: Test trên thiết bị thật**

## Debug Commands

```bash
# Kiểm tra audio service trên emulator
adb shell dumpsys audio

# Kiểm tra logcat cho audio errors
adb logcat | grep -i audio

# Kiểm tra file audio có được copy vào app không
adb shell ls -la /data/app/<package_name>/assets/audio/
```
