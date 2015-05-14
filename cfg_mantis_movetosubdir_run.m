function cfg_mantis_movetosubdir_run(job)
% need to loop over every file
% job should have files and subfolder

subfolder = job.subfolder;

for k=1:numel(job.files)
    disp(job.files{k})
    [pathstr,name,ext] = fileparts(char(job.files{k}));
    [success,message,messageid] = mkdir(pathstr,subfolder);
    if ~success 
      warning(['Error creating folder ' subfolder]);
    end

    [mvsuccess,mvmessage,mvmessageid] = movefile(char(job.files{k}),fullfile(pathstr, subfolder));
    if ~mvsuccess
	warning(['Error moving file ' char(job.files{k})]);
    end
end

end
