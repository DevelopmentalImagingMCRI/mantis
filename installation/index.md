---
layout: default
title: Installation
---
<br>
{: .content}

# Installing MANTiS
MANTiS is provided as a combination of matlab and c++ code. It needs to be built for your
platform. So far we have only tested on Linux systems. In principle it should also work
on OSX if SPM works.

## Prerequisites
The build process requires the following tools:

1. git
1. cmake
1. c++ compiler

## Decisions to make
MANTiS eventually needs to reside in the _spm/toolbox_ folder. You can carry out the commands
below in that folder or perform them elsewhere and copy the results to _spm/toolbox_. The 
advantage of doing everything in the _spm/toolbox_ is that it is easier to update the installation.

## Downloading
The source code must be fetched using _git_, and there are several steps. Type the following into
a terminal. These commands fetch the MANTiS code, plus some dependencies.

``` bash
git clone https://github.com/DevelopmentalImagingMCRI/mantis.git
cd mantis
git submodule init
git submodule update
```

Updates to mantis can be fetched using

``` bash
git pull
```

Updates to c++ parts will require a rebuild to take effect.

## Developers

[MANTiS is hosted on github](https://github.com/DevelopmentalImagingMCRI/mantis)

## Build ITK components
The following commands use the SuperBuild process, that fetches a
specific ITK version and builds it. This takes a while. If you know
what you are doing you may be able to use a system version of
ITK. Make sure you match up the installation directory with the
SuperBuild version

The build process requires cmake and git and a compiler.

``` bash
cd ITKStuff
```

On linux/mac:

``` bash
## Make a build directory with the matlab architecture in the name

export ARCH=$(echo "disp(sprintf('\n%s', computer)),quit" | matlab -nojvm -nodesktop -nosplash |tail -1)

mkdir Build.${ARCH} 
```

Finally, trigger a build:

``` bash
cd Build.${ARCH}

cmake ../SuperBuild
## increase if you have lots of cores
make -j2
```

executables named _segCSF_ , _cleanWM_ and _neonateScalper_ will be in

``` bash
mantis/ITKStuff/Build.${ARCH}/MANTiS-build/bin/
```

You can delete build files to save space:

``` bash

rm -rf ITK-build ITK-prefix ITK

```

## Preliminary windows instructions

We have only performed limited testing, with 64 bit Windows and the MSYS2 compiler
suite. Substituting 32 bit alternatives may work for 32 bit windows, provided you change the directory
name, as discussed below.

### Install MSYS 64 bit

Fetch and run the [64 bit msys installer](http://www.msys2.org)

Update the base system from the MSYS2 prompt:

``` bash
pacman -Syu
```

Close terminal, then reopen:

``` bash
pacman -Su
```

repeat a few times until everything appears stable.
### MSYS2 components

Select the "all" option (default).

``` bash
pacman -S zip git  base-devel mingw-w64-x86_64-ninja \
              mingw-w64-x86_64-toolchain \
              mingw-w64-x86_64-cmake \
              mingw-w64-x86_64-extra-cmake-modules \
              automake gcc-fortran


```

### Mantis

Note - some of the build tools issue complaints about path lengths, so carry out the build 
somewhere near the top of the drive and move it to the spm/toolbox folder later.

All the following commands are executed from the MSYS2 shell.

Fetch mantis (as per linux etc):

``` bash
git clone https://github.com/DevelopmentalImagingMCRI/mantis.git
cd mantis
git submodule init
git submodule update
```

Create the build folder. PCWIN64, in the paths below, is the result of the matlab command:
```matlab
computer
```
Change it if you get a different response on your system.
```bash
cd mantis/ITKStuff
mkdir Build.PCWIN64
cd Build.PCWIN64
```
Set the msys path

```
export PATH=/c/msys64/mingw64/bin:$PATH
```

Configure the build:

```bash
cmake -G Ninja \
-DCMAKE_CXX_COMPILER=c:/msys64/mingw64/bin/c++.exe \
-DCMAKE_EXE_LINKER_FLAGS="-static-libgcc -static-libstdc++ -static -lpthread"  \
../SuperBuild
```
Run the build:
```bash
ninja
```

Wait....

When it is done, check that the executables run by double clicking on
them from explorer. Exe files will be in 
```bash
mantis/ITKStuff/Build.PCWIN64/MANTiS-build/bin/
```
Nothing should happen, but if there is an error
message about missing libraries, then something has gone wrong.

Drag the entire mantis folder structure into the spm/toolbox folder.

Give it a try.