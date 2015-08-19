function res = cg_mantis_scalper_run( job )
%cfg_mantis_scalper_run Simple scalper of neonate T2 scan
%   Calls external ITK code

exedir = char(cg_mantis_get_defaults('opts.itk'));
% Do we need to do something for windows?
exe = fullfile(exedir, 'neonateScalper'); 


% We need to be able to process multiple structural scans
for k=1:numel(job.vols)
    prefix = job.scalperprefix;
 
    structfile=char(job.vols{k});
    [srcdir, corename, ext]=fileparts(structfile);
    % get rid of the ,1 at the end of the filename
    ext=regexprep(ext, ',\d$','');
    T2=fullfile( srcdir, [corename ext]);
    
    OUTPREF=fullfile(srcdir, [prefix corename ext]);
    command=[exe ' --input ' T2  ' --output ' OUTPREF];
    system(command);
    outnames{k}=OUTPREF;
    mantisCopyHeader(T2, outnames{k});
    T2names{k}=T2;
end



% result is the segmented csf. We need to return a structure containing
% this filename
res.scalped = outnames;
res.structural=T2names;
end
