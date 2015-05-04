function job=cg_mantis_firstnorm
job         = cfg_exbranch;
job.tag     = 'neonatefirstnorm';
job.name    = 'Path for all components of the neonate firstnorm';
job.val     = {};
job.help    = {
    'Helper object to make a firstnorm available as a dependency'
    };
job.prog = @mantis_firstnorm;
job.vout = @vout;
end

function dep = vout(job)
cdep = cfg_dep;
cdep(end).sname      = 'Neonate firstnorm';
cdep(end).src_output = substruct('.','tissuemap','()',{':'});
cdep(end).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});
dep=cdep;
end

function res = mantis_firstnorm(job)
    % don't need to use the job object. We are
    % just looking up defaults
    tpmimage = char(cg_mantis_get_defaults('opts.tpm2'));
    tpmcomponents = cg_mantis_get_defaults('opts.tpm2components');
    
    for k=1:tpmcomponents
        tissuemap{k}=[tpmimage ',' sprintf('%d',k)];
    end
    res.tissuemap=tissuemap;
end