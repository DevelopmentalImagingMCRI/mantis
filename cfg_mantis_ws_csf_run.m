function res = cfg_mantis_ws_csf_run( job )
%cfg_mantis_ws_run Watershed segmentation of csf using phase1 tissue maps
%   Calls external ITK code

% job contains the structural scan and the name of the subfolder that 
% phase1 results were put in. We use that information to construct 
% an external call.

exedir = char(cg_mantis_get_defaults('opts.itk'));
% Do we need to do something for windows?
exe = fullfile(exedir, 'segCSF'); 

Phase1Dir = job.parent{1}
Phase2Dir = cg_mantis_get_defaults('opts.phase2');
SUFF='wscsf'; % is this right
% We need to be able to process multiple structural scans
for k=1:numel(job.vols)
    thisfile=char(job.vols{k});
    [srcdir, imname, ext]=fileparts(thisfile);
    GM=fullfile(srcdir, Phase1Dir, ['c1' imname ext]);
    CSF=fullfile(srcdir, Phase1Dir, ['c3' imname ext]);
    OUTPREF=fullfile(srcdir, Phase2Dir, imname);
    command=[exe ' --input ' thisfile ' --csf ' CSF ' --grey ' GM ' --output ' OUTPREF];
    outnames{k}=fullfile(OUTPREF, Phase2Dir, [imname SUFF ext]);
end


% result is the segmented csf. We need to return a structure containing
% this filename
res.csfseg = outnames;
end

