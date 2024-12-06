#!/bin/bash

# Set up FreeSurfer environment
export FREESURFER_HOME=/Applications/freesurfer/7.4.1
export out_dir=/Users/jasonrussell/Documents/OUTPUTS/fslong_A001
export in_dir=/Users/jasonrussell/Documents/INPUTS/fslong_A001
export SUBJECTS_DIR=$in_dir/SUBJECTS
source $FREESURFER_HOME/SetUpFreeSurfer.sh



# Preprocess cortical thickness data
mris_preproc --qdec-long $out_dir/long.qdec.table_test.dat \
             --target fsaverage --hemi lh --meas thickness \
             --out $out_dir/lh.thickness.mgh

mris_preproc --qdec-long $out_dir/long.qdec.table_test.dat \
             --target fsaverage --hemi rh --meas thickness \
             --out $out_dir/rh.thickness.mgh

# Smooth data
mri_surf2surf --hemi lh --s fsaverage --sval $out_dir/lh.thickness.mgh \
               --tval $out_dir/$subject/lh.thickness_sm10.mgh --fwhm-trg 10 --cortex --noreshape

mri_surf2surf --hemi rh --s fsaverage --sval $out_dir/rh.thickness.mgh \
               --tval $out_dir/$subject/rh.thickness_sm10.mgh --fwhm-trg 10 --cortex --noreshape

