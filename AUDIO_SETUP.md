# 🎵 HƯỚNG DẪN THÊM NHẠC NỀN CHO GAME

## Vấn đề hiện tại
File `race_screen.mp4` là file **video**, không phải audio. Package `audioplayers` không phát được file video, chỉ phát được audio.

## Giải pháp: Extract Audio từ Video

### Cách 1: Dùng Online Converter (Đơn giản nhất)

1. **Truy cập website:**
   - https://convertio.co/vn/mp4-mp3/
   - https://www.freeconvert.com/mp4-to-mp3
   - https://cloudconvert.com/mp4-to-mp3

2. **Upload file:**
   - Chọn file `assets/audio/race_screen.mp4`
   - Chọn format output: **MP3** hoặc **WAV**

3. **Download file audio:**
   - Tải file `.mp3` hoặc `.wav` về
   - Đặt vào thư mục `assets/audio/`
   - Đổi tên thành: `race_screen.mp3` (hoặc giữ nguyên nếu tên khác)

4. **Cập nhật code:**
   - Đổi đường dẫn trong code từ `.mp4` → `.mp3`

### Cách 2: Dùng VLC Media Player (Miễn phí)

1. **Mở VLC Media Player**
2. **Menu:** Media → Convert/Save
3. **Add file:** Chọn `race_screen.mp4`
4. **Convert/Save**
5. **Profile:** Chọn "Audio - MP3" hoặc "Audio - WAV"
6. **Destination:** Chọn `assets/audio/race_screen.mp3`
7. **Start**

### Cách 3: Dùng FFmpeg (Command line)

```bash
# Cài FFmpeg (nếu chưa có)
# Windows: choco install ffmpeg
# Mac: brew install ffmpeg

# Extract audio từ video
ffmpeg -i assets/audio/race_screen.mp4 -vn -acodec libmp3lame assets/audio/race_screen.mp3
```

## Sau khi có file audio

### Bước 1: Đặt file vào thư mục
```
assets/
  audio/
    race_screen.mp3  ← File audio mới
```

### Bước 2: Cập nhật pubspec.yaml
```yaml
assets:
  - assets/audio/race_screen.mp3
```

### Bước 3: Cập nhật code
Đổi từ `.mp4` → `.mp3` trong `new_race_screen.dart`

### Bước 4: Rebuild app
```bash
flutter clean
flutter pub get
flutter run
```

## Lưu ý

- **File size:** File audio nên < 10MB để load nhanh
- **Format:** `.mp3` hoặc `.wav` được hỗ trợ tốt nhất
- **Quality:** 128-192 kbps là đủ cho nhạc nền
