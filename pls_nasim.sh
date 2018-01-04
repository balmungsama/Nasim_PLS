#!/bin/bash
#SBATCH -c 4            # Number of CPUS requested. If omitted, the default is 1 CPU.
#SBATCH --mem=10240     # Memory requested in megabytes. If omitted, the default is 1024 MB.
#SBATCH -t 0-0:10:0      # How long will your job run for? If omitted, the default is 3 hours.


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
bsr_thr=3

## grab user-specified variables ##

while getopts p:l:i:b:m:f:r:o:n:h: option; do
	case "${option}" in
		p) pipe=${OPTARG}
			 pipe="pipe=$pipe";;

		l) bsr_thr=${OPTARG}
			 bsr_thr="bsr_thr=$bsr_thr";;

		i) OPPNI_dir=${OPTARG}
			 OPPNI_dir="OPPNI_dir='$OPPNI_dir'"
			 MATLAB_CMD=$(echo "$MATLAB_CMD;$OPPNI_dir");;

		b) behav_path=${OPTARG}
			 behav_path="behav_path='$behav_path'"
			 MATLAB_CMD=$(echo "$MATLAB_CMD;$behav_path");;

		m) mask=${OPTARG}
			 mask="mask='$mask'"
			 MATLAB_CMD=$(echo "$MATLAB_CMD;$mask");;

		f) filt=${OPTARG}
			 filt="filt='$filt'"
			 MATLAB_CMD=$(echo "$MATLAB_CMD;$filt");;

		r) outlier_ls=${OPTARG}  # seperate outlier names using semicolons, ;
			 outlier_ls="outlier_ls='$outlier_ls'"
			 MATLAB_CMD=$(echo "$MATLAB_CMD;$outlier_ls");;

		o) output_path=${OPTARG}
			 output_path="output_path='$output_path'"
			 MATLAB_CMD=$(echo "$MATLAB_CMD;$output_path");;

		n) output_name=${OPTARG}
			 output_name="output_name='$output_name'"
			 MATLAB_CMD=$(echo "$MATLAB_CMD;$output_name");;

		h) echo_help=${OPTARG};;
	esac
done

## add in the pipeline and bsr_thr values ##

MATLAB_CMD=$(echo "$MATLAB_CMD;$pipe;$bsr_thr")

## add script to MATLAB_CMD ##

run_script="run('$nasim_pls_path/run_pls.m')"
MATLAB_CMD=$(echo "$MATLAB_CMD;$run_script")

## run the script ##

matlab -nodesktop -nosplash -r $MATLAB_CMD

## tell me you're done ##

echo '    '
echo 'done'