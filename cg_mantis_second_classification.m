function job=cg_mantis_second_classification

%% Job to do the segmentation with customized template


vols         = cfg_files;
vols.tag     = 'vols';
vols.name    = 'Volumes';
vols.help    = {['T2 scans with cleaned up WM.']};
vols.filter = 'image';
vols.ufilter = '.*';
vols.num     = [1 Inf];

vols2         = cfg_files;
vols2.tag     = 'tmaps';
vols2.name    = 'Tissue maps';
vols2.help    = {['Customized tissue maps']};
vols2.filter = 'image';
vols2.ufilter = '.*';
vols2.num     = [1 Inf];


job         = cfg_exbranch;
job.tag     = 'tissueclassif2';
job.name    = 'Morphogical clean up of White matter';
job.val     = {vols vols2};
job.help    = {
    'Clean of structural image. CSF prob maps is used'
    };
job.prog = @cfg_mantis_second_run;
% We're going to return standard space only to start
%job.vout = @vout;

end

function dep = vout(job)
% The output of this job is always the same
cdep = cfg_dep;
cdep(end).sname      = 'Tissue classification with patient specific template';
cdep(end).src_output = substruct('.','patientspecifictemplate','()',{':'});
cdep(end).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});

cdep(end+1) = cfg_dep;
cdep(end).sname      = 'Structural';
cdep(functionend).src_output = substruct('.','structural','()',{':'});
cdep(end).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});

dep=cdep;

end


function res = cfg_mantis_second_run(job)
    
if numel(job.vols) ~= numel(job.tmaps)
    error('Number of scans does not match number of templates')
end

for k=1:numel(job.vols)
   t2=char(job.vols{k});
   tmap=char(job.tmaps{k});
   
   guijob = cfg_phase1_tissue_classification(tmap);
   % now we harvest it to produce a job object
   [tag, onesegmentjob, typ, dep, chk, cj] =harvest(guijob,0,0,0)
   onesegmentjob.channel.vols = {t2};
   spm_jobman('initcfg')
   spm_jobman('run', onesegmentjob);
   
end
end