// this tool performs simple segmentations of the ventricles, give
// a probability map from spm. The idea is to use the map as
// a marker for segmenting enlarged ventricles.
#include <iostream>
#include <cstdio>
#include <vector>

#include "tclap/CmdLine.h"

#include "ioutils.h"
#include <itkLabelStatisticsImageFilter.h>
#include <itkNaryMaximumImageFilter.h>
#include <itkGradientMagnitudeRecursiveGaussianImageFilter.h>
#include <itkSmoothingRecursiveGaussianImageFilter.h>
#include <itkMorphologicalWatershedFromMarkersImageFilter.h>
#include <itkBinaryShapeOpeningImageFilter.h>
#include <itkGradientMagnitudeImageFilter.h>
#ifdef IFTWS
#include "itkIFTWatershedFromMarkersImageFilter.h"
#endif

#include <itkSmartPointer.h>
namespace itk
{
template <typename T>
class Instance : public T::Pointer {
public:
  Instance() : SmartPointer<T>( T::New() ) {}
};
}

#include "morphutils.h"


typedef class CmdLineType
{
public:
  std::string InputIm, OutputImPrefix; //
  std::string GProbIm, CSFProbIm;
} CmdLineType;

bool debug=false;
std::string debugprefix="/tmp/jc/prem";
std::string debugsuffix=".nii.gz";

template <class TImage>
void writeImDbg(const typename TImage::Pointer Im, std::string filename)
{
  if (debug)
    {
    writeIm<TImage>(Im, debugprefix + "_" + filename + debugsuffix);
    }
}

void ParseCmdLine(int argc, char* argv[],
                  CmdLineType &CmdLineObj
  )
{
  using namespace TCLAP;
  try
    {
    // Define the command line object.
    CmdLine cmd("segCSF", ' ', "0.9");

    ValueArg<std::string> inArg("i","input","input image",true,"result","string");
    cmd.add( inArg );

    ValueArg<std::string> outArg("","outputprefix","output image prefix",true,"result","string");
    cmd.add( outArg );

    ValueArg<std::string> greyArg("","grey","GM prob image", true,"","string");
    cmd.add( greyArg );


    ValueArg<std::string> csfArg("","csf","CSF prob image", true,"","string");
    cmd.add( csfArg );

    ValueArg<std::string> prefixArg("","prefix","write output images with this prefix",false, debugprefix, "string");
    cmd.add( prefixArg );
    SwitchArg debugArg("d", "debug", "save debug images", debug);
    cmd.add( debugArg );

    // Parse the args.
    cmd.parse( argc, argv );

    CmdLineObj.InputIm = inArg.getValue();
    CmdLineObj.OutputImPrefix = outArg.getValue();
    CmdLineObj.GProbIm = greyArg.getValue();
    CmdLineObj.CSFProbIm = csfArg.getValue();
    debugprefix = prefixArg.getValue();
    debug=debugArg.getValue();
    }
  catch (ArgException &e)  // catch any exceptions
    {
    std::cerr << "error: " << e.error() << " for arg " << e.argId() << std::endl;
    }
}

//////////////////////////////////////////////////////////////
#include "vibes_common.h"
/////////////////////////////////////////////////////////////////
template <class RawImType>
typename RawImType::Pointer scaleSpaceSmooth(typename RawImType::Pointer input, std::vector<float> scales)
{
  // smooth at different scales and take a max
  typename RawImType::Pointer res, tmp;

  itk::Instance< itk::SmoothingRecursiveGaussianImageFilter< RawImType, RawImType > > Smoother;
  itk::Instance< itk::MaximumImageFilter<RawImType, RawImType, RawImType> > Max;

  if (scales.size() == 0)
    {
    std::cerr << "At least one smoothing scale must be specified" << std::endl;
    return(nullptr);
    }
  Smoother->SetInput(input);
  Smoother->SetNormalizeAcrossScale(true);
  Smoother->SetSigma(scales[0]);
  res = Smoother->GetOutput();
  res->Update();
  res->DisconnectPipeline();

  for (unsigned i=1; i<scales.size(); i++)
    {
    Smoother->SetSigma(scales[i]);
    Max->SetInput(res);
    Max->SetInput2(Smoother->GetOutput());
    tmp=Max->GetOutput();
    tmp->Update();
    tmp->DisconnectPipeline();
    res=tmp;
    }
  return(res);
}

/////////////////////////////////////////////////////////////////
template <class PixType, int dimension>
void doSeg(const CmdLineType &CmdLineObj)
{
  // floating point image for spm prob maps
  typedef itk::Image<PixType, dimension> ImageType;
  typedef typename ImageType::Pointer IPtr;
  typedef typename itk::Image<float, ImageType::ImageDimension> FloatImType;
  typedef typename FloatImType::Pointer FIPtr;
  typedef typename itk::Image<unsigned char, ImageType::ImageDimension> MaskImType;
  typedef typename MaskImType::Pointer MIPtr;

  // load the prob images and create a brain mask
  FIPtr grey  = readIm<FloatImType>(CmdLineObj.GProbIm);
  FIPtr csf   = readIm<FloatImType>(CmdLineObj.CSFProbIm);

  IPtr T2 = readIm<ImageType>(CmdLineObj.InputIm);

  // simple intensity thresholding doesn't work well.


  // figure out a mean wm intensity
  MIPtr csfmask = doThresh<FloatImType, MaskImType>(csf, 0.9, 3);
  MIPtr gmmask = doThresh<FloatImType, MaskImType>(grey, 0.7, 2);

  itk::Instance< itk::BinaryThresholdImageFilter<ImageType, MaskImType> > T2Thresh;
  T2Thresh->SetInput(T2);
  T2Thresh->SetUpperThreshold(0);
  T2Thresh->SetLowerThreshold(0);
  T2Thresh->SetInsideValue(1);
  T2Thresh->SetOutsideValue(0);


  // object size filter on the csfmask
  itk::Instance< itk::BinaryShapeOpeningImageFilter< MaskImType> > SizeFilter;
  SizeFilter->SetInput(csfmask);
  //SizeFilter->SetInput(OpenThresh->GetOutput());
  SizeFilter->SetLambda(500);
  SizeFilter->SetForegroundValue(3);
  writeImDbg<MaskImType>(SizeFilter->GetOutput(), "csfsize");

  itk::Instance< itk::NaryMaximumImageFilter<MaskImType, MaskImType> > MaxFilt;
  MaxFilt->SetInput(0, T2Thresh->GetOutput());
  MaxFilt->SetInput(1, gmmask);
  MaxFilt->SetInput(2, SizeFilter->GetOutput());

  writeImDbg<MaskImType>(MaxFilt->GetOutput(), "allmarkers");

#ifndef IFTWS

  // use half min voxel size

  float minvxsz=1000.0;

  for (unsigned i = 0; i < ImageType::ImageDimension; i++) {
    if (T2->GetSpacing()[i] < minvxsz) minvxsz= T2->GetSpacing()[i];
  }
  //itk::Instance< itk::GradientMagnitudeRecursiveGaussianImageFilter<ImageType, ImageType > > GradFilt;
  itk::Instance <itk::GradientMagnitudeImageFilter<ImageType, ImageType> > GradFilt;
  GradFilt->SetInput(T2);
  GradFilt->SetUseImageSpacingOn();
  //GradFilt->SetSigma(minvxsz/2);
  //GradFilt->SetSigma(0.05);
  // use only two scales - very fine, and related to
  // voxel size.
  std::vector<float> scales;
  scales.push_back(0.25);
  scales.push_back(minvxsz);
  // //scales.push_back(1);
  IPtr grad = scaleSpaceSmooth<ImageType>(GradFilt->GetOutput(), scales);
  itk::Instance< itk::MorphologicalWatershedFromMarkersImageFilter<ImageType, MaskImType> > WSFilt;
  WSFilt->SetInput(GradFilt->GetOutput());
  WSFilt->SetMarkerImage(MaxFilt->GetOutput());
  writeImDbg<ImageType>(GradFilt->GetOutput(), "grad");
#else
  itk::Instance< itk::IFTWatershedFromMarkersImageFilter<ImageType, MaskImType> > WSFilt;
  WSFilt->SetInput(T2);
  WSFilt->SetMarkerImage(MaxFilt->GetOutput());


#endif
  itk::Instance<itk::BinaryThresholdImageFilter<MaskImType, MaskImType> > SelectCSF;
  SelectCSF->SetInput(WSFilt->GetOutput());
  SelectCSF->SetUpperThreshold(3);
  SelectCSF->SetLowerThreshold(3);
  SelectCSF->SetInsideValue(1);
  SelectCSF->SetOutsideValue(0);

  //writeIm<MaskImType>(SelectCSF->GetOutput(), CmdLineObj.OutputIm);
   writeIm<MaskImType>(SelectCSF->GetOutput(), CmdLineObj.OutputImPrefix + "_csfmask.nii");

}

int main(int argc, char * argv[])
{
  CmdLineType CmdLineObj;
  ParseCmdLine(argc, argv, CmdLineObj);

  const int dimension = 3;
  int dim1 = 0;
  itk::ImageIOBase::IOComponentEnum ComponentType;
  if (!readImageInfo(CmdLineObj.InputIm, &ComponentType, &dim1)) 
    {
    std::cerr << "Failed to open " << CmdLineObj.InputIm << std::endl;
    return(EXIT_FAILURE);
    }
  if (dim1 != dimension) 
    {
      std::cerr << CmdLineObj.InputIm << "isn't 3D" << std::endl;
      return(EXIT_FAILURE);
    }

  // These tolerances are being set high because we rely on spm to pass in
  // appropriate data. Problems arise because spm uses the sform when
  // the sform and qform are different while ITK seems to use the
  // qform.
  // This code doesn't use orientation info, so we'll ignore the
  // headers.
  // We'll use spm code to copy the headers in spm style.

  itk::ImageToImageFilterCommon::SetGlobalDefaultCoordinateTolerance(1000.0);
  itk::ImageToImageFilterCommon::SetGlobalDefaultDirectionTolerance(1000.0);

  switch (ComponentType) 
    {
    case (itk::ImageIOBase::IOComponentEnum::SHORT):
      doSeg<short, dimension>(CmdLineObj);
      break;
    case (itk::ImageIOBase::IOComponentEnum::USHORT):
      doSeg<unsigned short, dimension>(CmdLineObj);
      break;
    case (itk::ImageIOBase::IOComponentEnum::INT):
      doSeg<int, dimension>(CmdLineObj);
      break;
    default:
      doSeg<float, dimension>(CmdLineObj);
      break;
    }


  return(EXIT_SUCCESS);
}
