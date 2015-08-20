function job = cg_mantis_setorigin
%cfg_mantis_ws_csf batch setup
vols         = cfg_files;
vols.tag     = 'vols';
vols.name    = 'Volumes';
vols.help    = {'This module sets the origin of an image to the centre of mass' 
    'It is designed to work with scalped neonate images. Make sure'
    'to keep a copy of the originals if you will need to reset the origin'};
vols.filter = 'image';
vols.ufilter = '.*';
vols.num     = [1 Inf];

xoffset = cfg_entry;
xoffset.tag = 'xoffset';
xoffset.name = 'offset for x axis (mm)';
xoffset.help = {'offset for the x axis relative to the COM. Default: 0'};
xoffset.strtype='r';
xoffset.num = [1 1];
xoffset.def = @(val)defxoffset(val{:});

yoffset = cfg_entry;
yoffset.tag = 'yoffset';
yoffset.name = 'offset for y axis (mm)';
yoffset.help = {'offset for the y axis relative to the COM. Default: -20'};
yoffset.strtype='r';
yoffset.num = [1 1];
yoffset.def = @(val)defyoffset(val{:});

zoffset = cfg_entry;
zoffset.tag = 'zoffset';
zoffset.name = 'offset for z axis (mm)';
zoffset.help = {'offset for the z axis relative to the COM. Default: 15'};
zoffset.strtype='r';
zoffset.num = [1 1];
zoffset.def = @(val)defzoffset(val{:});

job         = cfg_exbranch;
job.tag     = 'setorigin';
job.name    = 'Origin to COM';
job.val     = {vols, xoffset, yoffset, zoffset};
job.help    = {
    'Segmentation of structural image using the watershed transform. GM and CSF prob maps are used'
    };
job.prog = @cg_mantis_setorigin_run;
job.vout = @vout;

end

function dep = vout(job)
% The output of this job is always the same

cdep = cfg_dep;
cdep(end).sname      = 'Set origin';
cdep(end).src_output = substruct('.','setorigin','()',{':'});
cdep(end).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});

dep=cdep;

end

function p = defxoffset(varargin)
p=0;
end

function p = defyoffset(varargin)
p=-20;
end

function p = defzoffset(varargin)
p=15;
end

