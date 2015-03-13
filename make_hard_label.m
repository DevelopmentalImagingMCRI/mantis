function make_hard_label (idir)
%function make_hard_label (idir)

scripts_dir = fullfile(spm('dir'),'toolbox','ANBS/', 'Scripts');

%Make hard segmentation label for spm run1
system(['LD_LIBRARY_PATH=/usr/lib;' scripts_dir '/make_hardseg_each_subj_run1.sh -d ' idir]); 

%Make hard segmentation label for spm run2
system(['LD_LIBRARY_PATH=/usr/lib;' scripts_dir '/make_hardseg_each_subj_run2.sh -d ' idir]); 