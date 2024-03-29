function res = cg_mantis_wm_clean_run( job )
%cg_mantis_wm_clean_run Morphological cleanup of wm
%   Calls external ITK code

% job contains the GM map from phase1 and the name of the subfolder
% that phase1 results were put in. We use that information to construct 
% an external call. 
% We use this messy method as the structural scan isn't available
% as a dependency

exedir = char(cg_mantis_get_defaults('opts.itk'));
% Do we need to do something for windows?
exe = fullfile(exedir, 'cleanWM'); 

exeprefix = char(cg_mantis_get_defaults('opts.externalcommandprefix'));
exe = [exeprefix exe];

SUFF='_csfmask'; % is this right
% We need to be able to process multiple structural scans

for k=1:numel(job.vols)
    Phase1Dir = job.parent{k};
    Phase2Dir = job.target{k};
    T2=char(job.vols{k});
    [srcdir, imname, ext]=fileparts(T2);
    WSCSF=fullfile(Phase2Dir, [imname SUFF '.nii']);
    %T2=fullfile( srcdir, [corename ext]);
    OUTNAME=fullfile(Phase2Dir, [imname '.nii']);
    command=[exe ' -i ' T2 ' -m ' WSCSF ' -o ' OUTNAME ];
    system(command);
    outnames{k}=OUTNAME;
    mantisCopyHeader(WSCSF, OUTNAME);

end


% result is the segmented csf. We need to return a structure containing
% this filename
res.wmclean = outnames;
end

