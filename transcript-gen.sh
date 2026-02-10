#!/bin/bash

# YouTube Transcription Automation Script
# Automatically downloads audio and transcribes using Whisper

set -e  # Exit on error

# Default configuration
WHISPER_MODEL="base"
OUTPUT_FORMATS="txt"
LANGUAGE=""
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="$SCRIPT_DIR/.venv"
TRANSCRIPTS_DIR="$SCRIPT_DIR/youtube-transcripts"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Help message
show_help() {
    cat << EOF
Usage: $0 [options] <youtube_url>

Options:
    -m <model>      Whisper model: tiny, base, small, medium, large (default: base)
    --srt           Generate SRT subtitles
    --vtt           Generate VTT subtitles
    --lang <code>   Language code (e.g., en, es, fr)
    -h, --help      Show this help message

Examples:
    $0 https://www.youtube.com/watch?v=VIDEO_ID
    $0 --srt --vtt https://www.youtube.com/watch?v=VIDEO_ID
    $0 --lang en -m medium https://www.youtube.com/watch?v=VIDEO_ID
EOF
    exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -m)
            WHISPER_MODEL="$2"
            shift 2
            ;;
        --srt)
            OUTPUT_FORMATS="txt,srt"
            shift
            ;;
        --vtt)
            OUTPUT_FORMATS="txt,vtt"
            shift
            ;;
        --lang)
            LANGUAGE="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            ;;
        *)
            YOUTUBE_URL="$1"
            shift
            ;;
    esac
done

# Check if URL provided
if [ -z "$YOUTUBE_URL" ]; then
    echo -e "${RED}Error: No YouTube URL provided${NC}"
    show_help
fi

# Combine formats if both srt and vtt requested
if [[ "$OUTPUT_FORMATS" == *"srt"* && "$OUTPUT_FORMATS" == *"vtt"* ]]; then
    OUTPUT_FORMATS="txt,srt,vtt"
fi

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}YouTube Transcription Automation${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check for Node.js (recommended for YouTube challenges)
if ! command -v node &> /dev/null; then
    echo -e "${YELLOW}⚠ Warning: Node.js not found${NC}"
    echo -e "${YELLOW}Installing Node.js is recommended for better YouTube compatibility${NC}"
    echo -e "${YELLOW}Install with: brew install node (macOS)${NC}"
    echo ""
fi

# Step 1: Create virtual environment if it doesn't exist
if [ ! -d "$VENV_DIR" ]; then
    echo -e "${GREEN}[1/6] Creating virtual environment...${NC}"
    python3 -m venv "$VENV_DIR"
    echo "✓ Virtual environment created"
    echo ""
    
    echo -e "${GREEN}[2/6] Installing dependencies...${NC}"
    source "$VENV_DIR/bin/activate"
    echo "  → Upgrading pip..."
    pip install --upgrade pip --quiet
    echo "  → Installing yt-dlp, whisper, and ffmpeg..."
    pip install yt-dlp openai-whisper imageio-ffmpeg --quiet
    echo "✓ Dependencies installed"
    echo ""
else
    echo -e "${GREEN}[1/6] Virtual environment exists${NC}"
    echo "✓ Using existing .venv"
    echo ""
    
    echo -e "${GREEN}[2/6] Activating virtual environment...${NC}"
    source "$VENV_DIR/bin/activate"
    echo "✓ Virtual environment activated"
    echo ""
fi

# Step 2: Create transcripts directory
echo -e "${GREEN}[3/6] Setting up output directory...${NC}"
mkdir -p "$TRANSCRIPTS_DIR"
echo "✓ Transcripts directory: $TRANSCRIPTS_DIR"
echo ""

# Step 3: Get video title
echo -e "${GREEN}[4/6] Fetching video information...${NC}"
VIDEO_TITLE=$(yt-dlp --print "%(title)s" --no-download --no-warnings "$YOUTUBE_URL" 2>/dev/null || echo "video")
# Sanitize filename
VIDEO_TITLE=$(echo "$VIDEO_TITLE" | sed 's/[^a-zA-Z0-9 _-]//g' | sed 's/  */ /g' | xargs)
echo "✓ Video: $VIDEO_TITLE"
echo ""

# Step 4: Download audio
echo -e "${GREEN}[5/6] Downloading audio...${NC}"
TEMP_AUDIO="/tmp/${VIDEO_TITLE}_$$.mp3"
yt-dlp \
    --extract-audio \
    --audio-format mp3 \
    --audio-quality 0 \
    --output "$TEMP_AUDIO" \
    --progress \
    --no-warnings \
    "$YOUTUBE_URL"
echo "✓ Audio downloaded"
echo ""

# Step 5: Transcribe with Whisper
echo -e "${GREEN}[6/6] Transcribing audio (this may take a few minutes)...${NC}"
echo "Model: $WHISPER_MODEL"
echo "Output formats: $OUTPUT_FORMATS"
if [ -n "$LANGUAGE" ]; then
    echo "Language: $LANGUAGE"
fi
echo ""
echo -e "${YELLOW}Processing... (progress will be shown below)${NC}"

WHISPER_ARGS=(
    "$TEMP_AUDIO"
    --model "$WHISPER_MODEL"
    --output_dir "$TRANSCRIPTS_DIR"
    --output_format "$OUTPUT_FORMATS"
    --verbose False
)

if [ -n "$LANGUAGE" ]; then
    WHISPER_ARGS+=(--language "$LANGUAGE")
fi

whisper "${WHISPER_ARGS[@]}" 2>&1 | grep -E "(Detecting language|Loading|100%|^$)" || true
echo ""
echo "✓ Transcription complete"
echo ""

# Step 6: Cleanup
echo -e "${YELLOW}Cleaning up temporary files...${NC}"
rm -f "$TEMP_AUDIO"
echo "✓ Temporary audio deleted"
echo ""

# Deactivate virtual environment
deactivate

echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✓ All Done!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "Transcript(s) saved to:"
echo "  $TRANSCRIPTS_DIR/${VIDEO_TITLE}.txt"
if [[ "$OUTPUT_FORMATS" == *"srt"* ]]; then
    echo "  $TRANSCRIPTS_DIR/${VIDEO_TITLE}.srt"
fi
if [[ "$OUTPUT_FORMATS" == *"vtt"* ]]; then
    echo "  $TRANSCRIPTS_DIR/${VIDEO_TITLE}.vtt"
fi
echo ""
echo "View with:"
echo "  cat \"$TRANSCRIPTS_DIR/${VIDEO_TITLE}.txt\""
echo ""
echo "Or open the folder:"
echo "  open \"$TRANSCRIPTS_DIR\""
echo ""
