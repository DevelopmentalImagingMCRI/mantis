function job = tbx_cfg_mantis
% Configuration file for Adoptive Neonatal Brain Segmentation
%_______________________________________________________________________
% Jian Chen
% $Id: tbx_cfg_mantis.m 7 2014-05-06 14:39:07Z chen $

addpath(fullfile(spm('dir'),'toolbox','mantis'));


p1seg = cg_phase1_tissue_classification;
% This is for phase 2. There needs to be
% a matching tag in order for jobs to run
% Thus we need a dummy entry here for the multi-subject
% version to run from inside 'finalseg'
p2seg = cg_phase1_tissue_classification;
p2seg.tag = 'phase2';
p2seg.name = 'Mantis: Phase 2 tissue classification';
mover=cg_mantis_movetosubdir;
wscsf=cg_mantis_ws_csf;
wmclean=cg_mantis_wm_clean;
mantisfolderinfo = cg_mantis_phases;
deformations=cg_mantis_deformations;
template=cg_mantis_template;
firstnorm=cg_mantis_firstnorm;
maketpm=cg_mantis_make_tpm;
finalseg=cg_mantis_second_classification;
hardseg1=cg_mantis_hardseg;
hardseg2=cg_mantis_hardseg2;

scalper = cg_mantis_scalper;
com = cg_mantis_setorigin;
% ---------------------------------------------------------------------
% mantis Adaptive-Neonatal-Brain-Segmentation
% ---------------------------------------------------------------------
job= cfg_choice;
job.tag     = 'mantis';
job.name    = 'Morphological adaptive neonatal tissue segmentation';
job.help    = {'Help needed'};
%job.values  = {segrun1 segcsf wmclean segrun2 hardlabel calvol batchrun};
job.values={p1seg mover wscsf wmclean mantisfolderinfo deformations template ...
    firstnorm maketpm p2seg finalseg hardseg1 hardseg2 scalper com};

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