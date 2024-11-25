%add fs dependencies
addpath(genpath('/Applications/freesurfer/7.4.1/matlab'))

%add directories
dir = '/Users/jasonrussell/Documents/OUTPUTS/fslong_A001';
sub_dir = '/Applications/freesurfer/7.4.1/subjects';

%import smoothed longitudinal data
[Y,mri] = fs_read_Y(sprintf('%s/lh.thickness_sm10.mgh', dir));

%import qdec and extract sub_ids, datamatrix
Qdec = fReadQdec(sprintf('%s/long.qdec.table_test.dat', dir));
Qdec = rmQdecCol(Qdec,1);
sID = Qdec(2:end,1);
Qdec = rmQdecCol(Qdec,1);
M = Qdec2num(Qdec);

%sort data matrix to match images in Y
[M,Y,ni] = sortData(M,1,Y,sID);

%make final data matrix including any interactions (age x timepoint)
X = [ones(length(M),1) M M(:,1).*M(:,2)];

%import sphere/cortex for plotting
lhsphere = fs_read_surf(sprintf('%s/fsaverage/surf/lh.sphere', sub_dir));
lhcortex = fs_read_label(sprintf('%s/fsaverage/label/lh.cortex.label', sub_dir));

%calculate covariance - lhTh0 for each vertex, lhRe residual for each
%vertex
[lhTh0,lhRe] = lme_mass_fit_EMinit(X,[1 2],Y,ni,lhcortex,3);

%calculate covariance for different regions (95 min verteces per region)
[lhRgs,lhRgMeans] = lme_mass_RgGrow(lhsphere,lhRe,lhTh0,lhcortex,2,95);

surf.faces =  lhsphere.tri;
surf.vertices =  lhsphere.coord';

%produce visualization. 1 is initail estimate, 2 is when grouped into regions - check these look similar to 
figure; p1 = patch(surf);
set(p1,'facecolor','interp','edgecolor','none','facevertexcdata',lhTh0(1,:)');

figure; p2 = patch(surf); set(p2,'facecolor','interp','edgecolor','none','facevertexcdata',lhRgMeans(1,:)');


%fit model
lhstats = lme_mass_fit_Rgw(X,[1 2],Y,ni,lhTh0,lhRgs,lhsphere);

%set contrast to assess age x timepoint interaction i.e. does rate of
%cortical thining differ by age
CM.C = [0 0 0 1];

F_lhstats = lme_mass_F(lhstats, CM);

%correct for multiple comparisons (FDR)
dvtx = lme_mass_FDR2(F_lhstats.pval, F_lhstats.sgn, lhcortex, 0.05, 0);

%export results to .mgh
fs_write_fstats(F_lhstats, mri, sprintf('%s/age_time_interaction.mgh', dir), 'sig');

