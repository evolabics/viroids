# Libraries - Packages
import pandas as pd
import subprocess
import argparse

# Argument parser
parser = argparse.ArgumentParser(description='Process Pospiviroidae table file')
parser.add_argument('file_path', type=str, help='Path to the needed file')
# Parse the argument
args = parser.parse_args()

# Function to read the infromation table from NCBI as a matrix
def infromation_matrix(file):
    # Initialize an empty list to store the valid data rows
    data_rows = []

    # Open the file in read mode
    with open(args.file_path, 'r') as f:
        # Skip the first line
        next(f)
        
        # Assign column names
        column_names = f.readline().strip().split('\t')
        
        # Read each line from the file
        for line in f:
            # Split the line using the tab character as the delimiter
            data = line.strip().split('\t')

            # Check if the line has only one element or not
            # Avoid the lines that contain just the taxonomy family
            if len(data) > 1:
                # Append the data to the list
                data_rows.append(data)

    # Create a DataFrame using the collected data_rows
    df = pd.DataFrame(data_rows, columns= column_names)
    return df

matrix = infromation_matrix(args.file_path)

# Function to download the genomes of viroids as fasta files from NCBI
def download_and_rename_fasta(organism, accession_number):
    # Use Entrez Direct (efetch) to download the genome
    efetch_command = f"efetch -db nucleotide -id {accession_number} -format fasta"
    try:
        # Execute the efetch command using subprocess
        result = subprocess.run(efetch_command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

        # Check if the efetch command was successful
        if result.returncode == 0:
            # Save the FASTA content to a file
            filename = f"{organism}.fa"
            with open(filename, 'w') as fasta_file:
                fasta_file.write(result.stdout)
            print(f"Downloaded and saved {filename}")
        else:
            print(f"Failed to download {organism}'s FASTA file.")
            print("Error:", result.stderr)
    except Exception as e:
        print(f"An error occurred while downloading {organism}'s FASTA file.")
        print("Error:", e)

for organism, accession_number in zip(matrix['"Genome"'], matrix['"Accession"']):
    organism = organism.strip('"')  # Remove surrounding quotes from organism name
    accession_number = accession_number.strip('"')  # Remove surrounding quotes from accession number
    download_and_rename_fasta(organism, accession_number)

# run as: python3 download_NCBI_genomes.py Pospiviroidae_table.tbl