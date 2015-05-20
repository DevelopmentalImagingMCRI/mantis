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


vols3         = cfg_files;
vols3.tag     = 'origtmaps';
vols3.name    = 'Standard tissue map';
vols3.help    = {['Phase 1 tissue maps (to indicate channel count)']};
vols3.filter = 'image';
vols3.ufilter = '.*';
vols3.num     = [1 Inf];


job         = cfg_exbranch;
job.tag     = 'tissueclassif2';
job.name    = 'Final spm segmentation';
job.val     = {vols vols2 vols3};
job.help    = {
    'Tissue classification with customized template'
    };
job.prog = @cg_mantis_second_run;
job.vout = @vout;

end

function dep = vout(job)
% These outputs are only useful for moving images around. We can't
% produce an output of the style of phase 1 without knowing how many
% channels in the template,

cdep = cfg_dep;
cdep(end).sname      = 'Structural';
cdep(end).src_output = substruct('.','structural','()',{':'});
cdep(end).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});

if ~strcmp(job.origtmaps,'<UNDEFINED>')
    
    for i=1:numel(job.origtmaps),
        cdep(end+1) = cfg_dep;
        cdep(end).sname      = sprintf('Classification with patient specific template c%d', i);
        cdep(end).src_output = substruct('.','patientspecifictemplate','{}',{i});
        cdep(end).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});
    end
end
dep=cdep;

end


function res = cg_mantis_second_run(job)
    
if numel(job.vols) ~= numel(job.tmaps)
    error('Number of scans does not match number of templates')
end

for k=1:numel(job.vols)
   t2=char(job.vols{k});
   tmap=char(job.tmaps{k});
   
   guijob = cg_phase1_tissue_classification(tmap);
   guijob.tag = 'phase2';
   guijob.name = 'Mantis: phase2 tissue classification';
   % now we harvest it to produce a job object
   [tag, onesegmentjob, typ, dep, chk, cj] =harvest(guijob,0,0,0);
   onesegmentjob.channel.vols = {t2};
   % setup a batch job
   % note that this needs to match phase1, as we are really using the same
   % code
   matlabbatch{1}.spm.tools.mantis.phase2=onesegmentjob;

   spm_jobman('initcfg')
   spm_jobman('run', matlabbatch);
   
   % create the output object
   tpmV = spm_vol(tmap);
   tissueclasses = length(tpmV);
   
   for i=1:tissueclasses
      [path, name, ext ] = fileparts(t2);
      thisone = fullfile(path, ['c' sprintf('%d', i) name ext]);
      res.patientspecifictemplate{i}{k}= thisone;
   end
   res.structural{k}=t2;
end
   
end