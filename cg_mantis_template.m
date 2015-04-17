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