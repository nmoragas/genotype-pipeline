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

This repository contains scripts and resources for a complete pipeline to process genotyping data in PLINK format. 
It includes quality control (QC) steps, imputation preparation, post-imputation filtering, and polygenic risk score (PRS) calculation.

### 1_QC/ – Genotype Quality Control
This module performs an extensive quality control of raw genotype data using PLINK and R. 
The steps ensure data integrity and remove problematic samples and variants before downstream analysis.

- a) Missingness filtering: Remove SNPs with high missing call rates (e.g., >5%) and samples with excessive missing genotypes.
- b) Heterozygosity check: Identify and remove samples with abnormal heterozygosity rates, which may indicate contamination or poor DNA quality.
- c) Sex concordance: Check genetic vs. reported sex and exclude mismatched samples.
- d) Relatedness check: Detect duplicates or related individuals using identity-by-descent (IBD, pi_hat > 0.8) and remove one from each pair.
- e) Hardy-Weinberg Equilibrium filtering: Filter SNPs significantly deviating from HWE (typically in controls).
- f) Population stratification: Perform PCA using Ancestry Informative Markers (AIMS) to detect population structure.
- g) Ancestry classification: Classify individuals into ancestry groups (European, Latino, Asian, African) based on principal components

### 2_data_preparation/ – Imputation Preparation
This stage prepares the filtered genotype data for imputation.

- a) SNP filtering and allele checks: Remove SNPs with strand issues or inconsistent annotations.
- b) LiftOver (optional): Convert coordinates to match imputation server genome build if necessary (e.g., GRCh37 to GRCh38).
- c) Wrayner checks: Run allele matching tools (e.g., Wellcome Trust tools) to generate a correction script (Run-plink.sh) aligning SNPs with the reference panel.
- d) VCF conversion: Convert final PLINK files to .vcf format.
- e) Compression and indexing: Create sorted and bgzipped .vcf.gz files with index for server upload.

### 3_imputation/ – Imputation via TOPMed
This step covers remote genotype imputation using the TOPMed Imputation Server.

- a) Prepare files for upload: Ensure data follows imputation server specifications.
- b) Upload & launch imputation: Submit data to the imputation server (e.g., TOPMed).
- c) Download results: Retrieve imputed data once available.
- d) Decompression: Unzip and organize imputed VCF files for analysis.

### 4_analysis/ – Post-Imputation Analysis
Final steps include downstream analyses on imputed genotype data.

- a) Sample/SNP extraction: Select specific subsets of individuals or variants.
- b) PCA for batch effects: Run PCA to detect technical artifacts or batch effects.
- c) PRS calculation: Compute Polygenic Risk Scores (PRS) using public or custom scoring files.


## 1 - Respository structure <a name = "rep_stru"></a>

The table below summarizes the main files and directories in this repository, along with a brief description of their contents.
|File  |Description            |
|:----:|-----------------------|
|[scripts/](scripts/)|Folder containing all scripts used to build the workflow.|
|[docs/](docs/)|This folder includes PDF and PNG files that help illustrate the workflow, along with example tables and resulting plots.|

## 2 - Prerequisites <a name = "prere"></a>
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


## 3 - Workflow <a name = "workflow"></a>

This repository is organized into modular steps that reflect a standard genotype data processing pipeline, from raw data to downstream analyses like PRS. Below is the step-by-step workflow:

> ⚠️ **Warning**: The workflow is divided into two main sections:  
> **1_QC** – Initial Quality Control.
>             Input: Raw genotype data in PLINK format (.bed, .bim, .fam)
>             Steps:
                    - Filter SNPs with high missingness (>5%)
                    - Remove samples with high missingness or heterozygosity outliers

Check sex concordance

Identify and remove duplicates or related individuals (pi_hat > 0.8)

Filter by Hardy-Weinberg equilibrium (HWE)

Perform PCA using AIMS to detect population outliers

Classify ancestry (European, Latino, Asian, African)
> **2. Statistical Analysis** – Includes diversity metrics, differential abundance testing, and predictive modeling.  
>  
> Below is a high-level overview of the steps involved in each section.  
> For detailed usage instructions, please refer to the dedicated README inside each folder.
---

![Workflow Overview](docs/Workflow.png)


### 1. Metagenomics pipeline

[scripts/1_Metagenomics_pipeline](scripts/1_Metagenomics_pipeline)

Part1:

- `1_human_remove.sh` - Aligns raw reads to the human genome using Bowtie2 (--very-sensitive-local -k 1) and removes human reads using Samtools.
- `2_QC_before.sh` - Initial Quality Control (QC). Performs quality assessment on raw FASTQ files using FastQC and aggregates reports with MultiQC.
- `3_dedup_trim.sh` - Deduplication and Trimming. Removes duplicate reads using Clumpify, applies quality trimming (PHRED > 20) and adapter removal using BBDuk, and discards read pairs where one read is shorter than 75 bp.
- `4_QC_after.sh` - Post-Trimming Quality Control. Re-runs FastQC and MultiQC to assess quality improvements after trimming.
Taxonomic Profiling:
- `5.1_kraken.sh` – Classifies clean reads using Kraken2 with a 0.1% confidence threshold against the UHGG database.
- `5.2_braken.sh` – Refines species-level abundance estimates using Bracken with a read-length parameter of 150 bp.
- `5.3_krakentools2.sh` – Converts Kraken2/Bracken output into MetaPhlAn-style (MPA format) abundance tables for downstream analysis.

Part2:

- `6_batch_correction.rmd` - (Optional) Batch Effect Correction. Applies batch effect correction using the ConQuR package if technical variation is detected across sample groups.
- `7_taxonomic_data_preparation.rmd` - Taxonomic Data Preparation. Prepares taxonomic abundance data for statistical analysis: includes genome length normalization, zero replacement using zCompositions, compositional data handling, and centered log-ratio (CLR) transformation.
- `8_phyloseq_object_creation.rmd` - (Optional) Phyloseq Object Creation. Builds a phyloseq object from the processed abundance table, taxonomy assignments, and metadata (e.g., case vs. control) for structured downstream ecological and statistical analysis.
                   

### 2. Statistical Analysis:
[scripts/2_statistical_analysis](scripts/2_statistical_analysis)

            a. Alpha and beta diversity – Alpha diversity calculated with Shannon and Chao1 indices; beta diversity assessed using Aitchison distance and PERMANOVA.
            b. Differential abundance analysis – Performed using ANCOM-BC and LINDA.
            c. Predictive modeling – Includes LASSO regression with glmnet and performance evaluation via AUC.
            d. Functional analysis – Functional profiling of metagenomic reads was performed using HUMAnN3, allowing the identification of gene families and metabolic pathways. Results were normalized (copies per million), stratified by taxonomy when appropriate, and used for downstream comparisons of functional potential across sample groups.

### 3. Data Visualization:
            a. Volcano plots – Run volcano_plot.R to visualize differentially abundant taxa or pathways.
            b. Heatmaps – Use heatmap.R to generate heatmaps for significant microbial associations.
            c. (Optional additional items can be listed here, such as ordination plots or bar charts, if applicable.)

## 4 - Authors <a name = "authors"></a>
This pipeline was primarily developed and implemented by:

Núria Moragas, PhD – [@nmoragas](https://github.com/nmoragas)
Designed, developed, and documented the full metagenomics pipeline, including data preprocessing, taxonomic classification, functional profiling, and downstream analyses.

The statistical analysis section integrates specific functions contributed by:

Elies Ramon, PhD – [@elies-ramon](https://github.com/elies-ramon)
Provided and adapted several functions used for alpha and beta diversity, as well as parts of the compositional data analysis pipeline.
