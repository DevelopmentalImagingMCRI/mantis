function res = cg_mantis_setorigin_run( job )
%cfg_mantis_ws_run Watershed segmentation of csf using phase1 tissue maps
%   Calls external ITK code

% job contains the GM map from phase1 and the name of the subfolder
% that phase1 results were put in. We use that information to construct 
% an external call. 
% We use this messy method as the structural scan isn't available
% as a dependency

% We need to be able to process multiple structural scans
for k=1:numel(job.vols)
    xoff = job.xoffset;
    yoff = job.yoffset;
    zoff = job.zoffset;
    
    structfile=char(job.vols{k});
    [srcdir, corename, ext]=fileparts(structfile);

    T2=fullfile( srcdir, [corename ext]);

    mantis_setcom(T2, xoff, yoff, zoff);
    
    T2names{k}=T2;
end



% result is the segmented csf. We need to return a structure containing
% this filename
res.setorigin=T2names;
end
