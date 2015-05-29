function job = cg_mantis_hardseg()
vols         = cfg_files;
vols.tag     = 'vols';
vols.name    = 'Tissue maps';
vols.help    = {['Select GM map from phase 1.']};
vols.filter = 'image';
vols.ufilter = '.*';
vols.num     = [1 Inf];

t2         = cfg_files;
t2.tag     = 'structural';
t2.name    = 'Structural volumes';
t2.help    = {['Scalped structural scans (T2).']};
t2.filter = 'image';
t2.ufilter = '.*';
t2.num     = [1 Inf];

job         = cfg_exbranch;
job.tag     = 'hardseg1';
job.name    = 'Hard segmentation of phase 1';
job.val     = {vols t2};
job.help    = {
    'Simple hard segmentation of phase 1 for detecting isolated misclassification following WM correction'
    };
job.prog = @cg_mantis_hardseg_run;
job.vout = @vout;
end


function dep = vout(job)
% The output of this job is always the same
cdep = cfg_dep;
cdep(end).sname      = 'Hard seg phase 1 - GM';
cdep(end).src_output = substruct('.','hard1','()',{':'});
cdep(end).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});

cdep(end+1) = cfg_dep;
cdep(end).sname      = 'Hard seg phase 1 - WM';
cdep(end).src_output = substruct('.','hard2','()',{':'});
cdep(end).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});

cdep(end+1) = cfg_dep;
cdep(end).sname      = 'Hard seg phase 1 - CSF';
cdep(end).src_output = substruct('.','hard3','()',{':'});
cdep(end).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});

dep=cdep;

end

