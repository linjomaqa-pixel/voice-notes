#!/usr/bin/env python3
"""錄音轉逐字稿 — faster-whisper 本機離線引擎。

全程在本機跑，音檔不外送；首次使用會從網路下載模型（large-v3 約 3GB）到本機快取。
stdout 只印出「逐字稿檔路徑」供上層 skill 取用；所有進度訊息走 stderr。
"""
import argparse
import sys
from pathlib import Path


def pick_device():
    """有 NVIDIA GPU 就用 cuda/float16，否則 cpu/int8。不依賴 torch。"""
    try:
        from ctranslate2 import get_cuda_device_count
        if get_cuda_device_count() > 0:
            return "cuda", "float16"
    except Exception:
        pass
    return "cpu", "int8"


def main():
    ap = argparse.ArgumentParser(description="錄音轉逐字稿（faster-whisper，本機離線）")
    ap.add_argument("audio", help="錄音檔路徑（wav/mp3/m4a/mp4/flac…）")
    ap.add_argument("--model", default="large-v3",
                    help="Whisper 模型，預設 large-v3（中文最準）；要快可用 medium / base / tiny")
    ap.add_argument("--language", default="zh",
                    help="語言，預設 zh（中文夾英文也可）；傳空字串則自動偵測")
    ap.add_argument("--out", default=None,
                    help="逐字稿輸出路徑，預設放錄音檔旁 <名稱>.txt")
    args = ap.parse_args()

    audio = Path(args.audio).expanduser()
    if not audio.is_file():
        print(f"[錯誤] 找不到錄音檔：{audio}", file=sys.stderr)
        return 2

    out = Path(args.out).expanduser() if args.out else audio.with_suffix(".txt")

    try:
        from faster_whisper import WhisperModel
    except ImportError:
        print("[錯誤] 尚未安裝 faster-whisper，請先執行 install 腳本安裝環境。", file=sys.stderr)
        return 3

    device, compute_type = pick_device()
    print(f"[資訊] 裝置={device} 模型={args.model} 語言={args.language or 'auto'}", file=sys.stderr)
    print("[資訊] 首次使用該模型會自動下載（large-v3 約 3GB），請耐心等候…", file=sys.stderr)

    try:
        model = WhisperModel(args.model, device=device, compute_type=compute_type)
    except Exception as e:
        # GPU 環境不齊時退回 CPU 再試一次
        if device == "cuda":
            print(f"[警告] GPU 初始化失敗（{e}），改用 CPU。", file=sys.stderr)
            model = WhisperModel(args.model, device="cpu", compute_type="int8")
        else:
            raise

    segments, info = model.transcribe(
        str(audio),
        language=(args.language or None),
        vad_filter=True,      # 過濾靜音，降低幻聽
        beam_size=5,
    )
    print(f"[資訊] 偵測語言={info.language}（信心 {info.language_probability:.2f}）"
          f" 音檔長度={info.duration:.1f}s", file=sys.stderr)

    lines = []
    for seg in segments:
        text = seg.text.strip()
        if text:
            lines.append(text)
            print(f"  [{seg.start:7.1f}s] {text}", file=sys.stderr)

    if not lines:
        print("[警告] 沒有轉出任何文字（可能是空白或純音樂）。", file=sys.stderr)

    out.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"[完成] 逐字稿已輸出：{out}", file=sys.stderr)
    print(str(out))  # stdout：逐字稿路徑，給上層 skill 取用
    return 0


if __name__ == "__main__":
    sys.exit(main())
