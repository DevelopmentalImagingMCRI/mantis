function res = cfg_mantis_ws_csf_run( job )
%cfg_mantis_ws_run Watershed segmentation of csf using phase1 tissue maps
%   Calls external ITK code

% job contains the GM map from phase1 and the name of the subfolder
% that phase1 results were put in. We use that information to construct 
% an external call. 
% We use this messy method as the structural scan isn't available
% as a dependency

exedir = char(cg_mantis_get_defaults('opts.itk'));
% Do we need to do something for windows?
exe = fullfile(exedir, 'segCSF'); 

Phase1Dir = job.parent{1}
Phase2Dir = char(cg_mantis_get_defaults('opts.phase2'));
SUFF='csfmask'; % is this right
% We need to be able to process multiple structural scans
for k=1:numel(job.vols)
    GMfile=char(job.vols{k});
    [srcdir, imname, ext]=fileparts(GMfile);
    corename=imname;
    %ext=ext(1:end-2);
    T2=fullfile( srcdir, [corename ext]);
    CSF=fullfile( Phase1Dir, ['c3' corename ext]);
    GM=fullfile( Phase1Dir, ['c1' corename ext]);
    OUTPREF=fullfile(srcdir, Phase2Dir, corename);
    command=[exe ' --input ' T2 ' --csf ' CSF ' --grey ' GM ' --outputprefix ' OUTPREF];
    system(command);
    outnames{k}=fullfile(srcdir, Phase2Dir, [corename SUFF ext]);
    T2names{k}=T2;
end



% result is the segmented csf. We need to return a structure containing
% this filename
res.csfseg = outnames;
res.structural=T2names;
end

