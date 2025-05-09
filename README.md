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
```

## Input Format
The Excel file should contain a Sequence column and multiple SampleX columns with ion count.

For example:

| Sequence | Sample1 | Sample2 |
|----------|---------|---------|
| MKT...   | 5       | 2       |
| AEV...   | 1       | 0       |


## Used packages

<details> <summary><strong>📦 shiny</strong></summary>
Chang W, Cheng J, Allaire JJ, Xie Y, McPherson J (2023). shiny: Web Application Framework for R. R package version 1.8.0.
URL: https://CRAN.R-project.org/package=shiny

</details> <details> <summary><strong>📦 readxl</strong></summary>
Wickham H, Bryan J (2023). readxl: Read Excel Files. R package version 1.4.3.
URL: https://CRAN.R-project.org/package=readxl

</details> <details> <summary><strong>📦 writexl</strong></summary>
Ooms J (2024). writexl: Export Data Frames to Excel 'xlsx' Format. R package version 1.4.0.
URL: https://CRAN.R-project.org/package=writexl

</details> <details> <summary><strong>📦 seqinr</strong></summary>
Charif D, Lobry JR (2007). SeqinR 1.0-2: A Contributed Package to the R Project for Statistical Computing Devoted to Biological Sequences Retrieval and Analysis. In Bastolla U, Porto M, Roman HE, Vendruscolo M (eds.), Structural Approaches to Sequence Evolution: Molecules, Networks, Populations, Biological and Medical Physics, Biomedical Engineering, Springer-Verlag, pp. 207-232.
URL: https://CRAN.R-project.org/package=seqinr

</details> <details> <summary><strong>📦 Biostrings</strong></summary>
Pagès H, Aboyoun P, Gentleman R, DebRoy S (2024). Biostrings: Efficient manipulation of biological strings. R package version 2.72.0.
Bioconductor.
URL: https://bioconductor.org/packages/Biostrings

</details> <details> <summary><strong>📦 shinyjs</strong></summary>
Attali D (2021). shinyjs: Easily Improve the User Experience of Your Shiny Apps in Seconds. R package version 2.1.0.
URL: https://CRAN.R-project.org/package=shinyjs

</details>
