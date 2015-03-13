function calvol (idir)
%function calvol (idir)

scripts_dir = fullfile(spm('dir'),'toolbox','ANBS/', 'Scripts');
seg_dir = fullfile(idir, 'spm_run2')
system(['LD_LIBRARY_PATH=/usr/lib;' scripts_dir '/calc_spm_seg_vol.sh -d ' seg_dir]);
