#!/bin/bash
#SBATCH --job-name=testPLINKarray         	# Job name
#SBATCH --partition=highmem_p         	# Partition (queue) name
#SBATCH --nodes=2                     	# Number of nodes
#SBATCH --ntasks=16                   	# Number of MPI ranks
#SBATCH --mem=250gb                     # Job memory request
#SBATCH --time=02:00:00              	 # Time limit hrs:min:sec
#SBATCH --output=testPLINKarray.%j.out   	 # Standard output log
#SBATCH --error=testPLINKarray.%j.err     	# Standard error log
#SBATCH --array=1-20                   # Array range = chrs

ml PLINK/2.00-alpha2.3-x86_64-20200914-dev

i=$SLURM_ARRAY_TASK_ID #set array number to variable i

cd /work/kylab/mike

#code to see jobs. put in ~/.bashrc
#alias j="sacct --format=jobid,jobname%30,partition,state,elapsed,timelimit,exitcode"

#Set parameters
genofile=("/scratch/mf91122/UKBimputation/bgen_v1.2_UKBsource/files/ukb_imp_chr"$i"_v3.bgen")
samplefile=("/scratch/mf91122/UKBimputation/bgen_v1.2_UKBsource/files/ukb_imp_v3.sample")
outputdir=("/scratch/mf91122/temp1282021")
outputfile=("chr"$i".QC.bgen")


mkdir -p $outputdir


#run basic QC on UKB source bgen 1.2 files

plink2 \
--bgen $genofile ref-first \
--sample $samplefile \
--maf 0.01 \
--mind 0.05 \
--geno 0.02 \
--hwe 1e-06 \
--maj-ref \
--export bgen-1.2 \
--out $outputdir/$outputfile
