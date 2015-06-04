function res = cg_mantis_make_tpm_run( job )
%cfg_mantis_ws_run Watershed segmentation of csf using phase1 tissue maps
%   Calls external ITK code

% job contains the GM map from phase1 and the name of the subfolder
% that phase1 results were put in. We use that information to construct 
% an external call. 
% We use this messy method as the structural scan isn't available
% as a dependency

%Phase1Dir = job.parent{1}
%Phase2Dir = char(cg_mantis_get_defaults('opts.phase2'));
%SUFF='WSCSF'; % is this right
% We need to be able to process multiple structural scans
tpmcomponents = cg_mantis_get_defaults('opts.tpmcomponents');

for k=1:numel(job.vols)
    Phase1Dir = job.parent{k};
    Phase2Dir = job.target{k};

    T2=char(job.vols{k});
    [srcdir, corename, ext]=fileparts(T2);
    
    %TPM=char(job.vols{k});
     
    TPM=fullfile( Phase2Dir, ['atlas_' corename ext]);
    Vtpm=spm_vol(TPM);
    
    numt = length(Vtpm)-1;
    
    %Tissues other than CSF
    Vtis = Vtpm(1:numt);
    [Ytis, XZY]=spm_read_vols(Vtis);
    
    %Brain edge
    Vbes = Vtpm(end);
    [Ybes, XZY]=spm_read_vols(Vbes);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    %Load spm csf segmentation
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    SPMCSF=fullfile( Phase1Dir, ['c3' corename ext]);
    Vspmcsf = spm_vol(SPMCSF);
    [Yspmcsf, XZY]=spm_read_vols(Vspmcsf);
    
    Ycsfcom = Ybes.*Yspmcsf; 
            
    %Load WS csf segmentation
    WSCSF = fullfile(Phase2Dir, [corename '_csfmask.nii']);
    Vwscsf = spm_vol(WSCSF);
    [Ywscsf, XZY]=spm_read_vols(Vwscsf);
    
    Ycsfcom(:,:,:,2)=Ywscsf;
    Ycsf=squeeze(max(Ycsfcom, [], 4));
      
    %Put CSF to tissue map at position number 3        
    YtisN = Ytis;
    YtisN(:,:,:,3)=Ycsf;
    YtisN(:,:,:,4:tpmcomponents) = Ytis(:,:,:,3:numt);
    Ytis=YtisN;
    clearvars YtisN;
    %Normalise tissues
    Ysum=sum(Ytis,4);
        
    Vo = Vtpm;
    for i = 1:numt+1
        Ytisnorm(:,:,:,i) = Ytis(:,:,:,i)./Ysum;
        %Vo(i).fname = ['norm_' num2str(i) '_' Vtpm(i).fname ];
        % only copy the first one so the offsets are OK for different
        % images
        Vv = Vtpm(1);
        Vv.fname = fullfile(Phase2Dir, ['norm_atlas_' num2str(i) '_' corename ext]);
        Vo(i) = spm_write_vol(Vv,squeeze(Ytisnorm(:,:,:,i)));
    end
    
    fname = fullfile(Phase2Dir, ['norm_atlas_' corename ext]);
    V4 = spm_file_merge(Vo,fname,0);

    for i = 1:numt+1
        delete(Vo(i).fname);
    end
    clear Ytisnorm;
    outnames{k}=fname;
    %These bits need to be cleaned up if we return channel information
%     for j=1:tpmcomponents
%         subtissuemap{k}{j}=[fname ',' sprintf('%d',j)];
%    end
end    

% result is the segmented csf. We need to return a structure containing
% this filename
res.tissuemap = outnames;
%res.subtissuemap = subtissuemap;

end

