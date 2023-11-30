#!/bin/bash

### Check if three arguments are provided: fasta directory, output directory, new directory's name
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 /path/to/your/fasta/files /path/to/output/directory output_dir_name"
    exit 1
fi

fasta_dir="$1"
output_dir="$2"
output_dir_name="$3"

### Check if the specified input directory exists
if [ ! -d "$fasta_dir" ]; then
    echo "The directory with the fasta files does not exist: $fasta_dir"
    exit 1
fi

### Check if the specified output directory exists
if [ ! -d "$output_dir" ]; then
    echo "The output directory does not exist: $output_dir"
    exit 1
fi

### Create the output directory with the specified name
mkdir -p "$output_dir/$output_dir_name"

# Loop through all FASTA files in the directory
for fasta_file in "$fasta_dir"/*.fa; do
    if [ -e "$fasta_file" ]; then
        
        # Generate the output file names
        output_file="$output_dir/$output_dir_name/${fasta_file##*/}.out"
        ps_file1="$output_dir/$output_dir_name/${fasta_file##*/}.ps"
        ps_file2="$output_dir/$output_dir_name/${fasta_file##*/}_ss.ps"

        ### Run RNAfold with the specified options
        echo "Running RNAfold for $fasta_file."
        RNAfold -p -d2 --MEA --circ < "$fasta_file" > "$output_file"
        # -p: Calculate the partition function and base pairing probability matrix
        # -d2: check is ignored, dangling energies will be added for the bases adjacent to a helix on both sides in any case (default)
        # --MEA: Compute MEA (maximum expected accuracy) structure (default=1)
        # --circ: Assume a circular RNA molecule
        
        ### Move all the PostScript files to the new directory
        mv ./*.ps "$output_dir/$output_dir_name/"
        
        # Process the PostScript files for this FASTA file
        for ss_file in "$output_dir/$output_dir_name"/*_ss.ps; do
            if [ -e "$ss_file" ]; then

                # Extract the base filename (without extension)
                base_filename=$(basename "$ss_file" _ss.ps)
                
                # Generate the output filenames with the desired _rss.ps suffix
                output_rss_file="$output_dir/$output_dir_name/${base_filename}_rss.ps"
                output_rss_file_p_flag="$output_dir/$output_dir_name/${base_filename}_p_rss.ps"

                
                # Run the Perl script for each pair of ss and dp files
                echo "Draw and markup RNA secondary structures for $fasta_file."
                perl /home/anna/viroids/work_in_progress/rnafold/perl_scripts/relplot.pl "$ss_file" "${ss_file%_ss.ps}_dp.ps" > "$output_rss_file"
                
                echo "Draw and markup RNA secondary structures for $fasta_file by coloring base pairs by their pair probability "
                perl /home/anna/viroids/work_in_progress/rnafold/perl_scripts/relplot.pl -p "$ss_file" "${ss_file%_ss.ps}_dp.ps" > "$output_rss_file_p_flag"
                # −p: the script colors base pairs by their pair probability, unpaired bases use the probability of being unpaired.
            
            fi
        done
    fi
done

echo "All output files moved to $output_dir$output_dir_name directory."