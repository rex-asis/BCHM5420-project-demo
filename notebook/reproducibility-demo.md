# Reproducibility Testing Workshop
2025-06-11 <br>
BCHM 5420 <br>
Rex Asis <br>

## Introduction
This demo will outline the steps taken to take a list of desired contigs from a multi-FASTA file, then split these contigs into single FASTA files, e.g.,


```python
# Input is a multi fasta file
cat multi.fasta
>contig1 
AGTCAGCATTTACTA
>contig2 
GTCTGTAGCTAGTCAGTCAGT
>contig3 
TAGCTAGATCAG
>contig4 
CGATAGCTAGATGCTAGTAGCTAGCTA

# Select a few FASTA headers or IDs, which get placed in a new fasta file
cat list.fasta
>contig2 
GTCTGTAGCTAGTCAGTCAGT
>contig3 
TAGCTAGATCAG

# Split the new file into individual fasta files
cat list.contig2.fasta
>contig2 
GTCTGTAGCTAGTCAGTCAGT

cat list.contig3.fasta
>contig3 
TAGCTAGATCAG
```

## Inputs Required
1. FASTA (.fasta) file containing the multiple contigs
2. Text (.txt) file containing list of contigs that needs to be extracted from the fasta file
3. (optional, but convenient) custom bash script (.sh) that combines two commands together


## Steps
All commands will be ran in bash.


```python
#!/bin/bash
```

1. Clone GitHub repository, which I made for the purposes of this demo: https://github.com/rex-asis/BCHM5420-project-demo# <br>
 (My project repository may take a bit longer to clone, so opted to make a smaller one instead)


```python
git clone git@github.com:rex-asis/BCHM5420-project-demo.git
```

The home directory is called **BCHM-5420-project-demo**. It will contain two directories: _inputs_ and _scripts_. Each directories also contain the files that we will need to run for this demo.

2. Setup conda environment. I use mamba, but conda (likely micromamba as well) will work. No docker though :(


```python
#!/bin/bash
# Install 'seqkit' tool from anaconda: https://anaconda.org/bioconda/seqkit
mamba create -n seqkit
mamba activate seqkit
mamba install -c bioconda seqkit
```

3. If we change directories to _inputs_, we will see 3 .fasta files. We need to combine this into 1 file using a command:


```python
cd /your/path/info/BCHM5420-project-demo/inputs
cat *.fasta > ptr-genomes.fasta
```

**Side Note**: I would have provided the combined file to you but it's too big for git!

4. Let's move back to the project's home directory and create a new set of directories. This is where the output of the main command will be deposited:


```python
cd /your/path/info/BCHM5420-project-demo/
mkdir -p outputs/seqkit # makes a directory called 'outputs', then another directory within 'outputs', called seqkit 
```

5. Checking that we're still in the project's home directory, we can now run our main command:


```python
bash scripts/seqkit-extract-v2025.06.08.sh region3
```

## Expected Outcome
Running this command will provide a few different outputs:
1. region3.fasta: Multi FASTA file containing only the list of FASTA headers selected


```python
cd /your/path/info/BCHM5420-project-demo/outputs/seqkit
ls
```

![seqkit-output1.png](reproducibility-demo_files/seqkit-output1.png)

2. region3.fasta.split: This is a directory, which contains single FASTA files that came from splitting the multi FASTA file from above

![seqkit-output2.png](reproducibility-demo_files/seqkit-output2.png)

## Breaking Down The Command
The command we ran relies on a custom bash script, **seqkit-extract-v2025.06.08.sh**, which looks like this:


```python
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
```

Let's breakdown these commands.

1. **(Optional - can skip to '2.' for the sake of time, but feel free to look through later)** The first thing you will notice is the following symbol:


```python
$1
```

In Bash script, this is called a variable. It let's us generalize the code so that we can apply it beyond a single file. <br>
Let's take a simpler command for example:


```python
#!/bin/bash
# Open file and only read first 2 lines
cat multi.fasta | head -2

# output
>contig1 
AGTCAGCATTTACTA
```

But what if I want to run this command for a different fasta file? I'm lazy, so I don't want to type the same command over and over. <br>
Another way is to write this command in a bash script (called 'open-file.sh'), and generalize the file name to $1: 


```python
#!/bin/bash
# open-file.sh
cat $1.fasta | head -2
```

Now we can run the script as follows:


```python
#!/bin/bash
# Open file called multi.fasta
bash open-file.sh multi

# output
>contig1 
AGTCAGCATTTACTA
```

This command is telling us to run a bash script, and to replace every $1 with the string 'multi'. <br>
What's nice is that we can use the same script to open another file, e.g., list.fasta, by replacing 'multi' with 'list'


```python
#!/bin/bash
# Open file called list.fasta
bash open-file.sh list

# output
>contig2 
GTCTGTAGCTAGTCAGTCAGT
```

2. Now looking closer at each command in the script:


```python
# Command 1
seqkit grep -f inputs/seqkit/$1.txt inputs/ptr-genomes.fasta -o outputs/seqkit/$1.fasta

seqkit grep # Seach sequences based on ID/name/sequence motifs. We're using it for ID (aka FASTA header) 
    -f inputs/seqkit/$1.txt inputs/ptr-genomes.fasta # Search for the corresponding FASTA headers listed in the .txt file ($1 is a filler) within the fasta file
    -o outputs/seqkit/$1.fasta # Place the output in the folder
```

The goal of this first command is to search for a provided list sequences within a FASTA file, given the sequence ID. Then, it combines all of those sequences into one file.


```python
# Command 2
seqkit split outputs/seqkit/$1.fasta -i


seqkit split outputs/seqkit/$1.fasta # Split the given fasta file in a particular way
    -i # Split into invididual sequences
```

This second command will take the multi FASTA output from above, and split it into individual sequences.

Since this is a bash script, it must to written as follows in order to run:


```python
#!/bin/bash
bash open-file.sh <name of file without .txt extension>

# e.g., if we want to open a file called region3.txt
bash seqkit-extract-v2025.06.08.sh region3
```

Rinse and repeat. You can imagine that this script can be used to locate a new set of contigs. The names of these contigs should be added to a new text file, such as 'newcontigs'. With this new file, we just have to replace $1 (aka 'region3' in the demo above) with 'newcontigs'
