function res = cg_mantis_make_csf_mask_run( job )
%cfg_mantis_ws_run Watershed segmentation of csf using phase1 tissue maps
%   Calls external ITK code

% job contains the GM map from phase1 and the name of the subfolder
% that phase1 results were put in. We use that information to construct
% an external call.
% We use this messy method as the structural scan isn't available
% as a dependency

%Phase2Dir = char(cg_mantis_get_defaults('opts.phase2'));
% Suffix used by segCSF
SUFF='_csfmask';
% We need to be able to process multiple structural scans
for k=1:numel(job.vols)
    Phase1Dir = job.parent{k};
    Phase2Dir = job.target{k};
    structfile=char(job.vols{k});
    [srcdir, corename, ext]=fileparts(structfile);
    ext=regexprep(ext, ',\d$','');
    T2=fullfile( srcdir, [corename ext]);
    CSF=fullfile( Phase1Dir, ['c3' corename ext]);
    GM=fullfile( Phase1Dir, ['c1' corename ext]);
    OUTPREF=fullfile(Phase2Dir, corename);
    outnames{k}=fullfile(Phase2Dir, [corename SUFF ext]);
    % load the csf file, threshold it, filter small objects and save.
    % Threshold hardcoded for now
    csfV = spm_vol(CSF);
    csfVol = spm_read_vols(csfV(1)) > 0.9;
    vxsz = abs(det(csfV.mat));
    % remove any component smaller than 500mm^3
    % This is done when generating markers for watershed
    csfVol = mantis_attribute_filter(csfVol, 500/vxsz);
    csfmaskV = csfV;
    csfmaskV.fname = outnames{k};
    spm_write_vol(csfmaskV, csfVol);
    %mantisCopyHeader(CSF, outnames{k});
    T2names{k}=T2;
end



% result is the segmented csf. We need to return a structure containing
% this filename
res.csfseg = outnames;
res.structural=T2names;
end

