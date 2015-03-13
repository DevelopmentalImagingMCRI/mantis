function transf_template (out_dir)
%function transf_template (rootdir)
%     
%Usage 
%       transf_template (out_dir)
%

jobfile = fullfile(spm('dir'),'toolbox','ANBS', 'deformation_job.m');
jobs = repmat(jobfile, 1, 1);

def = cellstr(spm_select('FPList',out_dir,'^iy.*\.nii$'));

firstnorm = cellstr(spm_select('FPList',out_dir,'^*firstnorm\.*\w'));
spm_jobman('serial', jobfile, '', def, firstnorm); 

brainedge = cellstr(spm_select('FPList',out_dir,'^*brain_edge\.*\w'));
spm_jobman('serial', jobfile, '', def, brainedge); 