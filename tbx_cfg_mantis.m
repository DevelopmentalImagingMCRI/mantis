function job = tbx_cfg_mantis
% Configuration file for Adoptive Neonatal Brain Segmentation
%_______________________________________________________________________
% Jian Chen
% $Id: tbx_cfg_mantis.m 7 2014-05-06 14:39:07Z chen $

addpath(fullfile(spm('dir'),'toolbox','mantis'));

%_______________________________________________________________________

data = cfg_files;
data.tag  = 'data';
data.name = 'Volumes';
data.help = {
'Select raw data (e.g. T1 images) for processing. '
'This assumes that there is one scan for each subject. '
'Note that multi-spectral (when there are two or more registered '
'images of different contrasts) processing is not yet implemented '
'for this method.'
};
data.filter = 'image';
data.ufilter = '.*';
data.num     = [1 Inf];

% ---------------------------------------------------------------------      
% idir Input Directory
% ---------------------------------------------------------------------      
idir= cfg_files;       
idir.tag     = 'idir'; 
idir.name    = 'Subject Directory';       
idir.val = {{'.'}};    
idir.help    = {       
       'This defaults to the current work directory. It is, however, a good '
       'idea to create a separate directory with a meaningful name for each project.' 
      }';    
idir.filter = 'dir';   
idir.ufilter = '.*';   
idir.num     = [1 1];     


% ---------------------------------------------------------------------      
% odir Output Directory
% ---------------------------------------------------------------------      
odir= cfg_files;       
odir.tag     = 'odir'; 
odir.name    = 'Output Directory';       
odir.val = {{'.'}};
odir.help    = {
    'This defaults to the current work directory. It is, however, a good '
    'idea to create a separate directory with a meaningful '
    'name for each project.'
      }';
odir.filter = 'dir';
odir.ufilter = '.*';
odir.num     = [1 1];


% ---------------------------------------------------------------------
% SPM run1
% ---------------------------------------------------------------------
segrun1= cfg_exbranch;
segrun1.tag     = 'segrun1';
segrun1.name    = 'SPM Segmentation run1';
%segrun1.val     = {data};    
segrun1.val     = {idir};
segrun1.help    = {'SPM Segmentation run1.'};
segrun1.prog = @(job)cg_mantis_jobs('segrun1',job);    
%segrun1.vout = @vout_spmrun1;

% ---------------------------------------------------------------------
% CSF segmentation
% ---------------------------------------------------------------------
segcsf= cfg_exbranch;
segcsf.tag     = 'segcsf';
segcsf.name    = 'Adaptive CSF segmentation';
%segcsf.val     = {data};    
segcsf.val     = {idir};
segcsf.help    = {'Adaptive CSF segmentation.'};
segcsf.prog = @(job)cg_mantis_jobs('segcsf',job);  
%segcsf.vout = @vout_spmcsf;

% ---------------------------------------------------------------------
% Clean White matter
% ---------------------------------------------------------------------
wmclean= cfg_exbranch;
wmclean.tag     = 'wmclean';
wmclean.name    = 'Clean White matter';
%wmclean.val     = {data};    
wmclean.val     = {idir};
wmclean.help    = {'Clean White matter.'};
wmclean.prog = @(job)cg_mantis_jobs('wmclean',job);       
%wmclean.vout = @vout_wmclean;

% %
% ---------------------------------------------------------------------
% % SPM run2
% % %
% ---------------------------------------------------------------------
% segrun2= cfg_exbranch;
% segrun2.tag     = 'segrun2';
% segrun2.name    = 'SPM Segmentation run2';
% % %segrun2.val     = {data};    
% segrun2.val     = {idir};
% segrun2.help    = {'SPM Segmentation run2.'};
segrun2=cg_mantis_segrun2;


% ---------------------------------------------------------------------
% Generate hard segmentation label
% ---------------------------------------------------------------------
hardlabel= cfg_exbranch;
hardlabel.tag     = 'hardlabel';
hardlabel.name    = 'Hard segmentation label';
%hardlabel.val     = {data};    
hardlabel.val     = {idir};
hardlabel.help    = {'Hard segmentation label.'};
hardlabel.prog = @(job)cg_mantis_jobs('hardlabel',job);       
%hardlabel.vout = @vout_hardlabel;

% ---------------------------------------------------------------------
% Calculate segmentation volume
% ---------------------------------------------------------------------
calvol= cfg_exbranch;
calvol.tag     = 'calvol';
calvol.name    = 'Segmentation volumes';
%calvol.val     = {data};    
calvol.val     = {idir};
calvol.help    = {'Segmentation volumes.'};
calvol.prog = @(job)cg_mantis_jobs('calvol',job);       



% ---------------------------------------------------------------------
% Batch process
% ---------------------------------------------------------------------
batchrun= cfg_exbranch;
batchrun.tag     = 'batchrun';
batchrun.name    = 'Segmentation volumes';
%batchrun.val     = {data};    
batchrun.val     = {idir};
batchrun.help    = {'Segmentation volumes.'};
batchrun.prog = @(job)cg_mantis_jobs('batchrun',job);       

p1test = cfg_phase1_tissue_classification;
mover=cfg_mantis_movetosubdir;
wscsf=cfg_mantis_ws_csf;
wmclean=cfg_mantis_wm_clean;
mantisfolderinfo = cg_mantis_phases;
deformations=cg_mantis_deformations;
% ---------------------------------------------------------------------
% mantis Adaptive-Neonatal-Brain-Segmentation
% ---------------------------------------------------------------------
job= cfg_choice;
job.tag     = 'mantis';
job.name    = 'Morphological adaptive neonatal tissue segmentation';
job.help    = {'Help needed'};
%job.values  = {segrun1 segcsf wmclean segrun2 hardlabel calvol batchrun};
job.values={p1test mover wscsf wmclean mantisfolderinfo deformations};

%-------------------------------------------------------------------------
% function dep = vout_spmrun1(job)
%dep(1)   = cfg_dep;
%dep(1).sname      = sprintf('csf');
%dep(1).src_output = substruct('.', 'files', {':'});
%dep(1).tgt_spec   = cfg_findspec({{'filter','nifti'}});
%dep(2)   = cfg_dep;
%dep(2).sname      = sprintf('White matter');
%dep(2).src_output = substruct('.', 'files', {':'});
%dep(2).tgt_spec   = cfg_findspec({{'filter','nifti'}});
%
%dep(3)   = cfg_dep;
%dep(3).sname      = sprintf('Warped Image (Deformation)');
%dep(3).src_output = substruct('.', 'files', {':'});
%dep(3).tgt_spec   = cfg_findspec({{'filter','nifti'}});
%dep(4)   = cfg_dep;
%dep(4).sname      = sprintf('Inverse Warped Image (Deformation)');
%dep(4).src_output = substruct('.', 'files', {':'});
%dep(4).tgt_spec   = cfg_findspec({{'filter','nifti'}});
% 
% 
return;