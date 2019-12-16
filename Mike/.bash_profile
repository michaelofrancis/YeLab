# .bash_profile

# Get the aliases and functions

alias samtoolsload='module load SAMtools/1.9-foss-2016b'
alias l='ls -alt'
alias igv1='xqlogin' 
alias igv2='module load IGV/2.4.4-Java-1.8.0_144; sh /usr/local/apps/eb/IGV/2.4.4-Java-1.8.0_144/igv.sh'
alias plink107='module load PLINK/1.07-foss-2016b'
alias plinkload='module load PLINK/1.9b_5-x86_64'
alias plink2load='module load PLINK/2.00-alpha2-x86_64-20191128'
alias Rload='module load R/3.6.1-foss-2018a-X11-20180131-GACRC'
alias j="qstat_me"
alias s="sleep infinity"
alias sc="cd /scratch/mf91122/"
alias w="cd /work/kylab/mike/"
alias pro="cd /project/kylab/"
alias 8="cd /scratch/mf91122/UKBimputation/8.GWAS_results_12142019"
alias bashreload="source ~/.bash_profile && echo Bash config reloaded"


if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs

PATH=$PATH:$HOME/.local/bin:$HOME/bin

export PATH
