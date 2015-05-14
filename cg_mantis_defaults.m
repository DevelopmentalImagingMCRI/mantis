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
mantis.opts.itk       = {fullfile(spm('dir'),'toolbox','mantis', 'ITKStuff', ...
    'Code', ['Build' computer], 'MANTiS-build', 'bin')}; % Itk binaries

% Shell scripts
%=======================================================================
mantis.opts.scripts   = {fullfile(spm('dir'),'toolbox','mantis', 'Scripts')}; % Scripts directory


% Segmentation job
%=======================================================================
mantis.opts.segjob    = {fullfile(spm('dir'),'toolbox','mantis', 'segment_ext_job.m')}; % segment_ext job


% deformation job
%=======================================================================
mantis.opts.defjob    = {fullfile(spm('dir'),'toolbox','mantis', 'deformation_job.m')}; % deformation job


