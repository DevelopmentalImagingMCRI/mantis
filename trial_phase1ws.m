% List of open inputs
nrun = X; % enter the number of runs here
jobfile = {'/home/jianc/spm8/toolbox/mantis/trial_phase1ws_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(0, nrun);
for crun = 1:nrun
end
spm('defaults', 'PET');
spm_jobman('serial', jobs, '', inputs{:});
