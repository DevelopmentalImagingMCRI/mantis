function job = cg_mantis_phases
% retrieves the default phase directories
% and makes them available
% as a dependency object.
% Will make both the full path and the prefix available

vols         = cfg_files;
vols.tag     = 'vols';
vols.name    = 'Volumes';
vols.help    = {['Structural scans - Phase folder names will be derived from this.']};
vols.filter = 'image';
vols.ufilter = '.*';
vols.num     = [1 Inf];

job         = cfg_exbranch;
job.tag     = 'phasefolders';
job.name    = 'Folders for phases - image files get placed here';
job.val     = {vols };
job.help    = {
    'Helper object to look up sub folder names and provide them as dependencies'
    };
job.prog = @mantis_phases;
job.vout = @vout;

end

function dep = vout(job)
cdep = cfg_dep;
cdep(end).sname      = 'Phase1 subfolder';
cdep(end).src_output = substruct('.','outpathphase1','()',{':'});
cdep(end).tgt_spec   = cfg_findspec({{'filter','dir','strtype','e'}});

cdep(end+1) = cfg_dep;
cdep(end).sname      = 'Phase2 subfolder';
cdep(end).src_output = substruct('.','outpathphase2','()',{':'});
cdep(end).tgt_spec   = cfg_findspec({{'filter','dir','strtype','e'}});

cdep(end+1) = cfg_dep;
cdep(end).sname      = 'Phase3 subfolder';
cdep(end).src_output = substruct('.','outpathphase3','()',{':'});
cdep(end).tgt_spec   = cfg_findspec({{'filter','dir','strtype','e'}});

cdep(end+1) = cfg_dep;
cdep(end).sname      = 'Phase1 subfolder (not full path)';
cdep(end).src_output = substruct('.','phase1fold','()',{':'});
cdep(end).tgt_spec   = cfg_findspec({{'filter','dir','strtype','e'}});

cdep(end+1) = cfg_dep;
cdep(end).sname      = 'Phase2 subfolder (not full path)';
cdep(end).src_output = substruct('.','phase2fold','()',{':'});
cdep(end).tgt_spec   = cfg_findspec({{'filter','dir','strtype','e'}});

cdep(end+1) = cfg_dep;
cdep(end).sname      = 'Phase3 subfolder (not full path)';
cdep(end).src_output = substruct('.','phase3fold','()',{':'});
cdep(end).tgt_spec   = cfg_findspec({{'filter','dir','strtype','e'}});

cdep(end+1) = cfg_dep;
cdep(end).sname      = 'Structural image folder (root)';
cdep(end).src_output = substruct('.','root','()',{':'});
cdep(end).tgt_spec   = cfg_findspec({{'filter','dir','strtype','e'}});


cdep (end+1) = cfg_dep;
cdep(end).sname      = 'Phase1 single subfolder';
cdep(end).src_output = substruct('.','outpathphase1','()',{1});
cdep(end).tgt_spec   = cfg_findspec({{'filter','dir','strtype','e'}});

cdep(end+1) = cfg_dep;
cdep(end).sname      = 'Phase2 single subfolder';
cdep(end).src_output = substruct('.','outpathphase2','()',{1});
cdep(end).tgt_spec   = cfg_findspec({{'filter','dir','strtype','e'}});

cdep(end+1) = cfg_dep;
cdep(end).sname      = 'Phase3 single subfolder';
cdep(end).src_output = substruct('.','outpathphase3','()',{1});
cdep(end).tgt_spec   = cfg_findspec({{'filter','dir','strtype','e'}});


cdep(end+1) = cfg_dep;
cdep(end).sname      = 'Structural single image folder (root)';
cdep(end).src_output = substruct('.','root','()',{1});
cdep(end).tgt_spec   = cfg_findspec({{'filter','dir','strtype','e'}});

% stuff for template

dep=cdep;

end
function mantisMkDir(srcd, p)
[success, message, messageid] = mkdir(srcd,p);
if (success ~= 1) & ~strcmp(messageid, 'MATLAB:MKDIR:DirectoryExists')
    message
end
end

function res = mantis_phases(job)
p1 =  char(cg_mantis_get_defaults('opts.phase1'));
p2 =  char(cg_mantis_get_defaults('opts.phase2'));
p3 =  char(cg_mantis_get_defaults('opts.phase3'));
for k=1:numel(job.vols)
    structural = char(job.vols{k});
    [srcdir, imname, ext]=fileparts(structural);
    root{k}=srcdir;
    outpathphase1{k}=fullfile(srcdir, p1);
    outpathphase2{k}=fullfile(srcdir, p2);
    outpathphase3{k}=fullfile(srcdir, p3);
    phase1fold{k}=p1;
    phase2fold{k}=p2;
    phase3fold{k}=p3;
    % create the folders here - saves messing around with more
    % complex batch jobs
    mantisMkDir(srcdir, p1);
    mantisMkDir(srcdir, p2);
    mantisMkDir(srcdir, p3);
end
res.outpathphase1=outpathphase1;
res.outpathphase2=outpathphase2;
res.outpathphase3=outpathphase3;
res.phase1fold=phase1fold;
res.phase2fold=phase2fold;
res.phase3fold=phase3fold;

res.root=root;

end
