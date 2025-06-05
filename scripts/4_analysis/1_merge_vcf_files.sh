#!/bin/bash
#SBATCH --job-name=merge_gen           # Nom del treball
#SBATCH --mem=360G                 # Mem?ria sol?licitada (150 GB)
#SBATCH --output=merge_gen.txt         # Fitxer de sortida
#SBATCH --error=merge_gen.txt           # Redirigeix els errors al mateix fitxer que la sortida
#SBATCH --chdir=.                  # Executar el treball al directori actual


module load apps/bcftools/1.21

# Directori de treball
cd ./Dir

# Directori de sortida
resDir="./resDir"

# Llistat de directoris de projectes
dataDirs=(
  "./project_1/project_1"
  "./project_2/project_2"
  "./project_3/project_3"
)


# Per cada cromosoma
for chr in $(seq 1 22) X; do
  echo "Processant cromosoma $chr..."

  # Indexa els fitxers d'entrada
  for dir in "${dataDirs[@]}"; do
    bcftools index -f "${dir}/chr${chr}.dose.vcf.gz"
  done

  # Merge dels VCFs
  bcftools merge -m all \
    "${dataDirs[0]}/chr${chr}.dose.vcf.gz" \
    "${dataDirs[1]}/chr${chr}.dose.vcf.gz" \
    "${dataDirs[2]}/chr${chr}.dose.vcf.gz" \
    "${dataDirs[3]}/chr${chr}.dose.vcf.gz" \
    "${dataDirs[4]}/chr${chr}.dose.vcf.gz" \
    -Oz -o "${resDir}/Merged_data_chr${chr}.vcf.gz"

  # Indexa el fitxer de sortida
  bcftools index "${resDir}/Merged_data_chr${chr}.vcf.gz"
done
