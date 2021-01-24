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
#See also: https://github.com/large-scale-gxe-methods/GEM

###Set Parameters ==============================

#Set imputed genotype data input directory
genoindir=("PUTYOURGENOTYPEDIRECTORYHERE")

#For example, see /project/kylab/lab_shared/UKB/imputation/filtered-QC-maj-ref-bgen/
#These genotype files are given with the script that generated them from the original UKB files.
#Use these or use your own QC-ed genotype files.

#Set output directory
outdir=("PUTYOUROUTPUTDIRECTORYHERE")
outputfileprefix=("PHENO-EXPOSURE-examplename")

#Set phenotype parameters
phenodir=("PUTYOURDIRECTORYHERE")
phenofilename=("thenameofyourphenotypefile.csv")
phenotype=("nameofphenotypecolumn")
exposure=("nameofexposurecolumn")

covars=("Sex" "Age" "BMI" "PCA1" "PCA2" "PCA3") #put your covariates here

idname=("IID") #this should be how you named your UK Biobank phenotype file id column

typeofphenotype=("0") #0 indicates a continuous phenotype and 1 indicates a binary phenotype.  
robuststderr=("1") #0 for model-based standard errors and 1 for robust standard errors.

###=================================================================================
###End set Parameters===============================================================
###=================================================================================



#Today's date
now=$(date +"%m_%d_%Y") #no need to change this

#This sets the chromosome number (the array number) as i. All jobs will run in parallel as resources become available.
i=$SLURM_ARRAY_TASK_ID

module load GEM/1.1-foss-2019b

mkdir -p "$outdir"


GEM \
--sample "$genoindir"/chr${i}.sample \
--bgen "$genoindir"/chr${i}.bgen \
--pheno-file "$phenodir"/"$phenofilename" \
--sampleid-name "$idname" \
--pheno-name "$phenotype" \
--exposure-names "$exposure" \
--covar-names ${covars[*]} \
--pheno-type "$typeofphenotype" \
--robust "$robuststderr" \
--out "$outdir"/"$outputfileprefix"_chr${i}_"$now".out
