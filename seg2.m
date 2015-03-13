function seg2 (idir)
%function seg2 (idir)
%Usage  
%       seg2(idir)
%     

jobfile = {fullfile(spm('dir'),'toolbox','ANBS', 'segment_run2_job.m')};
jobs = repmat(jobfile, 1, 1);

spm('defaults', 'PET');
%nrun=size(idir,1);
%inputs = cell(1, nrun);
out_dir=fullfile(idir, 'spm_run2');
subjtemp=fullfile(idir, 'spm_run2', 'subjtemplate');

wcsf = spm_select('FPList',out_dir,'^*csfmask*')
wvol = cellstr(strrep(wcsf(1,:), '_csfmask.nii', '.nii,1'));
vol =cellstr(strrep(wvol(1,:), '/w', '/'));

cortex = cellstr(fullfile(subjtemp, 'cortex_norm.nii,1')); 
wm = cellstr(fullfile(subjtemp, 'wm_norm.nii,1'));
csf = cellstr(fullfile(subjtemp, 'csf_norm.nii,1'));
dgm = cellstr(fullfile(subjtemp, 'deepgreymatter_map_norm.nii,1'));
hipp = cellstr(fullfile(subjtemp, 'hippocampus_map_norm.nii,1'));
amyg = cellstr(fullfile(subjtemp, 'amygdala_map_norm.nii,1'));
cere = cellstr(fullfile(subjtemp, 'cerebellum_norm.nii,1'));
brainstem = cellstr(fullfile(subjtemp, 'brainstem_norm.nii,1'));
background = cellstr(fullfile(subjtemp, 'background_norm.nii,1')); % New Segment: Volumes - cfg_files

spm_jobman('serial', jobfile, '', vol, cortex, wm, csf, dgm, hipp, amyg, cere, brainstem, background);
