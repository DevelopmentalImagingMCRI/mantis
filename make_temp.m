function make_temp(idir)
%function make_temp(idir)
%Make custom template of the subject

template_dir = fullfile(spm('dir'),'toolbox','ANBS', 'template');
scripts_dir = fullfile(spm('dir'),'toolbox','ANBS/', 'Scripts');
fwhm = []; % FWHM for smooth the csf map

%%%%%%%%%%%%%%
%Prepare files 
%%%%%%%%%%%%%%
CURRENTDIR = pwd;
out_dir=fullfile(idir, 'spm_run2'); 

cd (out_dir)
if ~exist(out_dir, 'dir')
    system([scripts_dir '/prepare_file_for_SPM_secondrun_each_subj.sh -t ' template_dir]);
    transf_template (out_dir)
end

%Combinding CSF segmentation from WS and csf template
system(['LD_LIBRARY_PATH=/usr/lib;' scripts_dir '/combine_spmcsf_and_segcsf_each_subj.sh -t ' template_dir]);

%%%%%%%%%%%%%%%%%%%%%%%%
%Make subject's template 
%%%%%%%%%%%%%%%%%%%%%%%%
system(['LD_LIBRARY_PATH=/usr/lib;' scripts_dir '/make_subject_template.sh  -t ' template_dir])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cd(CURRENTDIR)