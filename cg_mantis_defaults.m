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
mantis.opts.tpm2       = {fullfile(spm('dir'),'toolbox','mantis','template', 'Firstnorm.nii')}; % Template directory
mantis.opts.tpm2components = 8;

% BrainEdge
%=======================================================================
mantis.opts.tpm2d       = {fullfile(spm('dir'),'toolbox','mantis','template')}; % Template directory
mantis.opts.tpm2       = {fullfile(spm('dir'),'toolbox','mantis','template', 'BrainEdge.nii')}; % Template directory
mantis.opts.tpm2components = 1;

% ITK code
%=======================================================================
mantis.opts.itk       = {fullfile(spm('dir'),'toolbox','mantis', 'ITK_Code', 'Code', 'Build')}; % Itk scripts

%=======================================================================
% Folder names
mantis.opts.phase1 = {'Phase1'};
mantis.opts.phase2 = {'Phase2'};
mantis.opts.phase3 = {'Phase3'};


% Shell scripts
%=======================================================================
mantis.opts.scripts   = {fullfile(spm('dir'),'toolbox','mantis', 'Scripts')}; % Scripts directory


% Segmentation job
%=======================================================================
mantis.opts.segjob    = {fullfile(spm('dir'),'toolbox','mantis', 'mantis_segment_ext_job.m')}; % segment_ext job


% deformation job
%=======================================================================
mantis.opts.defjob    = {fullfile(spm('dir'),'toolbox','mantis', 'mantis_deformation_job.m')}; % deformation job


