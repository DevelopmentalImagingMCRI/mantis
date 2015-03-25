function cfg_mantis_movetosubdir_run(job)
% need to loop over every file
% job should have files and subfolder

subfolder = job.subfolder{1}

for k=1:numel(job.files)
    disp(job.files{k})
end

end