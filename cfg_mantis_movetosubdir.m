function job = cfg_mantis_movetosubdir
% modified version of the basicio tools that moves files to a subfolder,
% creating the folder if necessary. Can't see a way to do this with
% the existing tools.
files         = cfg_files;
files.tag     = 'files';
files.name    = 'Files to move';
files.help    = {'These files will be moved.'};
files.filter = 'any';
files.ufilter = '.*';
files.num     = [0 Inf];

subfolder         = cfg_entry;
subfolder.tag     = 'subfolder';
subfolder.name    = 'subfolder';
subfolder.help    = {'The subfolder.'};
subfolder.strtype = 's';
subfolder.num     = [1  Inf];

file_move         = cfg_exbranch;
file_move.tag     = 'file_move';
file_move.name    = 'Move/Delete Files';
file_move.val     = {files subfolder };
file_move.help    = {'Move files to subfolder.'};
file_move.prog = @cfg_mantis_movetosubdir_run;
% Outputs are new locations
file_move.vout = @cfg_mantis_movetosubdir_vout;
job=file_move;
end
