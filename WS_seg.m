function WS_seg (root_dir, out_dir)
%function WS_seg (root_dir, out_dir)

ITKdir = fullfile(spm('dir'),'toolbox','ANBS/ITK_Code/Code/Build/');

csf = spm_select('FPList',root_dir,'^c3.*\.nii$');
grey = spm_select('FPList',root_dir,'^c1.*\.nii$');

inputTem  = spm_select('List',root_dir,'^c1.*\.nii$');
filestem = inputTem (3:end);
inputImg =fullfile(root_dir, filestem);

outputprefix = fullfile (out_dir, filestem(1:end-4));

system(['LD_LIBRARY_PATH=/usr/lib; ' ITKdir '/segCSF -i ' inputImg ' --csf ' csf ' --grey ' grey ' --outputprefix ' outputprefix])
