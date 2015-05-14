# MANTiS
========

The morphogical adaptive neonate tissue segmentation toolbox for spm.


## Setup ITK tools

MANTiS uses ITK to implement some steps. These tools need to be compiled, a process
that has been tested on linux and mac. The build process requires cmake and git

cd mantis/ITKStuff

On linux/mac:

ARCH=$(echo "disp(sprintf('\n%s', computer)),quit" | matlab -nojvm -nodesktop -nosplash |tail -1)

mkdir Build.${ARCH} 
cd Build.${ARCH}

cmake ../SuperBuild



make

executables will be in

mantis/ITKStuff/Build.${ARCH}/MANTiS-build/bin/

