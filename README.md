# genotype-pipeline
<p align="left">
Pipeline for genotype data processing: quality control, imputation preparation, post-imputation filtering, and polygenic risk score analysis
</p>

---
## Table of contents

- [0 - Overview](#over) - Overview of the project's purpose and goals
- [1 - Respository structure](#rep_stru) - Instructions on how to begin with this project
- [2 - Prerequisites](#prere) - Required software and installation steps 
- [3 - Workflow](#workflow) - Detailed guide to each stage of the project
- [4 - Authors](#authors) - Detailed guide to each stage of the project 


## 0 - Overview <a name = "over"></a>
---

This repository contains scripts and resources for a complete pipeline to process genotyping data in PLINK format. 
It includes quality control (QC) steps, imputation preparation, post-imputation filtering, and polygenic risk score (PRS) calculation.

### 🔹  1_QC/ – Genotype Quality Control
This module conducts a comprehensive quality control of raw genotype data using PLINK and R, ensuring the reliability of the dataset prior to downstream analyses. 
The process begins with the removal of SNPs that exhibit high missing call rates (commonly above 5%), as well as samples with excessive levels of missing genotype data.

Next, samples are assessed for abnormal heterozygosity, which can be indicative of contamination or low DNA quality. Those that fall outside the expected range are excluded. 
The module also verifies sex concordance by comparing genetically inferred sex with reported sex, removing any mismatched individuals to maintain consistency.

To avoid confounding due to non-independence between samples, related individuals or duplicates are identified using identity-by-descent (IBD) metrics, with one individual from each related pair removed. 
SNPs that significantly deviate from Hardy-Weinberg Equilibrium (typically evaluated in control samples) are also filtered out, as such deviations may signal genotyping errors or population structure artifacts.

Population stratification is assessed through Principal Component Analysis (PCA), using Ancestry Informative Markers (AIMS) to identify major axes of genetic variation. 
Based on their principal component scores, individuals are then classified into broad ancestry groups, including European, Latino, Asian, and African, allowing for downstream analyses to appropriately account for population structure.



### 🔹  2_data_preparation/ – Imputation Preparation
This stage focuses on preparing high-quality, filtered genotype data for imputation by ensuring compatibility with reference panels and imputation servers. 
The process begins with a final round of SNP filtering to eliminate variants with strand ambiguities, mismatches in allele annotation, or other inconsistencies that could affect imputation accuracy.

If the reference genome build used in the dataset differs from that required by the imputation server (for example, GRCh37 vs. GRCh38), a coordinate conversion step (LiftOver) is applied to align the dataset accordingly.

Next, allele matching is performed using tools such as the Wellcome Trust’s Wrayner check utilities. 
These tools compare the dataset against the imputation reference panel and generate a correction script (Run-plink.sh) to standardize SNP orientation, alleles, and positions.

Following correction, the dataset is converted from PLINK binary format to Variant Call Format (VCF), which is the standard input format required by most imputation servers. 
Finally, the VCF files are sorted, compressed using bgzip, and indexed with tabix to generate .vcf.gz and accompanying index files, ready for upload to the imputation platform.



### 🔹  3_imputation/ – Imputation via TOPMed
This step involves performing genotype imputation using the TOPMed Imputation Server, a widely used platform that infers missing genotypes based on a large, diverse reference panel. 
The process enhances genomic coverage and is essential for downstream analyses like GWAS or polygenic risk scoring.

The first task is to prepare the dataset according to the imputation server’s formatting requirements, ensuring all input files (e.g., .vcf.gz, .tbi) are properly structured, compressed, and indexed.

Once the data is validated, it is uploaded to the TOPMed Imputation Server. 
The imputation job is configured through the server’s web interface, where parameters such as population reference panel and phasing options are specified.

After imputation is completed, the resulting files—typically VCFs containing imputed genotype probabilities—are downloaded. 
These files are then decompressed and organized for downstream analysis, such as quality assessment or variant filtering.



### 🔹  4_analysis/ – Post-Imputation Analysis
Final steps include downstream analyses on imputed genotype data.

- a) Sample/SNP extraction: Select specific subsets of individuals or variants.
- b) PCA for batch effects: Run PCA to detect technical artifacts or batch effects.
- c) PRS calculation: Compute Polygenic Risk Scores (PRS) using public or custom scoring files.


## ⚙️ 1 - Respository structure <a name = "rep_stru"></a>
---

The table below summarizes the main files and directories in this repository, along with a brief description of their contents.
|File  |Description            |
|:----:|-----------------------|
|[scripts/](scripts/)|Folder containing all scripts used to build the workflow.|
|[docs/](docs/)|This folder includes PDF and PNG files that help illustrate the workflow, along with example tables and resulting plots.|



## 🛠️ 2 - Prerequisites <a name = "prere"></a>
---
To successfully run the pipeline, ensure the following software and input formats are available:
This workflow is currently designed to run in high-performance computing (HPC) environments using `SLURM` job scheduling with `Bash scripts` (#!/bin/bash) and `RStudio`.

The table below provides a summary of the main tools used in this repository, along with a brief description of their purpose and functionality.
| Tool       | Description                                                                                   |
|:----------:|-----------------------------------------------------------------------------------------------|
| R    | Statistical analysis and plotting. |
| PLINK 1.9     | Genotype QC, filtering, and manipulation. |
| VCFtools    | VCF file manipulation.      |
| bcftools   | VCF file compression/indexing.     |
| python     | General scripting.                                   |
| perl    | Required for LiftOver scripts.     |
| LiftOver   | Coordinate conversion between builds.      |


## 🚀 3 - Workflow <a name = "workflow"></a>
---

This repository is organized into modular steps that reflect a standard genotype data processing pipeline, from raw data to downstream analyses like PRS. Below is the step-by-step workflow:


![Workflow Overview](docs/Workflow.png)


### 🔹 1_QC – Initial Quality Control.

[scripts/1_QC](scripts/1_QC)

- `1_QC`:

            a. Missingness filtering: Remove SNPs with high missing call rates (e.g., >5%) and samples with excessive missing genotypes.
            b. Heterozygosity check: Identify and remove samples with abnormal heterozygosity rates, which may indicate contamination or poor DNA quality.
            c. Sex concordance: Check genetic vs. reported sex and exclude mismatched samples.
            d. Relatedness check: Detect duplicates or related individuals using identity-by-descent (IBD, pi_hat > 0.8) and remove one from each pair.
            e. Hardy-Weinberg Equilibrium filtering: Filter SNPs significantly deviating from HWE (typically in controls).
            f. Population stratification: Perform PCA using Ancestry Informative Markers (AIMS) to detect population structure.
            g. Ancestry classification: Classify individuals into ancestry groups (European, Latino, Asian, African) based on principal components


### 🔹 2_data_preparation/ - Data Preparation for Imputation

[scripts/2_data_preparation](scripts/2_data_preparation)

- `2_data_preparation`:

            a. SNP filtering and allele checks: Remove SNPs with strand issues or inconsistent annotations.
            b. LiftOver (optional): Convert coordinates to match imputation server genome build if necessary (e.g., GRCh37 to GRCh38).
            c. Wrayner checks: Run allele matching tools (e.g., Wellcome Trust tools) to generate a correction script (Run-plink.sh) aligning SNPs with the reference panel.
            d. VCF conversion: Convert final PLINK files to .vcf format.
            e. Compression and indexing: Create sorted and bgzipped .vcf.gz files with index for server upload.

### 🔹 3_imputation/ – Imputation via TOPMed

[scripts/3_imputation](scripts/3_imputation)

- `3_imputation`:

            a. Prepare files for upload: Ensure data follows imputation server specifications.
            b. Upload & launch imputation: Submit data to the imputation server (e.g., TOPMed).
            c. Download results: Retrieve imputed data once available.
            d. Decompression: Unzip and organize imputed VCF files for analysis.


### 🔹  4_analysis/ – Post-Imputation Analysis

[scripts/4_analysis](scripts/4_analysis)

- `4_analysis`:

            - a) Sample/SNP extraction: Select specific subsets of individuals or variants.
            - b) PCA for batch effects: Run PCA to detect technical artifacts or batch effects.
            - c) PRS calculation: Compute Polygenic Risk Scores (PRS) using public or custom scoring files.



## ✍️ 4 - Authors <a name = "authors"></a>
---

This pipeline was primarily developed and implemented by:

Núria Moragas, PhD – [@nmoragas](https://github.com/nmoragas)
Designed, developed, and documented the full metagenomics pipeline, including data preprocessing, taxonomic classification, functional profiling, and downstream analyses.

