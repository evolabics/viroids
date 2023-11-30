#!/bin/bash

# Check if a directory that contain the .out files is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

directory="$1"

# Check if the directory that contain the .out files exist
if [ ! -d "$directory" ]; then
    echo "Directory not found: $directory"
    exit 1
fi

# Loop through all .out files in the specified directory
for outfile in "$directory"/*.out; do
    if [ -f "$outfile" ]; then

        # Extract the base name without the extension
        base_name="${outfile%.*}"

        echo "Computing coordinates for $base_name to create a mountain plot"

        # Run b2mt.pl with input from the .out file and output to .dat file
        perl /home/anna/viroids/work_in_progress/rnafold/perl_scripts/b2mt.pl < "$outfile" > "${base_name}.dat"
    fi
done