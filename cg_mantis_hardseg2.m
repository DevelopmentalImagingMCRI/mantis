function job = cg_mantis_hardseg2()
vols         = cfg_files;
vols.tag     = 'vols';
vols.name    = 'Tissue maps';
vols.help    = {['Select GM map from phase 2.']};
vols.filter = 'image';
vols.ufilter = '.*';
vols.num     = [1 Inf];

hp1         = cfg_files;
hp1.tag     = 'hardseg1';
hp1.name    = 'Phase 1 hard segmentation';
hp1.help    = {['Select GM hard segmentation from phase 1.']};
hp1.filter = 'image';
hp1.ufilter = '.*';
hp1.num     = [1 Inf];

t2         = cfg_files;
t2.tag     = 'structural';
t2.name    = 'Structural volumes';
t2.help    = {['Scalped structural scans (T2).']};
t2.filter = 'image';
t2.ufilter = '.*';
t2.num     = [1 Inf];

job         = cfg_exbranch;
job.tag     = 'hardseg2';
job.name    = 'Hard segmentation of phase 2';
job.val     = {vols t2 hp1};
job.help    = {
    'Simple hard segmentation of phase 1 for detecting isolated misclassification following WM correction'
    };
job.prog = @cg_mantis_hardseg2_run;
job.vout = @vout;
end


function dep = vout(job)
% The output of this job is always the same
cdep = cfg_dep;
cdep(end).sname      = 'Hard seg phase 2 - all';
cdep(end).src_output = substruct('.','hard','()',{':'});
cdep(end).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});

dep=cdep;

end

