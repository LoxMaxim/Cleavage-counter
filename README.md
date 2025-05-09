# Cleavage-counter
A Shiny app for aligning protein sequences to a reference, counting frequency of matches, and exporting results.

# Protein Sequence Aligner and Frequency Counter

This Shiny application allows users to:

- Upload Excel files containing protein sequences and sample data.
- Align each sequence to a given reference.
- Count frequencies of exact matches across sequence positions.
- Export results as Excel or FASTA files.

## Installation

Install required R packages:

```R
install.packages(c("shiny", "readxl", "writexl", "shinyjs"))
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
BiocManager::install("Biostrings")
BiocManager::install("seqinr")

## Input Format
The Excel file should contain a Sequence column and multiple SampleX columns with ion count.

For example:

| Sequence | Sample1 | Sample2 |
|----------|---------|---------|
| MKT...   | 5       | 2       |
| AEV...   | 1       | 0       |

