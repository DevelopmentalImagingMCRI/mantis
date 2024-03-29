# MANTiS

[MANTiS home page](http://developmentalimagingmcri.github.io/mantis)

The morphogical adaptive neonate tissue segmentation toolbox for spm.

If you use this toolbox, please cite:

[_Neonatal Brain Tissue Classification with Morphological Adaptation and Unified Segmentation_, Beare et al, Frontiers in Neuroinformatics, 2016.](http://dx.doi.org/10.3389/fninf.2016.00012)

```
@Article{Beare2016NeonateClassification,
  author =       {Beare, R. and Chen, J. and Kelly, C.E. and Alexopoulos, D. and Smyser, C.D. and Rogers, C.E. and Loh, W.Y. Gabra-Fam, L. and Cheong, J.L.Y. nd  Spittle, A. J. and Anderson, P. J. and Doyle, L.W. and Inder, T.E. and Seal, M.L. and Thompson, D.K.},
  title =        {Neonatal Brain Tissue Classification with Morphological Adaptation and Unified Segmentation},
  journal =      {Frontiers in Neuroinformatics},
  year =         {2016},
  volume =       {10},
  number =       {12},
  DOI = {10.3389/fninf.2016.00012},
  OPTannote =    {}
}

```

## Installation

MANTiS uses ITK binaries that need to be built for your system, as we
do not supply binary files. This process requires the following tools:

c++ development tools (gcc/g++ on linux, available via package manager, xcode on mac, free from the app store)

git version control system

cmake cross platform build system.

The installation process can be carried out anywhere and the resulting
folder moved to the spm toolbox folder, or carried out directly in the
spm toolbox folder. The following example assumes the latter,
requiring write access to that folder.

1. Fetch the package:

```bash
git clone https://github.com/DevelopmentalImagingMCRI/mantis.git
cd mantis
git submodule init
git submodule update
```

1. Build the ITK components:

The following commands use the SuperBuild process, that fetches a
specific ITK version and builds it. This takes a while. If you know
what you are doing you may be able to use a system version of
ITK. Make sure you match up the installation directory with the
SuperBuild version

The build process requires cmake and git and a compiler.

```bash
cd ITKStuff
```

On linux/mac:
```bash
## Make a build directory with the matlab architecture in the name

export ARCH=$(echo "disp(sprintf('\n%s', computer)),quit" | matlab -nojvm -nodesktop -nosplash |tail -1)

mkdir Build.${ARCH} 
```

Finally, trigger a build:

```bash
cd Build.${ARCH}

cmake ../SuperBuild
## increase if you have lots of cores
make -j2
```

executables named _segCSF_ , _cleanWM_ and _neonateScalper_ will be in
```bash
mantis/ITKStuff/Build.${ARCH}/MANTiS-build/bin/
```

You can delete build files:

```bash

rm -rf ITK-build ITK-prefix ITK

```


## Getting started

MANTiS is an SPM toolbox and can be accessed as follows.

1. Select mantis from the toolbox dropdown menu:
![mantis from toolbox menu](https://github.com/DevelopmentalImagingMCRI/mantis/raw/master/Instructions/mantis_toolbox_menu.png)
1. Select the complete pipeline option to load the pipeline in the batch editor.
![mantis from local menu](https://github.com/DevelopmentalImagingMCRI/mantis/raw/master/Instructions/mantis_menu2.png)
1. Select scalped T2 structural scans from the batch editor file selection:
![mantis from batch](https://github.com/DevelopmentalImagingMCRI/mantis/raw/master/Instructions/mantis_file_selection.png)
1. Click the green run button, and wait. The results for each phase will be stored in two folders, named Phase1 and Phase2.
1. The components from which the pipeline is constructed are available from the batch editor tools 
