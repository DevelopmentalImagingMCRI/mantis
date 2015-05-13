# MANTiS
========

The morphogical adaptive neonate tissue segmentation toolbox for spm.


## Setup ITK tools

MANTiS uses ITK to implement some steps. These tools need to be compiled, a process
that has been tested on linux and mac. The build process requires cmake and git

cd mantis/ITKStuff

mkdir Build

ccmake ../SuperBuild

make
