# voice-notes — 錄音轉逐字稿＋自動整理文件（全本機離線）

把一段錄音丟給 Claude Code，自動轉成逐字稿、再整理成一份繁體文件（會議記錄／重點筆記／條列）。
**轉錄與整理全在你自己電腦上完成，錄音不會外送。** 底層用 Whisper（`faster-whisper`）離線模型。

---

## 安裝（最省事：把下面這段貼給你的 Claude Code）

```
請幫我安裝這個工具：
把 https://github.com/linjomaqa-pixel/voice-notes clone 到我家目錄，
然後執行裡面的安裝腳本（Windows 跑 install.ps1、Mac 跑 install.command），裝完提醒我重開 session。
```

你的 Claude Code 會自動做這些事（透明，供你安心）：
1. `git clone` 這個 repo 到你電腦。
2. 在 skill 資料夾建一個 Python venv，`pip install faster-whisper av`（本機轉錄引擎）。
3. 把 `skill/voice-notes` 連結進 `~/.claude/skills/`（用 junction／symlink，之後 `git pull` 就能更新）。
4. 請你重開 Claude Code session。

> 手動安裝也行：`git clone` 後進資料夾，Windows 執行 `install.ps1`、Mac 執行 `bash install.command`。

---

## 使用

重開 session 後，把錄音檔丟給 Claude Code，講一句你要什麼，例如：

- 「把這段錄音轉逐字稿，整理成**會議記錄** `C:\path\會議.m4a`」
- 「這堂課的錄音幫我整理成**重點筆記**」
- 「我口述的備忘轉成**條列整理**」

產出會是一份 `<錄音檔名>-整理.md`，放在**錄音檔同一個資料夾**，並自動開啟。

支援音訊/影片格式：wav / mp3 / m4a / mp4 / flac / aac / ogg…

---

## 隱私與紅線

- **全程本機離線**：錄音、逐字稿、整理文件都只在你自己電腦上，不上傳任何服務。
- 模型是「一次性從網路下載進來」（large-v3 約 3GB），之後離線可用；音檔從不外送。
- 🔴 **這個 repo 是公開的，絕不要把錄音檔、逐字稿、公司網址、帳密或任何機密 commit 進來**
  （`.gitignore` 已先擋常見音檔與 `-整理` 輸出檔，但請仍自行留意）。

---

## 需求

- Python 3.9+、git（沒有 Python：Windows `winget install -e --id Python.Python.3.12`、Mac `brew install python`）。
- 首次轉錄某模型會下載一次（large-v3 約 3GB）。
- 純 CPU 機器跑 large-v3 偏慢；要快可改小模型：對 Claude Code 說「用 medium 模型轉」即可。

---

## 想要圖形介面？

本工具走命令列、適合交給 Claude Code 全自動跑。若你偏好「視窗點一點」的圖形介面，可另外裝
[Buzz](https://github.com/chidiwilliams/buzz)（同樣是 Whisper、本機離線），自己轉出逐字稿後，
再把 `.txt` 丟給這個 skill 整理即可。詳見 `docs/Buzz安裝說明.md`。
