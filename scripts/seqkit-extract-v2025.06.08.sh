### 2025-06-08 Rex Asis
### seqkit-extract-v2025.06.08.sh
### This script will extract a list of FASTA headers from a multi-FASTA file, then generate individual single FASTA files

## Inputs required
# 1. Multi FASTA file
# 2. A text file containing the list of single FASTA sequences that want to be extracted.

# cd ~/BCHM5420/BCHM5420_class_project
# bash scripts/seqkit-extract.sh $1
seqkit grep -f inputs/seqkit/$1.txt inputs/ptr-genomes.fasta -o outputs/seqkit/$1.fasta
seqkit split outputs/seqkit/$1.fasta -i
