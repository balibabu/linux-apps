#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
# Treat unset variables as an error when substituting.
# Pipestatus to be the exit status of the last command in a pipeline that exited with a non-zero status.
set -euo pipefail

# Check if a video file argument is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <video_file>"
    exit 1
fi

video_file="$1"

# Check if the video file exists and is a regular file
if ! [ -f "$video_file" ]; then
    echo "Error: Video file '$video_file' not found or is not a regular file."
    exit 1
fi

# Check if the video file is readable
if ! [ -r "$video_file" ]; then
    echo "Error: Video file '$video_file' not readable."
    exit 1
fi

# Get the directory and base name of the video file
video_dir=$(dirname "$video_file")
base_name=$(basename "$video_file")

# Get the filename without the extension
# This handles names like "video.mp4" -> "video"
# And "video.tar.gz" -> "video.tar" (which is usually desired for subtitles)
filename_no_ext="${base_name%.*}"

# Define common subtitle extensions
subtitle_exts=("srt" "vtt" "ass" "sub" "ssa")
found_subtitle_path=""

# Search for a subtitle file
for ext in "${subtitle_exts[@]}"; do
    potential_sub_file="$video_dir/$filename_no_ext.$ext"
    if [ -f "$potential_sub_file" ] && [ -r "$potential_sub_file" ]; then
        found_subtitle_path="$potential_sub_file"
        break # Use the first subtitle file found
    fi
done

if [ -n "$found_subtitle_path" ]; then
    echo "Found subtitle: $found_subtitle_path"
    
    # Escape the subtitle path for ffplay's -vf subtitles filter.
    # The filter's filename argument requires ' and \ to be escaped with a backslash.
    # 1. Replace all backslashes (\) with double backslashes (\\)
    escaped_subtitle_path="${found_subtitle_path//\\/\\\\}"
    # 2. Replace all single quotes (') with backslash and single quote (\')
    escaped_subtitle_path="${escaped_subtitle_path//\'/\'}"

    echo "Attempting to play with subtitles..."
    # Try to play with subtitles. The `if` statement checks the exit code.
    if ffplay "$video_file" -vf "subtitles=$escaped_subtitle_path"; then
        # Playback was successful or the user closed ffplay normally (exit code 0)
        echo "Playback finished."
    else
        # ffplay exited with an error (non-zero exit code)
        exit_status=$? # Capture the exit status
        echo "Warning: ffplay failed (exit code $exit_status) when trying to play with subtitles."
        echo "This could be due to an issue with the subtitle file, ffplay configuration, or other errors."
        echo "Attempting to play without subtitles as a fallback..."
        ffplay "$video_file"
    fi
else
    echo "No subtitle file found with a matching name and common extension (.${subtitle_exts[*]})."
    echo "Attempting to play without subtitles..."
    ffplay "$video_file"
fi

