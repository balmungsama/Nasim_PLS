#!/bin/bash
#SBATCH -c 4            # Number of CPUS requested. If omitted, the default is 1 CPU.
#SBATCH --mem=10240     # Memory requested in megabytes. If omitted, the default is 1024 MB.
#SBATCH -t 1-1:1:1      # How long will your job run for? If omitted, the default is 3 hours.


## TODO ##

# 1. integrate the mask into the analysis


## package filepath ##

nasim_pls_path='/global/home/hpc3586/JE_packages/Nasim_PLS'

## help text ##

# -p pipe        : CON = 1, FIX = 2, IND, = 3
# -t bsr_thr     : bootstrap ratio threshold to use for the PLS 
# -i OPPNI_dir   : oppni output directory
# -b behav_path  : path leading to a text file of column-wise behavioural data
# -m mask        : (optional) a mask file for the fMRI data
# -f filter      : a filter to only include SPMs which contain a given keyword
# -r outlier_ls  : a list of outliers to exclude from the initial analysis
# 								 formated as <subjid>, run<run#>, or <subjid>_run<run#>
# 								 seperate multiple entries using semicolons, ;
# -o output_path : a directory to output the pls results file
# -n output_name : the filename prefix of the .mat output
#  								 prefix_behavPLS.mat

## default values ##

pipe=2
bsr=3

## grab user-specified variables ##

while getopts p:i:b:m:f:r:o:n:h: option; do
	case "${option}" in
		p) pipe=${OPTARG};;
		t) bsr_thr=${OPTARG};;
		i) OPPNI_dir=${OPTARG};;
		b) behav_path=${OPTARG};;
		m) mask=${OPTARG};;
		f) filter=${OPTARG};;
		r) outlier_ls=${OPTARG};;  # seperate outlier names using semicolons, ;
		o) output_path=${OPTARG};;
		n) output_name=${OPTARG};;
		h) echo_help=${OPTARG};;
	esac
done

## prep variables ##

pipe="pipe=$pipe"
bsr_thr="bsr_thr=$bsr_thr"
OPPNI_dir="OPPNI_dir='$OPPNI_dir'"
behav_path="behav_path='$behav_path'"
mask="mask='$mask'"
filter="filter='$filter'"
outlier_ls="outlier_ls='$outlier_ls'"
output_path="output_path='$output_path'"
output_name="output_name='$output_name'"

run_script="run('$nasim_pls_path/run_pls.m')"

## compile variables ##

MATLAB_CMD="$pipe;$bsr_thr;$OPPNI_dir;$behav_path;$mask;$filter;$outlier_ls;$output_path;$output_name;$run_script"

matlab -nodesktop -nosplash -r $MATLAB_CMD

echo '    '
echo 'done'