# 🧬 Imputation Workflow with TOPMed Server
This section describes the steps to perform genotype imputation using the TOPMed Imputation Server.

## a) Upload VCF Files
Upload the preprocessed VCF files (e.g., one per chromosome) to the TOPMed Imputation Server with the following configuration:

  - Imputation Tool: Minimac4
  - Reference Panel: TOPMed r3
  - Build: GRCh38/hg38
  - r² Filter: Off
  - Phasing: Eagle v2.4 (Phased Input)
  - QC Frequency Check: Enabled (vs. TOPMed panel)
  - Mode: Quality Control and Imputation
  - Encryption: AES-256 (ensure the info file is embedded in the .vcf)

⚠️ Make sure all .vcf.gz files are properly sorted and indexed with bcftools index before uploading.

## b) Download Imputation Results
After imputation is complete, download the results using the secure download link provided by TOPMed. You can use curl to fetch and extract the data automatically.

```{bash}
# Run the download script from TOPMed (example ID/token)
curl -sL https://______ | bash
```

This will download all imputed chromosomes into a folder like ImputationResults/.

## c) Check Logs and QC Report
Review:

qcreport.html for imputation quality and warnings.
Server-generated logs for any chromosome-specific issues.

## d) Unzip the Results
Each chromosome is encrypted using AES-256 and packaged in .zip files. Extract them with 7z (7-Zip) using the password provided in your job confirmation.

```{bash}
# Define password
password="your_password_here"

# Extract chromosomes 1–22
for i in {1..22}; do
    7z e -p"$password" "chr_${i}.zip"
done

# Extract chromosome X
7z e -p"$password" "chr_X.zip"
```


🧹 You may delete the .zip files after extraction to save space.











