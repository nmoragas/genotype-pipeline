# 🧬 Genotyping Data Processing Pipeline

This repository contains a set of independent scripts and tools to manipulate, clean, and prepare genotyping data in VCF or PLINK formats. Each script performs a specific task and can be used separately depending on the needs of the project.

## 📁 Pipeline Overview

1. **`1_merge_vcf_files.rmd`**  
   Merges VCF files from different cohorts or batches for each chromosome.

2. **`2_extract_samples/`**  
   Extracts a subset of samples based on a predefined list. Can be used to select study-specific individuals or remove unwanted samples.

3. **`3_concatenate_chromosomes/`**  
   Concatenates all chromosomes into a single genome-wide VCF file per individual or group, enabling downstream genome-wide analyses.

4. **`4_transform_vcf_to_plink/`**  
   Converts the VCF files to PLINK format (`.bed/.bim/.fam`) using standard tools (e.g., `plink2` or `vcftools`), required for many GWAS and QC steps.

5. **`6_filter_low_quality_snps.rmd`**  
   Filters out SNPs with low imputation quality (e.g., based on R² or INFO score thresholds) to retain only high-confidence variants.

> 🔢 **Note**: Step 5 is either intentionally skipped or handled elsewhere.

## 🛠 Requirements

- `bcftools`
- `plink2`
- `vcftools` (if used)
- R + packages: `tidyverse`, `data.table`, `knitr`, etc.

## 📌 Usage

Each step can be run independently, depending on your dataset and goals. Adjust paths and parameters within each script as needed for your environment.

