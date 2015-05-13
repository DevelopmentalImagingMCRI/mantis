function mantisCopyHeader(template, target)
% Copy the header from the template to the target image.

templatespace = spm_get_space(template);
spm_get_space(target, templatespace);
end
