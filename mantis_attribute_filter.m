function newvol = mantis_attribute_filter(volume, vthresh)
   [Labelled, comps] = spm_bwlabel(cast(volume, 'double'));
    
    ncl = histc(Labelled(:),[1:comps])';
    incl = find(ncl < vthresh);
    newvol = volume;
    if ~isempty(incl)
        tochange = ismember(Labelled, incl);
        newvol(tochange) = 0;
    end
end