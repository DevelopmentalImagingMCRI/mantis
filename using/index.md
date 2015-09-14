---
layout: default
title: Installation
---

<section role="banner">
  <img src="/img/banner.jpg" />
</section>

## Preliminaries

MANTiS is designed to process brain extracted T2 weighted images that are in the same orientation
as the template. Orientation in this case doesn't imply that the new image and template
should be registered - simply that the data ordering is the same. We use the _fslswapdim_ tool
to control data ordering.

Brain extraction for the MANTiS validation studies were carried out using FSL _BET_. There
is also a [preliminary tool](#brain) in MANTiS to perform brain extraction.

Finally, as with typical SPM segmentation, the origins of the image need to be roughly equivalent
to the template. There is a tool in MANTiS to set the origin based on the centre of mass. This
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


## Brain extraction

The MANTiS brain extraction tool is available via the batch interface:

## Setting image origins.


