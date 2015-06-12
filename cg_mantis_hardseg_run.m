function res = cg_mantis_hardseg_run(job)
% cg_mantis_hardseg_run performs cleanup and hard segmentation
% for phase 1, which is mostly used by phase 2
% also need a background mask

tpmcomponents = cg_mantis_get_defaults('opts.tpmcomponents');

for k=1:numel(job.vols)
    % work out the names of all the tissue maps
    tissue = char(job.vols{k});
    % structural must have a brain mask applied
    % Need to fix this when we modify the template
    structural = char(job.structural{k});
    [srcdir, corename, ext]=fileparts(tissue);
    subcorename=regexprep(corename, '^c.', '');
    for J=1:tpmcomponents,
        thistissue=['c' sprintf('%d', J) subcorename ext];
        tmap(J,:)=fullfile(srcdir, thistissue);
    end
    
    tissueV = spm_vol(tmap);
    tissueY = spm_read_vols(tissueV);
    
    % find the position of the maximum in the tissue
    % dimension
    [mxProb,mxProbIdx]=max(tissueY, [], 4);
    
    % make a brain mask from the skull stripped structural
    % and set any background voxels in the brain mask to csf
    t2=spm_vol(structural);
    t2V = 3*(spm_read_vols(t2) ~= 0);
    
    bg = mxProbIdx==tpmcomponents;
    
    mxProbIdx(find(bg)) = 0;
    
    %brainascsf = bg .* t2V;
    
    %mxProbIdx = mxProbIdx + brainascsf;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for J=1:3,
        oname=fullfile(srcdir, ['h' sprintf('%d', J) subcorename ext]);
        kk=find(mxProbIdx == J);
        n=zeros(size(mxProbIdx));
        n(kk)=J;
        v=tissueV(J);
        v.fname=oname;
        spm_write_vol(v, n);
        if (J==1)
            res.hard1{k} = oname;
        elseif (J==2)
            res.hard2{k} = oname;
        else
            res.hard3{k} = oname;            
        end
        
    end
    
end
