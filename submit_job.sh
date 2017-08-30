#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -M hpc3586@localhost
#$ -m be
#$ -q abaqus.q

cd /home/hpc3586/JE_packages/Nasim_PLS

date=$(date +%F)

#mkdir -p error/$date
#mkdir -p output/$date
mkdir -p results/$date

matlab -nosplash -nodesktop -r "run('run_pls.m')"
