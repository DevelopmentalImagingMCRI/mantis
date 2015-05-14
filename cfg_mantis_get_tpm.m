function tpm_nam = cfg_mantis_get_tpm
tpm_nam = fullfile(char(cg_mantis_get_defaults('opts.tpm')),'firstnorm.nii');
end
