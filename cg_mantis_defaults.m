function cg_mantis_defaults
% Sets the defaults for MANTIS
% FORMAT cg_mantis_defaults
%_______________________________________________________________________
%
% This file is intended to be customised for the site.
%
% Care must be taken when modifying this file
%_______________________________________________________________________
% $Id: cg_mantis_defaults.m 

global mantis

% Template
%=======================================================================
mantis.opts.tpmd       = {fullfile(spm('dir'),'toolbox','mantis','template')}; % Template directory
mantis.opts.tpm       = {fullfile(spm('dir'),'toolbox','mantis','template', 'NeonateTPM.nii')}; % Template directory
mantis.opts.tpmcomponents = 9;

% Firstnorm
%=======================================================================
mantis.opts.tpm2d       = {fullfile(spm('dir'),'toolbox','mantis','template')}; % Template directory
mantis.opts.tpm2       = {fullfile(spm('dir'),'toolbox','mantis','template', 'FirstnormB.nii')}; % Template directory
mantis.opts.tpm2components = 9;

% ITK code
%=======================================================================
mantis.opts.itk       = {fullfile(spm('dir'),'toolbox','mantis', 'ITKStuff', ...
    ['Build.' computer], 'MANTiS-build', 'bin')}; % Itk binaries

%=======================================================================
% Folder names
mantis.opts.phase1 = {'Phase1'};
mantis.opts.phase2 = {'Phase2'};

%=======================================================================
% Smoothing of CSF for stage 2 atlas
mantis.opts.csfsmooth = 7;
% Predefined pipelines
spmversion=spm('Ver');
if strcmp(spmversion, 'SPM12')
    mantis.opts.mainpipeline = fullfile(spm('dir'),'toolbox','mantis','mantis_complete_segmentation12.m');
    mantis.opts.mainpipelinesimple = fullfile(spm('dir'),'toolbox','mantis','mantis_complete_segmentation_simplecsf_spm12.m');
else
    mantis.opts.mainpipeline = fullfile(spm('dir'),'toolbox','mantis','mantis_complete_segmentation8.m');
end
