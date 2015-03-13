function batch_run (idir)
%function batch_run (idir)
%Usage  
%       batch_run (idir)
%     
%
%%%%%%%%%%%%%%%%%
%Step 1: spm_run1
%%%%%%%%%%%%%%%%%
spm_segrun1(idir)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Step 2: WS csf segmentation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mkdir(idir, 'WS_seg');
WS_seg(fullfile (idir, 'spm_run1'), [idir '/WS_seg/']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Step 3: Clean white matter
%%%%%%%%%%%%%%%%%%%%%%%%%%%
mkdir(idir, 'spm_run2');
wmclean(fullfile (idir, 'spm_run1'), fullfile (idir, 'spm_run2'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Step 4: Make custom template
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
make_temp(idir);

%%%%%%%%%%%%%%%%%
%Step 5: spm_run2
%%%%%%%%%%%%%%%%%
make_temp(idir);
seg2 (idir);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Step 6: Make hard segmentation label
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
make_hard_label(idir);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Step 6: Calculte tissue volumes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
calvol(idir);


