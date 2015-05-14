# MANTis
========

The morphogical adaptive neonate tissue segmentation toolbox for spm.

Design goals:

Where possible, make it look like "native" spm. When using existing
functionality, like new segment, call the existing function to create
the objects and modify them as required.

This means we can use the existing vout callbacks and run functions.

Phase 1:

cfg_phase1_tissue_classification.m - calls tbx_cfg_preproc8 and
replaces the tissue component.


Creating sub folders: 

Need a folder creator that can use dependencies