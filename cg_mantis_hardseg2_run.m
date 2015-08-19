function res = cg_mantis_hardseg2_run(job)
    % cg_mantis_hardseg_run performs cleanup and hard segmentation
    % dependencies will provide 1 tissue map, and we might
    % also need a background mask
    
    tpmcomponents = cg_mantis_get_defaults('opts.tpmcomponents');

for k=1:numel(job.vols)
    % work out the names of all the tissue maps
    tissue = char(job.vols{k});
    % structural must have a brain mask applied
    % Need to fix this when we modify the template
    structural = char(job.structural{k});
    [srcdir, corename, ext]=fileparts(tissue);
    ext=regexprep(ext, ',\d$', '');
    subcorename=regexprep(corename, '^c.', '');
    for J=1:tpmcomponents,
        thistissue=['c' sprintf('%d', J) subcorename ext];
        tmap(J,:)=fullfile(srcdir, thistissue);
    end
    oname = fullfile(srcdir, ['hard' subcorename ext]); 
    % construct names of the hard segmentations
    hseg = char(job.hardseg1{k});
    [hsrcdir, hcorename, hext]=fileparts(hseg);
    hext=regexprep(hext, ',\d$', '');
    hsubcorename=regexprep(hcorename, '^h.', '');
    for J=1:3,
        thishard=['h' sprintf('%d', J) hsubcorename hext];
        hmap(J,:)=fullfile(hsrcdir, thishard);
    end

    tissueV = spm_vol(tmap);
    tissueY = spm_read_vols(tissueV);
    clear tmap;
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
 
    % previous bit is same as phase 1 hardseg - could refactor
    % Assumes that the ordering in the template is the same
    
    % load the phase 1 hard segmentations
    hardV = spm_vol(hmap);
    hardY = spm_read_vols(hardV);
    clear hmap;
    % phase 2 - replace phase2 gm voxels that were wm in phase 1
    % with wm - these correspond to isolated bits of wm
    % find voxels that were wm in phase 1, but not phase 2.
    hardwhite2 = (mxProbIdx == 2);
    hardwhite1 = (hardY(:,:,:,2)>0.5);
    
    hwdiff = hardwhite1 & (~hardwhite2);
    clearvars hardwhite1;
    % find voxels that were gm in phase 2 but not phase 1
    hardgrey2 = (mxProbIdx == 1);
    hardgrey1 = (hardY(:,:,:,1)>0.5);
    gmdiff = hardgrey2 & (~hardgrey1);
    
    clearvars hardgrey1;
   
    g2white = gmdiff & hwdiff;
    
    % similar kind of thing with csf
    hardcsf2 = (mxProbIdx == 3);
    hardcsf1 = (hardY(:,:,:,3)>0.5);
    
    csfdiff = hardcsf1 & (hardcsf2==0);
    clearvars hardcsf1;
    
    g2csf = gmdiff & csfdiff;
    % now to correct the gm and wm channel
    
    hardgrey2 = hardgrey2 & (~(g2csf | g2white));
    hardwhite2 = hardwhite2 | g2white;
    hardcsf2 = hardcsf2 | g2csf;

    % Now we do more fixing of other WM error by using the largest
    % components
    % why do we do the fixing of wm above, which is caused by resetting
    % brightness if we are going to delete isolated parts?
    [whitelab, whitecc] = spm_bwlabel(double(hardwhite2), 6);
    % doesn't appear to be nice connected component analysis tool in spm
    % some other spm functions use this approach
    ccs = histc(whitelab(:),(0:whitecc) + 0.5);
    ccs = ccs(1:end-1);
    % peak in this histogram should be the biggest object
    totalwm = sum(hardwhite2(:));
    % we want the largest one or two wm components. Take the largest 2
    % if the biggest is less than 0.75 of total wm.
    [biggest, bigIdx] = max(ccs);
    largestwhite = (whitelab == bigIdx);
    if (biggest < 0.75 * totalwm),
        ccs(bigIdx)=0;
        [biggest2, bigIdx2] = max(ccs);
        largestwhite = largestwhite | (whitelab == bigIdx2);
    end
    g=hardV(1);
    % combine the results into a single hard segmentation image
    % we've only fiddled with labels 1,2,3, so get rid of the original
    % versions of these from mxProbIdx and replace with the new ones

    mxProbIdx(find(mxProbIdx <= 3))=0;
    mxProbIdx(find(hardcsf2))=3;
    mxProbIdx(find(largestwhite))=2;
    mxProbIdx(find(hardgrey2))=1;
    
    % bits of white we've ditched become csf
    mxProbIdx(find(hardwhite2 & (~largestwhite)))=3;
    % finally save
    outvol = hardV(1);
    outvol.fname=oname;
    outvol.pinfo(1)=1;
    outvol.pinfo(2)=0;
    
    spm_write_vol(outvol,mxProbIdx);
    res.hard{k} = oname;
end

end
