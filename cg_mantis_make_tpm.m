function job = cg_mantis_make_tpm
vols         = cfg_files;
vols.tag     = 'vols';
vols.name    = 'Volumes';
vols.help    = {['Select WS CSF map from phase 2. Other images will be ' ...
                 'figured out.']};
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
phase1Dir.num     = [1 inf];

phase2Dir         = cfg_files;
phase2Dir.tag     = 'target';
phase2Dir.name    = 'Target Directory';
phase2Dir.help    = {'Directory where the Phase2 results were put.'};
phase2Dir.filter = 'dir';
phase2Dir.ufilter = '.*';
phase2Dir.num     = [1 Inf];


job         = cfg_exbranch;
job.tag     = 'maketpm';
job.name    = 'Make subject specific template';
job.val     = {vols phase1Dir phase2Dir};
job.help    = {
    'Make subject specific template using deformed template tissue and WS of csf'
    };
job.prog = @cg_mantis_make_tpm_run;
job.vout = @vout;

end

function dep = vout(job)
% The output of this job is always the same
cdep = cfg_dep;
cdep(end).sname      = 'Subject template';
cdep(end).src_output = substruct('.','tissuemap','()',{':'});
cdep(end).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});
dep=cdep;

%% Note - this will need to change if the number of template channels changes
% It is not quite right, and we don't use the channel information, so 
% leave it out for now.
% 
% cdep (end+1) = cfg_dep;
% cdep(end).sname      = 'Subject template channel 1';
% cdep(end).src_output = substruct('.','subtissuemap','()',{'1'});
% cdep(end).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});
% dep=cdep;
% 
% cdep (end+1) = cfg_dep;
% cdep(end).sname      = 'Subject template channel 2';
% cdep(end).src_output = substruct('.','subtissuemap','()',{'2'});
% cdep(end).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});
% dep=cdep;
% 
% cdep (end+1) = cfg_dep;
% cdep(end).sname      = 'Subject template channel 3';
% cdep(end).src_output = substruct('.','subtissuemap','()',{'3'});
% cdep(end).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});
% dep=cdep;
% 
% cdep (end+1) = cfg_dep;
% cdep(end).sname      = 'Subject template channel 4';
% cdep(end).src_output = substruct('.','subtissuemap','()',{'4'});
% cdep(end).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});
% dep=cdep;
% 
% cdep (end+1) = cfg_dep;
% cdep(end).sname      = 'Subject template channel 5';
% cdep(end).src_output = substruct('.','subtissuemap','()',{'5'});
% cdep(end).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});
% dep=cdep;
% 
% cdep (end+1) = cfg_dep;
% cdep(end).sname      = 'Subject template channel 6';
% cdep(end).src_output = substruct('.','subtissuemap','()',{'6'});
% cdep(end).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});
% dep=cdep;
% 
% cdep (end+1) = cfg_dep;
% cdep(end).sname      = 'Subject template channel 7';
% cdep(end).src_output = substruct('.','subtissuemap','()',{'7'});
% cdep(end).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});
% dep=cdep;
% 
% cdep (end+1) = cfg_dep;
% cdep(end).sname      = 'Subject template channel 8';
% cdep(end).src_output = substruct('.','subtissuemap','()',{'8'});
% cdep(end).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});
% dep=cdep;
% 
% cdep (end+1) = cfg_dep;
% cdep(end).sname      = 'Subject template channel 9';
% cdep(end).src_output = substruct('.','subtissuemap','()',{'9'});
% cdep(end).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});
% dep=cdep;


end

