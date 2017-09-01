#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -M hpc3586@localhost
#$ -m be
#$ -q abaqus.q

OPPNI_dir=$1
BEHAV_dir=$2
OUTPUT_dir=$3
BEHAV_vars=$4
PIPE=$5
VAR_NORM=$6

PLS_PATH='/home/hpc3586/JE_packages/Nasim_PLS'
date=$(date +%F) 

OUTPUT_dir=$OUTPUT_dir/$date

mkdir -p $OUTPUT_dir
cd $OUTPUT_dir

# extract behavioural variable names
BEHAV_vars=($BEHAV_vars)
BEHAV_vars_ls=''

for var in ${BEHAV_vars[@]};
	BEHAV_vars_ls="$BEHAV_vars_ls '$var' "
done

PLScmd_OPPNI_dir="OPPNI_dir='$OPPNI_dir'"
PLScmd_OUTPUT_dir="OUTPUT_dir='$OUTPUT_dir'"
PLScmd_BEHAV_dir="BEHAV_dir='$BEHAV_dir'"
PLScmd_BEHAV_vars="BEHAV_vars={$BEHAV_vars_ls}"
PLScmd_PIPE="PIPE=$PIPE"
PLScmd_VAR_NORM="VAR_NORM=$VAR_NORM"
PLScmd_DATE="'$date'"

MATLAB_COMMAND=''

VARIABLE_LIST=($(compgen -v PLScmd_))

for var in ${VARIABLE_LIST[@]}; do
	MATLAB_COMMAND="$MATLAB_COMMAND $var;"
done

PLScmd_RUN="run('$PLS_PATH/run_pls.m')"

MATLAB_COMMAND2="$MATLAB_COMMAND$PLScmd_RUN"

matlab -nosplash -nodesktop -r $MATLAB_COMMAND
