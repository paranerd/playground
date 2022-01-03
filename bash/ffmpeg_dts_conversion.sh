#!/bin/bash

# This converts the input video stream to 8-bit HEVC and/or the audio stream(s) to DTS for better compatibility.

PATH_TO_FILE=""
FILENAME=""
MODE=4

if [[ $MODE -eq 0 ]]
then
  # 2 audio streams, preserve original
  ffmpeg -i "${PATH_TO_FILE}/${FILENAME}" -strict -2 -map 0:v -map 0:a:0 -map 0:a:1 -map 0:a -c copy -map 0:s -c copy -c:a:0 dts -c:a:1 dts -metadata:s:a:0 title="DTS 5.1" -metadata:s:a:1 title="DTS 5.1" "${PATH_TO_FILE}/converted-${FILENAME}"
elif [[ $MODE -eq 3 ]]
then
  # 2 audio streams, keep DTS only
  ffmpeg -i "${PATH_TO_FILE}/${FILENAME}" -strict -2 -map 0:v -map 0:a:0 -map 0:a:1 -c copy -map 0:s -c copy -c:a:0 dts -c:a:1 dts -metadata:s:a:0 title="DTS 5.1" -metadata:s:a:1 title="DTS 5.1" "${PATH_TO_FILE}/converted-${FILENAME}"
elif [[ $MODE -eq 1 ]]
then
  # 1 audio stream, preserve original
  ffmpeg -i "${PATH_TO_FILE}/${FILENAME}" -strict -2 -map 0:v -map 0:a:0 -map 0:a -c copy -map 0:s -c copy -c:a:0 dts -metadata:s:a:0 title="DTS 5.1" "${PATH_TO_FILE}/converted-${FILENAME}"
elif [[ $MODE -eq 2 ]]
then
  # 2 audio streams, preserve original, convert second audio stream only
  ffmpeg -i "${PATH_TO_FILE}/${FILENAME}" -strict -2 -map 0:v -map 0:a:1 -map 0:a -c copy -map 0:s -c copy -c:a:0 dts -metadata:s:a:0 title="DTS 5.1" "${PATH_TO_FILE}/converted-${FILENAME}"
elif [[ $MODE -eq 4 ]]
then
  # 2 audio streams, keep DTS only, also convert to 8-bit HEVC
  ffmpeg -i "${PATH_TO_FILE}/${FILENAME}" -strict -2 -map 0:v -map 0:a:0 -map 0:a:1 -c copy -map 0:s -c copy -c:a:0 dts -c:a:1 dts -c:v libx265 -vf format=yuv420p -metadata:s:a:0 title="DTS 5.1" -metadata:s:a:1 title="DTS 5.1" "${PATH_TO_FILE}/converted-${FILENAME}"
fi
