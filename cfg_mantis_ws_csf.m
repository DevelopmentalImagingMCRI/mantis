function job = cfg_mantis_ws_csf
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
vols         = cfg_files;
vols.tag     = 'vols';
vols.name    = 'Volumes';
vols.help    = {'Select scans from this channel for processing.'};
vols.filter = 'image';
vols.ufilter = '.*';
vols.num     = [1 Inf];

% Only provide an input for the structural scan. The csf and gm prob maps
% will be hard coded.

% subfolder where phase1 results go
phase1Dir         = cfg_files;
phase1Dir.tag     = 'parent';
phase1Dir.name    = 'Parent Directory';
phase1Dir.help    = {'Directory where the Phase1 results were put.'};
phase1Dir.filter = 'dir';
phase1Dir.ufilter = '.*';
phase1Dir.num     = [1 1];

job         = cfg_exbranch;
job.tag     = 'wscsf';
job.name    = 'Watershed segmentation of CSF';
job.val     = {vols phase1Dir };
job.help    = {
    'Segmentation of structural image using the watershed transform. GM and CSF prob maps are used'
    };
job.prog = @cfg_mantis_ws_csf_run;
job.vout = @vout;

end

function dep = vout(job)
% The output of this job is always the same
cdep = cfg_dep;
cdep(end).sname      = 'Watershed csf seg';
cdep(end).src_output = substruct('.','csfseg','()',{':'});
cdep(end).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});

dep=cdep;

end

