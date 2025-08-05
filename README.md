# 🧬 genotype-pipeline
<p align="left">
Pipeline for genotype data processing: quality control, imputation preparation, post-imputation filtering, and polygenic risk score analysis
</p>

---

 
## Table of contents

- [0 - Overview](#over) - Overview of the project's purpose and goals
- [1 - Respository structure](#rep_stru) - Instructions on how to begin with this project
- [2 - Prerequisites](#prere) - Required software and installation steps 
- [3 - Workflow](#workflow) - Detailed guide to each stage of the project
- [4 - Authors](#authors) 


## 0 - Overview <a name = "over"></a>
---

This repository contains scripts and resources for a complete pipeline to process genotyping data in PLINK format. 
It includes quality control (QC) steps, imputation preparation, post-imputation filtering, and polygenic risk score (PRS) calculation.

### 🔹  1_QC/ – Genotype Quality Control
This module applies comprehensive QC to raw genotype data using PLINK and R. It filters SNPs and samples with high missingness, detects heterozygosity outliers, and ensures sex concordance. Related individuals are identified and one from each pair is removed. SNPs failing Hardy-Weinberg Equilibrium are excluded. Finally, PCA using Ancestry Informative Markers (AIMS) is used to detect population stratification and classify individuals into ancestry groups (e.g., European, Latino, Asian, African) for appropriate downstream analysis.



### 🔹  2_data_preparation/ – Imputation Preparation
This stage ensures that genotype data is compatible with imputation servers and reference panels. It includes final SNP filtering to remove ambiguous variants, optional coordinate conversion (LiftOver) to match genome builds, and allele matching using tools like Wrayner. The cleaned data is then converted to VCF format, compressed, and indexed (.vcf.gz + .tbi) for imputation.



### 🔹  3_imputation/ – Imputation via TOPMed
This step uses the TOPMed Imputation Server to infer missing genotypes, increasing genomic coverage for downstream analyses like GWAS or PRS.

Data must first be prepared in the required format (compressed and indexed VCFs). After uploading to the server and configuring imputation parameters, the resulting imputed VCF files are downloaded, decompressed, and organized for further analysis.



### 🔹  4_analysis/ – Post-Imputation Analysis
This final stage focuses on post-imputation analyses to extract meaningful insights from the genotype data. Sample and SNP extraction. Subset the imputed dataset by selecting specific individuals or variants of interest for targeted analyses, etc

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

            a. *1_merge_vcf_files.rmd*. Merges VCF files from different cohorts or batches for each chromosome.
            b. 2_extract_samples/. Extracts a subset of samples based on a predefined list. Can be used to select study-specific individuals or remove unwanted samples.
            c. 3_concatenate_chromosomes/. Concatenates all chromosomes into a single genome-wide VCF file per individual or group, enabling downstream genome-wide analyses.
            d. `4_transform_vcf_to_plink/`. Converts the VCF files to PLINK format (.bed/.bim/.fam) using standard tools (e.g., plink2 or vcftools), required for many GWAS and QC steps.
            e. `5_filter_low_quality_snps.rmd`. Filters out SNPs with low imputation quality (e.g., based on R² or INFO score thresholds) to retain only high-confidence variants.



## ✍️ 4 - Authors <a name = "authors"></a>
---

This pipeline was primarily developed and implemented by:

Núria Moragas, PhD – [@nmoragas](https://github.com/nmoragas)
Led the development, adaptation, and documentation of the pipeline, including downstream analyses.

Anna Diez
Contributed to the initial implementation of the imputation pipeline.

