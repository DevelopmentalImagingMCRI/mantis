function job = cfg_phase1_tissue_classification

%% call the newsegment job creator
try
    % spm12
    newsegmentjob=spm_cfg_preproc8;
catch
    % spm 8
    newsegmentjob=tbx_cfg_preproc8;
end    
%% Change the tissue maps

%fslmerge -t NeonateTPM /tmp/spm8/toolbox/ANBS/template/cortex.nii
%/tmp/spm8/toolbox/ANBS/template/wm.nii
%/tmp/spm8/toolbox/ANBS/template/csf.nii
%/tmp/spm8/toolbox/ANBS/template/deepgreymatter_map.nii
%/tmp/spm8/toolbox/ANBS/template/hippocampus_map.nii
%/tmp/spm8/toolbox/ANBS/template/amygdala_map.nii
%/tmp/spm8/toolbox/ANBS/template/cerebellum.nii
%/tmp/spm8/toolbox/ANBS/template/brainstem.nii
%/tmp/spm8/toolbox/ANBS/template/background.nii

%% This bit from spm new segment - we're replacing the
% tissue maps with ours. The first bits
% are efectively field definitions.

tpm         = cfg_files;
tpm.tag     = 'tpm';
tpm.name    = 'Tissue probability map';
tpm.filter = 'image';
tpm.ufilter = '.*';
tpm.num     = [1 1];

ngaus         = cfg_menu;
ngaus.tag     = 'ngaus';
ngaus.name    = 'Num. Gaussians';
ngaus.labels = {
                '1'
                '2'
                '3'
                '4'
                '5'
                '6'
                '7'
                '8'
                'Nonparametric'
                }';
ngaus.values = {
                1
                2
                3
                4
                5
                6
                7
                8
                Inf
                }';
ngaus.val    = {Inf};
native         = cfg_menu;
native.tag     = 'native';
native.name    = 'Native Tissue';
native.labels = {
                 'None'
                 'Native Space'
                 'DARTEL Imported'
                 'Native + DARTEL Imported'
                 }';
native.values = {
                 [0 0]
                 [1 0]
                 [0 1]
                 [1 1]
                 }';
native.val    = {[1 0]};
% ---------------------------------------------------------------------
% warped Warped Tissue
% ---------------------------------------------------------------------
warped         = cfg_menu;
warped.tag     = 'warped';
warped.name    = 'Warped Tissue';
warped.labels = {
                 'None'
                 'Modulated'
                 'Unmodulated'
                 'Modulated + Unmodulated'
                 }';
warped.values = {
                 [0 0]
                 [0 1]
                 [1 0]
                 [1 1]
                 }';
warped.val    = {[0 0]};



tissue         = cfg_branch;
tissue.tag     = 'tissue';
tissue.name    = 'Tissue';
tissue.val     = {tpm ngaus native warped };
tissue.help    = {'A number of options are available for each of the tissues.  You may wish to save images of some tissues, but not others. If planning to use DARTEL, then make sure you generate ``imported'''' tissue class images of grey and white matter (and possibly others).  Different numbers of Gaussians may be needed to model the intensity distributions of the various tissues.'};

tissues         = cfg_repeat;
tissues.tag     = 'tissues';
tissues.name    = 'Tissues';
tissues.values  = {tissue };
tissues.num     = [0 Inf];

tissues.val     = {tissue tissue tissue tissue tissue tissue };
tpm_nam = fullfile(char(cg_mantis_get_defaults('opts.tpm')),'NeonateTPM.nii');
ngaus   = [2 2 2 2 2 2 2 2 2];
nval    = {[1 0],[1 0],[1 0],[1 0],[1 0],[1 0],[1 0],[1 0],[1 0]};
for k=1:numel(ngaus),
    tissue.val{1}.val{1} = {[tpm_nam ',' num2str(k)]};
    tissue.val{2}.val    = {ngaus(k)};
    tissue.val{3}.val    = {nval{k}};
    tissues.val{k}       = tissue;
end

% replace the original tissue maps
newsegmentjob.val{2}=tissues;

newsegmentjob.tag = 'phase1';
newsegmentjob.name = 'Mantis: Phase 1 tissue classification';
%job.val={data matlabbatch};
newsegmentjob.help = {['This is the standard spm8 new segment with a custom ' ...
             'neonate template.']};

job=newsegmentjob;
end
%% Local Functions
%% We're using the ones provided in spm8 for this

