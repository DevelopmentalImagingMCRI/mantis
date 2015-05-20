function job=cg_mantis_template
job         = cfg_exbranch;
job.tag     = 'neonatetemplate';
job.name    = 'Path for all components of the neonate template';
job.val     = {};
job.help    = {
    'Helper object to make a template available as a dependency'
    };
job.prog = @mantis_template;
job.vout = @vout;
end

function dep = vout(job)
cdep = cfg_dep;
cdep(end).sname      = 'Neonate template';
cdep(end).src_output = substruct('.','tissuemap','()',{':'});
cdep(end).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});
dep=cdep;

cdep (end+1) = cfg_dep;
cdep(end).sname      = 'Neonate template channel 1';
cdep(end).src_output = substruct('.','tissuemap','()',{1});
cdep(end).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});
dep=cdep;

cdep (end+1) = cfg_dep;
cdep(end).sname      = 'Neonate template channel 2';
cdep(end).src_output = substruct('.','tissuemap','()',{2});
cdep(end).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});
dep=cdep;

cdep (end+1) = cfg_dep;
cdep(end).sname      = 'Neonate template channel 3';
cdep(end).src_output = substruct('.','tissuemap','()',{3});
cdep(end).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});
dep=cdep;

cdep (end+1) = cfg_dep;
cdep(end).sname      = 'Neonate template channel 4';
cdep(end).src_output = substruct('.','tissuemap','()',{4});
cdep(end).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});
dep=cdep;

cdep (end+1) = cfg_dep;
cdep(end).sname      = 'Neonate template channel 5';
cdep(end).src_output = substruct('.','tissuemap','()',{5});
cdep(end).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});
dep=cdep;

cdep (end+1) = cfg_dep;
cdep(end).sname      = 'Neonate template channel 6';
cdep(end).src_output = substruct('.','tissuemap','()',{6});
cdep(end).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});
dep=cdep;

cdep (end+1) = cfg_dep;
cdep(end).sname      = 'Neonate template channel 7';
cdep(end).src_output = substruct('.','tissuemap','()',{7});
cdep(end).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});
dep=cdep;

cdep (end+1) = cfg_dep;
cdep(end).sname      = 'Neonate template channel 8';
cdep(end).src_output = substruct('.','tissuemap','()',{8});
cdep(end).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});
dep=cdep;

cdep (end+1) = cfg_dep;
cdep(end).sname      = 'Neonate template channel 9';
cdep(end).src_output = substruct('.','tissuemap','()',{9});
cdep(end).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});
dep=cdep;


end

function res = mantis_template(job)
    % don't need to use the job object. We are
    % just looking up defaults
    tpmimage = char(cg_mantis_get_defaults('opts.tpm'));
    tpmcomponents = cg_mantis_get_defaults('opts.tpmcomponents');
    
    for k=1:tpmcomponents
        tissuemap{k}=[tpmimage ',' sprintf('%d',k)];
    end
    res.tissuemap=tissuemap;
end