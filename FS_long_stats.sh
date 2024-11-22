#!/bin/bash

#setup FS
export FREESURFER_HOME=/Applications/freesurfer/7.4.1
export out_dir=/Users/jasonrussell/Documents/OUTPUTS/fslong_A001
export in_dir=/Users/jasonrussell/Documents/INPUTS/fslong_A001
export SUBJECTS_DIR=$in_dir/resources/SUBJECTS
source $FREESURFER_HOME/SetUpFreeSurfer.sh


#generate subcortical stats table
asegstats2table --qdec-long $out_dir/long.qdec.table_test.dat --stats aseg.stats --tablefile $out_dir/aseg.table.txt


