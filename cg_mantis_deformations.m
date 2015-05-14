function job=cg_mantis_deformations
%% set up the template deformation job.
% a cut down version of spm_cfg_defs
hsummary = {[...
    'This is a utility for applying deformation fields to the template',...
    'used in segmentation, so that a custom template can be generated.',...
    'This version will apply a list of deformations to the same image list,'...
    'which is assumed to be components of the same image.']};

himgr = {[...
    'Deformations can be thought of as vector fields. These can be represented ',...
    'by three-volume images.']};

happly = {[...
    'Apply the resulting deformation field to some images. ']};

def          = files('Deformation Field','def','.*y_.*\.nii$',[1 Inf]);
def.help     = himgr;

applyto      = files('Apply to','fnames','image',[1 Inf]);
applyto.val  = {''};
applyto.help = happly;

saveusr      = files('Output directory','saveusr','dir',[1 1]);
saveusr.help = {['The combined deformation field and the warped images ' ...
    'are written into the specified directory.']};

interp      = cfg_menu;
interp.name = 'Interpolation';
interp.tag  = 'interp';
interp.labels = {'Nearest neighbour','Trilinear','2nd Degree B-spline',...
    '3rd Degree B-Spline ','4th Degree B-Spline ','5th Degree B-Spline',...
    '6th Degree B-Spline','7th Degree B-Spline'};
interp.values = {0,1,2,3,4,5,6,7};
interp.def  = @(val)spm_get_defaults('normalise.write.interp',val{:});
interp.help    = {
    ['The method by which the images are sampled when ' ...
    'being written in a different space. ' ...
    '(Note that Inf or NaN values are treated as zero, ' ...
    'rather than as missing data)']
    '    Nearest Neighbour:'
    '      - Fastest, but not normally recommended.'
    '    Bilinear Interpolation:'
    '      - OK for PET, realigned fMRI, or segmentations'
    '    B-spline Interpolation:'
    ['      - Better quality (but slower) interpolation' ...
    '/* \cite{thevenaz00a}*/, especially with higher ' ...
    'degree splines. Can produce values outside the ' ...
    'original range (e.g. small negative values from an ' ...
    'originally all positive image).']
    }';

conf         = exbranch('Template deformations','defs',{def,applyto,saveusr,interp});
conf.prog    = @cg_mantis_deformations_run;
conf.vout    = @vout;
conf.help    = hsummary;
job=conf;
end

function files_item = files(name, tag, fltr, num)
files_item        = cfg_files;
files_item.name   = name;
files_item.tag    = tag;
files_item.filter = fltr;
files_item.num    = num;
end
function exbranch_item = exbranch(name, tag, val)
exbranch_item      = cfg_exbranch;
exbranch_item.name = name;
exbranch_item.tag  = tag;
exbranch_item.val  = val;
end
function dep = vout(job)
% Run function is going to return the list of output names
cdep = cfg_dep;
cdep(end).sname      = 'Template deformation';
cdep(end).src_output = substruct('.','warped','()',{':'});
cdep(end).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});
dep=cdep;
end