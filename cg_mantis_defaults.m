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
mantis.opts.tpm       = {fullfile(spm('dir'),'toolbox','mantis','template')}; % Template directory

% ITK code
%=======================================================================
mantis.opts.itk       = {fullfile(spm('dir'),'toolbox','mantis', 'ITK_Code', 'Code', 'Build')}; % Itk scripts

%=======================================================================
% Folder names
mantis.opts.phase1 = {'Phase1'};
mantis.opts.phase2 = {'Phase2'};

% Shell scripts
%=======================================================================
mantis.opts.scripts   = {fullfile(spm('dir'),'toolbox','mantis', 'Scripts')}; % Scripts directory


% Segmentation job
%=======================================================================
mantis.opts.segjob    = {fullfile(spm('dir'),'toolbox','mantis', 'mantis_segment_ext_job.m')}; % segment_ext job


% deformation job
%=======================================================================
mantis.opts.defjob    = {fullfile(spm('dir'),'toolbox','mantis', 'mantis_deformation_job.m')}; % deformation job


