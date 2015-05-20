function dep = cg_mantis_movetosubdir_vout(job)

dep = cfg_dep;
dep.sname = 'Moved files';
dep.src_output = substruct('.', 'files');
dep.tgt_spec = cfg_findspec({{'class', 'cfg_files', 'strtype', 'e'}});

end

