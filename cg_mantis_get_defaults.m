function varargout = cg_mantis_get_defaults(defstr, varargin)
% Get/set the defaults values associated with an identifier
% FORMAT defval = cg_mantis_get_defaults(defstr)
% Return the defaults value associated with identifier "defstr". 
% Currently, this is a '.' subscript reference into the global  
% "defaults" variable defined in spm_defaults.m.
%
% FORMAT cg_mantis_get_defaults(defstr, defval)
% Sets the mantis value associated with identifier "defstr". The new
% mantis value applies immediately to:
% * new modules in batch jobs
% * modules in batch jobs that have not been saved yet
% This value will not be saved for future sessions of SPM. To make
% persistent changes, edit cg_mantis_defaults.m.
%__________________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging

% based on Volkmar Glauches version of
% spm_get_defaults
% $Id: cg_mantis_get_defaults.m 404 2011-04-11 10:03:40Z gaser $

global mantis;
if isempty(mantis)
    cg_mantis_defaults;
end

% construct subscript reference struct from dot delimited tag string
tags = textscan(defstr,'%s', 'delimiter','.');
subs = struct('type','.','subs',tags{1}');

if nargin == 1
    varargout{1} = subsref(mantis, subs);
else
    mantis = subsasgn(mantis, subs, varargin{1});
end
