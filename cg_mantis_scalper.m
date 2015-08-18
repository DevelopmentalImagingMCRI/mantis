function job = cg_mantis_scalper
%cfg_mantis_ws_csf batch setup
vols         = cfg_files;
vols.tag     = 'vols';
vols.name    = 'Volumes';
vols.help    = {['T2 weighted images. This is a simple, unvalidated scalper. Probably no worse than BET, and a heap faster.']};
vols.filter = 'image';
vols.ufilter = '.*';
vols.num     = [1 Inf];

scalperprefix = cfg_entry;
scalperprefix.tag = 'scalperprefix';
scalperprefix.name = 'Filename prefix for scalper output';
scalperprefix.help = {'String prepended to the filename of scalped images. Default is ''sc''.'};
scalperprefix.strtype='s';
scalperprefix.num = [1 Inf];
scalperprefix.def = ['sc'];

job         = cfg_exbranch;
job.tag     = 'wsscalper';
job.name    = 'Simple watershed scalping';
job.val     = {vols, scalperprefix};
job.help    = {
    'Segmentation of structural image using the watershed transform. GM and CSF prob maps are used'
    };
job.prog = @cg_mantis_scalper_run;
job.vout = @vout;

end

function dep = vout(job)
% The output of this job is always the same
cdep = cfg_dep;
cdep(end).sname      = 'Neonate T2 scalping';
cdep(end).src_output = substruct('.','scalped','()',{':'});
cdep(end).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});

cdep(end+1) = cfg_dep;
cdep(end).sname      = 'Structural';
cdep(end).src_output = substruct('.','structural','()',{':'});
cdep(end).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});

dep=cdep;

end

