#!/bin/bash
#SBATCH --partition=batch
#SBATCH --job-name=GEM_PHENO
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=16
#SBATCH --time=144:00:00
#SBATCH --mem=10000 #10 Gb is sufficient for the GEM jobs I have run
#SBATCH --output=GEM-PHENO.%j.out
#SBATCH --error=GEM-PHENO.%j.err
#SBATCH --array=1-22 #chromosome as array variable

#Mike Francis, 1-24-2021
#This script runs the GEM Genome-wide GxE interaction statistical software on all chromosomes for a given phenotype

#This sets the chromosome number (the array number) as i. All jobs will run in parallel as resources become available.
i=$SLURM_ARRAY_TASK_ID

module load GEM/1.1-foss-2019b


###Set Parameters ==============================

#Today's date
now=$(date +"%m_%d_%Y")

#Set imputed genotype data input directory
genoindir=("/scratch/mf91122/T-1/1.GWAS/filtered-QC-maj-ref-bgen")

#These genotype files are found here with the script that generated them from the original UKB files.
#/project/kylab/lab_shared/UKB/imputation/filtered-QC-maj-ref-bgen/
#Use these or use your own QC-ed genotype files.

#Set output directory
outdir=("PUTYOURDIRECTORYHERE")

#Set phenotype file Directory
phenodir=("PUTYOURDIRECTORYHERE")

mkdir -p "$outdir"

GEM \
--sample "$genoindir"/chr${i}.sample \
--bgen "$genoindir"/chr${i}.bgen \
--pheno-file "$phenodir"/YOURPHENOTYPEFILEMUSTBECSV.csv \
--sampleid-name IID \
--pheno-name PHENOCOLNAME \
--exposure-names EXPOSURECOLNAME \
--covar-names Sex Age BMI \
PCA1 PCA2 PCA3 PCA4 PCA5 PCA6 PCA7 PCA8 PCA9 PCA10 \
--pheno-type 0 \
--robust 1 \
--out "$outdir"/OUTPUTFILENAME_chr${i}_"$now".out
