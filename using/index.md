---
layout: default
title: Using mantis
---
<br>
<section class="content">
## Preliminaries

MANTiS is designed to process brain extracted T2 weighted images that are in the same orientation
as the template. Orientation in this case doesn't imply that the new image and template
should be registered - simply that the data ordering is the same. We use the _fslswapdim_ tool
to control data ordering.

Brain extraction for the MANTiS validation studies were carried out using FSL _BET_. There
is also a [preliminary tool](extraction) in MANTiS to perform brain extraction.

Finally, as with typical SPM segmentation, the origins of the image need to be roughly equivalent
to the template. There is a [tool in MANTiS](origin) to set the origin based on the centre of mass. This
tool should also be applied to brain extracted images.

##Getting started

MANTiS is an SPM toolbox and can be accessed as follows.

1. Select mantis from the toolbox dropdown menu:
![mantis from toolbox menu](https://github.com/DevelopmentalImagingMCRI/mantis/raw/master/Instructions/mantis_toolbox_menu.png)
1. Select the complete pipeline option to load the pipeline in the batch editor.
![mantis from local menu](https://github.com/DevelopmentalImagingMCRI/mantis/raw/master/Instructions/mantis_menu2.png)
1. Select scalped T2 structural scans from the batch editor file selection:
![mantis from batch](https://github.com/DevelopmentalImagingMCRI/mantis/raw/master/Instructions/mantis_file_selection.png)
1. Click the green run button, and wait. The results for each phase will be stored in two folders, named Phase1 and Phase2.
1. The components from which the pipeline is constructed are available from the batch editor tools menu.

## Brain Extraction
[A preliminary tool:](extraction) is available for brain extraction in
T2 weighted images.

## Setting image origin
SPM segmentation utilises the image origin from the nifti files if it
is set on the assumption that is positioned similarly to the origin of
standard space. Strange results can occur if this isn't the
case. [A tool for setting image origin:](origin) based on the centre
of mass of the brain is available. It should be applied to brain
extracted images.

# Complete pipeline
A pipeline performing brain extraction and origin setting can be
constructed in the batch editor as per the image below:
![mantis complete pipeline](https://github.com/DevelopmentalImagingMCRI/mantis/raw/master/Instructions/mantis_complete.png)

# Changing templates
The template image used by mantis is specified in a defaults file: *mantis/cg\_mantis\_defaults.m*
A custom template can be used by changing the *mantis.opts.tpm* and *mantis.opts.tpm2*
variables in this file to reference your own template. The components
of the custom template must match those in the original (at least for
gray, white and csf tissue classes), and changes will affect all
toolbox users. Use multiple copies of the toolbox to simultaneously
test different templates.
