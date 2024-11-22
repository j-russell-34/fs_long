addpath(genpath('/Applications/freesurfer/7.4.1/matlab/lme'))

dir = '/Users/jasonrussell/Documents/OUTPUTS/fslong_A001';
sub_dir = '/Applications/freesurfer/7.4.1/subjects';

[Y,mri] = fs_read_Y(sprintf('%s/lh.thickness_sm10.mgh', dir));

Qdec = fReadQdec(sprintf('%s/long.qdec.table_test.dat', dir));
Qdec = rmQdecCol(Qdec,1);
sID = Qdec(2:end,1);
Qdec = rmQdecCol(Qdec,1);
M = Qdec2num(Qdec);

[M,Y,ni] = sortData(M,1,Y,sID);

lhsphere = fs_read_surf(sprintf('%s/fsaverage/surf/lh.sphere', sub_dir));
lhcortex = fs_read_label(sprintf('%s/fsaverage/label/lh.cortex.label', sub_dir));