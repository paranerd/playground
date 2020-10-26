#!/bin/bash

# This takes a source directory of files, looks for the filenames
# in a destination directory and moves the files there if found

source_dir=<path_to_source>
dest_dir=<path_to_destination>

for source in ${source_dir}/*; do
        dest=$(find ${dest_dir} -name $(basename ${source}))

        if [ ! -z "$dest" ]; then
                mv "${source}" "${dest}"
        fi
done