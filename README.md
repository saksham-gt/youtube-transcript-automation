# YouTube Transcription Automation

Automatically download and transcribe YouTube videos using `yt-dlp` and OpenAI Whisper.  
All transcripts are stored in the `youtube-transcripts` folder inside the repo.

---

## Features

- Audio-only download (no video)
- Automatic virtual environment (`.venv`) creation, activation, and deactivation
- Whisper transcription models: tiny, base, small, medium, large
- Outputs: TXT (default), optional SRT and VTT
- Optional language specification for faster transcription
- Automatic cleanup of temporary audio files
- Beginner-friendly: run the script directly, no manual setup
- Clean progress output without verbose terminal spam

---

## Requirements

- macOS or Linux
- Python 3.8+
- Git (optional, if cloning the repo)

All dependencies (`yt-dlp`, `openai-whisper`, `imageio-ffmpeg`) are installed automatically in the `.venv`.

---

## Usage

1. Clone the repo (if not already):

```bash
git clone git@github.com:saksham-gt/youtube-transcript-automation.git
cd youtube-transcript-automation
```

2. Run the transcription script:

```bash
./transcript-gen.sh [options] <youtube_url>
```

### Options

| Flag | Description |
|------|-------------|
| `-m <model>` | Whisper model: tiny, base, small, medium, large (default: base) |
| `--srt` | Generate SRT subtitles |
| `--vtt` | Generate VTT subtitles |
| `--lang <code>` | Language code (e.g., en, es, fr) |

### Examples

* Basic transcription:

```bash
./transcript-gen.sh https://www.youtube.com/watch?v=VIDEO_ID
```

* With SRT and VTT:

```bash
./transcript-gen.sh --srt --vtt https://www.youtube.com/watch?v=VIDEO_ID
```

* Specify language and model:

```bash
./transcript-gen.sh --lang en -m medium https://www.youtube.com/watch?v=VIDEO_ID
```

---

## Output

Transcripts are saved in `youtube-transcripts`:

```
youtube-transcripts/
├── My Video Title.txt
├── My Video Title.srt   (if --srt used)
└── My Video Title.vtt   (if --vtt used)
```

Temporary audio files are automatically deleted after transcription.

---

## Virtual Environment

* `.venv` is created automatically if missing.
* Automatically activated at script start and deactivated after completion.
* To reuse in a new session:

```bash
source .venv/bin/activate
```

---

## Notes

* First run may take a few minutes to create `.venv` and install dependencies.
* Whisper models vary in speed and accuracy:
  * `tiny` → fastest, least accurate
  * `base` → balanced (default)
  * `small`, `medium`, `large` → progressively slower but more accurate
* Audio-only downloads are faster and smaller than full video downloads.
* The script automatically handles YouTube's JavaScript challenges using remote components.

---

## Troubleshooting

### YouTube Download Issues

If you encounter warnings about "n challenge solving failed" or "remote components", the script should handle this automatically with `--remote-components ejs:github`. If issues persist:

1. **Install Node.js** (recommended for better JS challenge handling):
   ```bash
   # macOS
   brew install node
   
   # Or download from https://nodejs.org/
   ```

2. **Update yt-dlp** to the latest version:
   ```bash
   source .venv/bin/activate
   pip install --upgrade yt-dlp
   deactivate
   ```

3. **Try alternative format selection** if some formats are missing (the script handles this automatically).

### SSL Certificate Errors

If you see SSL certificate errors, you may need to update your Python certificates:
```bash
/Applications/Python\ 3.*/Install\ Certificates.command
```

---

## One-liner Install + Run

No setup required, everything is handled automatically:

```bash
git clone <repo_url> && cd <repo_folder> && ./transcript-gen.sh https://www.youtube.com/watch?v=VIDEO_ID
```

---

Happy transcribing! 🎉
