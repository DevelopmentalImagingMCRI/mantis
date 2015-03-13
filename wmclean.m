function wmclean (idir, flag)
%function wmclean (input_dir, out_dir, flag)
%input_dir: input directory, flag=1, WS_seg; flag=2 spm_run1
%out_dir: output directory spm_run2
%flag: 1 using WS_sge output; 2 using spm_run1 output

if nargin < 2
    flag =1 
end

template_dir = fullfile(spm('dir'),'toolbox','ANBS', 'template');
ITK_dir = fullfile(spm('dir'),'toolbox','ANBS/ITK_Code/Code/Build/');
scripts_dir = fullfile(spm('dir'),'toolbox','ANBS/', 'Scripts');

%Prepare spm_run2 files
CURRENTDIR = pwd;
cd ([idir '/spm_run2'])
system([scripts_dir '/prepare_file_for_SPM_secondrun_each_subj.sh -t ' template_dir]);
cd (CURRENTDIR)

input_dir = fullfile (idir, 'spm_run1');
out_dir = fullfile (idir, 'spm_run2')
WS_dir = fullfile (idir, 'WS_seg')

%Transfer_template to subject space
transf_template (out_dir)

%Do white matter clean
inputTem  = spm_select('List',input_dir,'^c1.*\.nii$');
filestem = inputTem (3:end-4);
inputImg = fullfile(input_dir, filestem);
maskImg = fullfile(WS_dir, [filestem '_csfmask.nii.gz'])
outputfile = fullfile (out_dir, [filestem '.nii']);

if flag == 1
    system(['LD_LIBRARY_PATH=/usr/lib;' ITK_dir '/cleanWM -i ' inputImg ' -m ' maskImg ' -o ' outputfile])
else 
    csf = spm_select('FPList',input_dir,'^c3.*\.nii$');
    grey = spm_select('FPList',input_dir,'^c1.*\.nii$');
    inputTem  = spm_select('List',input_dir,'^c1.*\.nii$');
    filestem = inputTem (3:end); 
    inputImg =fullfile(input_dir, filestem);
    system(['LD_LIBRARY_PATH=/usr/lib;' ITK_dir '/cleanWM --prefix ' filestem ' --templatecsf ' out_dir '/wtemplate_csf.nii  --csf ' csf  ' -i ' inputImg  ' -o ' outputfile])
end