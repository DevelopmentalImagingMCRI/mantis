function out = cg_mantis_deformations_run(job)
% modified version of spm_defs to perform multiple 
% deformations of one image (template). In this function
% we loop over the list of deformations.
% looping over the images to be warped is done in apply_def
% We base the output name on the deformation image.
for k=1:numel(job.def)
    [defdir, defname, ext] = fileparts(job.def{k});
    oname=regexprep(defname, 'i*y_', '');
    oname=['atlas_' oname];
    [Def,mat] = get_def(job.def{k});
    [dpath ipath] = get_paths(job);
    out.warped{k} = apply_def(Def,mat,strvcat(job.fnames),ipath,oname, job.interp);
end
%_______________________________________________________________________

%_______________________________________________________________________
function [Def,mat] = get_def(job)
% Load a deformation field saved as an image

P      = [repmat(job{:},3,1), [',1,1';',1,2';',1,3']];
V      = spm_vol(P);
Def    = cell(3,1);
Def{1} = spm_load_float(V(1));
Def{2} = spm_load_float(V(2));
Def{3} = spm_load_float(V(3));
mat    = V(1).mat;
%_______________________________________________________________________

%_______________________________________________________________________
function [Def,mat] = get_inv(job)
% Invert a deformation field (derived from a composition of deformations)

VT          = spm_vol(job.space{:});
[Def0,mat0] = get_comp(job.comp);
M0      = mat0;
M1      = inv(VT.mat);
M0(4,:) = [0 0 0 1];
M1(4,:) = [0 0 0 1];
[Def{1},Def{2},Def{3}]    = spm_invdef(Def0{:},VT.dim(1:3),M1,M0);
mat         = VT.mat;
%_______________________________________________________________________

%_______________________________________________________________________
function [dpath,ipath] = get_paths(job)
switch char(fieldnames(job.savedir))
    case 'savepwd'
        dpath = pwd;
        ipath = pwd;
    case 'savesrc'
        dpath = get_dpath(job);
        ipath = '';
    case 'savedef'
        dpath = get_dpath(job);
        ipath = dpath;
    case 'saveusr'
        dpath = job.savedir.saveusr{1};
        ipath = dpath;
end
%_______________________________________________________________________

%_______________________________________________________________________
function dpath = get_dpath(job)
% Determine what is required, and pass the relevant bit of the
% job out to the appropriate function.

fn = fieldnames(job);
fn = fn{1};
switch fn
case {'comp'}
    dpath = get_dpath(job.(fn){1});
case {'def'}
    dpath = fileparts(job.(fn){1});
case {'dartel'}
    dpath = fileparts(job.(fn).flowfield{1});
case {'sn2def'}
    dpath = fileparts(job.(fn).matname{1});
case {'inv'}
    dpath = fileparts(job.(fn).space{1});
case {'id'}
    dpath = fileparts(job.(fn).space{1});
otherwise
    error('Unrecognised job type');
end;

%_______________________________________________________________________

%_______________________________________________________________________
function fname = save_def(Def,mat,ofname,odir)
% Save a deformation field as an image

if isempty(ofname), fname = {}; return; end;

fname = {fullfile(odir,['y_' ofname '.nii'])};
dim   = [size(Def{1},1) size(Def{1},2) size(Def{1},3) 1 3];
dtype = 'FLOAT32';
off   = 0;
scale = 1;
inter = 0;
dat   = file_array(fname{1},dim,dtype,off,scale,inter);

N      = nifti;
N.dat  = dat;
N.mat  = mat;
N.mat0 = mat;
N.mat_intent  = 'Aligned';
N.mat0_intent = 'Aligned';
N.intent.code = 'VECTOR';
N.intent.name = 'Mapping';
N.descrip = 'Deformation field';
create(N);
N.dat(:,:,:,1,1) = Def{1};
N.dat(:,:,:,1,2) = Def{2};
N.dat(:,:,:,1,3) = Def{3};
return;
%_______________________________________________________________________

%_______________________________________________________________________
function ofnames = apply_def(Def,mat,fnames, oname, odir, intrp)
% Warp an image or series of images according to a deformation field

intrp = [intrp*[1 1 1], 0 0 0];
ofnames = cell(size(fnames,1),1);

for i=1:size(fnames,1),
    V = spm_vol(fnames(i,:));
    M = inv(V.mat);
    [pth,nam,ext,num] = spm_fileparts(deblank(fnames(i,:)));
    if isempty(odir)
        % use same path as source image
        opth = pth;
    else
        % use prespecified path
        opth = odir;
    end
    ofnames{i} = fullfile(opth,[oname,ext]);
    Vo = struct('fname',ofnames{i},...
                'dim',[size(Def{1},1) size(Def{1},2) size(Def{1},3)],...
                'dt',V.dt,...
                'pinfo',V.pinfo,...
                'mat',mat,...
                'n',V.n,...
                'descrip',V.descrip);
    ofnames{i} = [ofnames{i} num];
    C  = spm_bsplinc(V,intrp);
    Vo = spm_create_vol(Vo);
    for j=1:size(Def{1},3)
        d0    = {double(Def{1}(:,:,j)), double(Def{2}(:,:,j)),double(Def{3}(:,:,j))};
        d{1}  = M(1,1)*d0{1}+M(1,2)*d0{2}+M(1,3)*d0{3}+M(1,4);
        d{2}  = M(2,1)*d0{1}+M(2,2)*d0{2}+M(2,3)*d0{3}+M(2,4);
        d{3}  = M(3,1)*d0{1}+M(3,2)*d0{2}+M(3,3)*d0{3}+M(3,4);
        dat   = spm_bsplins(C,d{:},intrp);
        Vo    = spm_write_plane(Vo,dat,j);
    end;
end;
return;

