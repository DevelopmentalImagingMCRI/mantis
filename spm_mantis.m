function spm_mantis
% MANTIS Toolbox wrapper to call MANTIS functions
%_______________________________________________________________________
% Jian Chen

rev = '$Rev: 1 $';

SPMid = spm('FnBanner',mfilename,rev);
[Finter,Fgraph,CmdLine] = spm('FnUIsetup','mantis');
spm_help('!ContextHelp',mfilename);
spm_help('!Disp','mantis.man','',Fgraph,'   mantis toolbox for SPM8');


% pathnames
q=char(39); % to make it easier getting quotes into the strings
segjob= char(cg_mantis_get_defaults('opts.mainpipeline'));
segjobcom=['spm_jobman(' q 'interactive' q ',' q segjob q ');'];

fig = spm_figure('GetWin','Interactive');
h0  = uimenu(fig,...
	'Label',	'mantis',...
	'Separator',	'on',...
	'Tag',		'mantis',...
	'HandleVisibility','on');
h1  = uimenu(h0,...
	'Label',	'SPM Segmentation phase 1 ',...
	'Separator',	'off',...
	'Tag',		'SPM Segmentation phase 1',...
	'CallBack',segjobcom,...
	'HandleVisibility','on');
