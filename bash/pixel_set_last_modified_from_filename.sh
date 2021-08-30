#!/bin/bash

# This tool sets the Last Modified timestamp of Pixel phone videos based on the file's name
# It requires a filename in the form of PXL_yyyymmdd_hhmmssuuu.mp4

# How to use:
# - Get a list of filenames, put them, line-by-line, into a file e.g. 'corrupted_files.txt'
# - Set the photos_folder to where your media files are

corrupted_files="./corrupted_files.txt"
photos_folder=""

while IFS= read -r filename
do
  path=$(find ${photos_folder} -name "$filename" -not -path "*/@eaDir/*")
  filename=$(basename "${path}")

  datetime=$(echo ${filename} | tr -d -c 0-9)
  datetime=${datetime::-4}
  datetime=${datetime::-2}.${datetime: -2}

  touch -t ${datetime} "${path}"
done < "$corrupted_files"
