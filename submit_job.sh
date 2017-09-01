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
date=$(date +%F) # need to pass the date into Matlab too
mkdir -p results/$date
cd $PLS_PATH/results/$date

# extract behavioural variable names
BEHAV_vars=($BEHAV_vars)
BEHAV_vars_ls=''

for var in ${BEHAV_vars[@]};
	BEHAV_vars_ls="$BEHAV_vars_ls '$var' "
done

cmd_OPPNI_dir="OPPNI_dir='$OPPNI_dir'"
cmd_OUTPUT_dir="OUTPUT_dir='$OUTPUT_dir'"
cmd_BEHAV_dir="BEHAV_dir='$BEHAV_dir'"
cmd_BEHAV_vars="BEHAV_vars={$BEHAV_vars_ls}"
cmd_PIPE="PIPE=$PIPE"
cmd_VAR_NORM="VAR_NORM=$VAR_NORM"

MATLAB_COMMAND=''

VARIABLE_LIST=($(compgen -v cmd_))

for var in ${VARIABLE_LIST[@]}; do
	MATLAB_COMMAND="$MATLAB_COMMAND $var;"
done

cmd_RUN="run('$PLS_PATH/run_pls.m')"

MATLAB_COMMAND2="$MATLAB_COMMAND$cmd_RUN"

matlab -nosplash -nodesktop -r $MATLAB_COMMAND
