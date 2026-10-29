# （可選）用 Buzz 圖形介面轉逐字稿

這個工具平常不需要 Buzz —— Claude Code 會用內建的 `faster-whisper` 引擎自動轉。
但如果你**偏好視窗點一點**的圖形介面自己轉，可以裝 Buzz，轉出 `.txt` 後再丟給 skill 整理。

Buzz 是開源、本機離線的語音轉文字桌面 App（同樣底層是 Whisper）。

## 安裝（Windows）
1. 到 <https://github.com/chidiwilliams/buzz/releases> 下載最新版的 Windows 檔：
   一個 `Buzz-*.exe` **和同一版的兩個 `.bin` 檔**（三個放同一資料夾，少了 `.bin` 會失敗）。
2. 執行 `.exe` 安裝。

## 設定（中文夾英文）
- 引擎選 **Faster Whisper**，模型選 **large-v3**（中文最準；首次自動下載約 3GB）。
- Task 選 `transcribe`，語言設**中文**，匯出格式選 **TXT**。
- 嫌慢可改 `medium` 模型。

## 轉完之後
把 Buzz 匯出的 `.txt` 丟給 Claude Code 說「把這份逐字稿整理成會議記錄」，
skill 會接手做簡轉繁、補標點、套範本。

> macOS 同樣到 Releases 頁下載對應的 Mac 版本安裝。
