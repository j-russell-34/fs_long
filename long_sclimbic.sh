#!/bin/bash

#setup FS
export FREESURFER_HOME=/Applications/freesurfer/7.4.1
export out_dir=/Users/jasonrussell/Documents/OUTPUTS/fslong_A001
export in_dir=/Users/jasonrussell/Documents/INPUTS/fslong_A001
export SUBJECTS_DIR=$in_dir/resources/SUBJECTS
source $FREESURFER_HOME/SetUpFreeSurfer.sh

#run sclimbic on brains in subject specific longitudinal space
for long_dir in "${SUBJECTS_DIR}"/*_e*.long.*; do
    # Extract subject ID and time point
    subject=$(basename "${long_dir}")
    subject_id=$(echo "${subject}" | cut -d'.' -f1)

    # Define the path to the orig.mgz file
    orig_file="${long_dir}/mri/orig.mgz"

    # Check if orig.mgz exists
    if [[ -f "${orig_file}" ]]; then
        echo "Processing ${orig_file} for subject ${subject_id}..."

        # Run the sclimbic pipeline (replace "sclimbic_command" with the actual command)
        mri_sclimbic_seg \
            --i "${orig_file}" \
            --o "${out_dir}" --write_volumes --write_qa_stats --etiv

        echo "Finished processing ${orig_file} for subject ${subject_id}."

        else
        echo "Warning: orig.mgz not found for ${long_dir}."
    fi
done

