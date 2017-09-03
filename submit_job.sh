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

for var in ${BEHAV_vars[@]}; do
	BEHAV_vars_ls="$BEHAV_vars_ls'$var',"
done

BEHAV_vars_ls=${BEHAV_vars_ls%","}

PLS_OPPNI_dir="OPPNI_dir='$OPPNI_dir'"
PLS_OUTPUT_dir="OUTPUT_dir='$OUTPUT_dir'"
PLS_BEHAV_dir="BEHAV_dir='$BEHAV_dir'"
PLS_BEHAV_vars="BEHAV_vars={$BEHAV_vars_ls}"
PLS_PIPE="PIPE=$PIPE"
PLS_VAR_NORM="VAR_NORM=$VAR_NORM"

# VARIABLE_LIST=($(compgen -v PLS_))

# MATLAB_COMMAND=''
# for var in ${VARIABLE_LIST[@]}; do
# 	var=$(echo $var)
# 	MATLAB_COMMAND="$MATLAB_COMMAND $var;"
# done

MATLAB_COMMAND="$PLS_OPPNI_dir;$PLS_OUTPUT_dir;$PLS_BEHAV_dir;$PLS_BEHAV_vars;$PLS_PIPE;$PLS_VAR_NORM"

PLS_RUN="run('$PLS_PATH/run_pls.m')"

MATLAB_COMMAND="$MATLAB_COMMAND;$PLS_RUN"

echo $MATLAB_COMMAND

matlab -nosplash -nodesktop -r $MATLAB_COMMAND
