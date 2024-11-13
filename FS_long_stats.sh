#!/bin/bash

#setup FS
source $FREESURFER_HOME/SetUpFreeSurfer.sh

#generate subcortical stats table
asegstats2table --qdec-long long.qdec.table.dat --stats aseg.stats --tablefile aseg.table.txt
