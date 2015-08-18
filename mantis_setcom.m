function mantis_setcom(P, xoff, yoff, zoff)
% use center-of-mass (COM) to roughly correct for differences in the
% position between image and template

V = spm_vol(P);

% pre-estimated COM of MNI template
com_reference = [xoff yoff zoff];

Affine = eye(4);
vol = spm_read_vols(V(1));

% don't use background values
[x,y,z] = ind2sub(size(vol),find(vol>0));
com = V(1).mat(1:3,:)*[mean(x) mean(y) mean(z) 1]';
com = com';

M = spm_get_space(V(1).fname);
Affine(1:3,4) = (com - com_reference)';
spm_get_space(V(1).fname,Affine\M);

end
