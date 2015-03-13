function spm_segrun1(root_dir)
% List of open inputs
% New Segment: Volumes - cfg_files
 % enter the number of runs here
%jobfile = {'/home/jianc/spm8_4337/toolbox/ANBS/segment_ext_job.m'};
jobfile = {fullfile(spm('dir'),'toolbox','ANBS', 'segment_ext_job.m')};
jobs = repmat(jobfile, 1, 1);

data={fullfile(root_dir, spm_select('List',root_dir,'^*.nii'))};
nrun = length(data);

spm('defaults', 'PET');
inputs = cell(1, nrun);
for crun = 1:nrun
    inputs = cellstr(data{crun}); % New Segment: Volumes - cfg_files
    spm_jobman('serial', jobs, '', inputs);
end


