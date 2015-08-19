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
#include <itkOtsuThresholdImageFilter.h>
#include "itkLabelImageToShapeLabelMapFilter.h"
#include "itkLabelMapToBinaryImageFilter.h"
#include "itkBinaryDilateParaImageFilter.h"
#include "itkBinaryErodeParaImageFilter.h"
#include "itkBinaryFillholeImageFilter.h"
#include "itkDirectionalGradientImageFilter.h"

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
  std::string InputIm, OutputIm, OutputMaskIm;
  float erodesize, gradsize;
  float merodesize, mdilatesize;
} CmdLineType;

bool debug=false;
std::string debugprefix="/tmp/prem";
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
    CmdLine cmd("neonateScalper", ' ', "0.9");

    ValueArg<std::string> inArg("i","input","T2 input image",true,"result","string");
    cmd.add( inArg );

    ValueArg<std::string> outArg("o","output","output image",true,"result","string");
    cmd.add( outArg );

    ValueArg<std::string> maskArg("m","mask","output brain mask",false,"","string");
    cmd.add( maskArg );

    ValueArg<float> erodeArg("", "erode", "size of erosion (mm)", false, 2, "float");
    cmd.add(erodeArg);

    ValueArg<float> gradArg("", "grad", "size of gradient smoothing (mm)", false, 1, "float");
    cmd.add(gradArg);

    ValueArg<float> merodeArg("", "markererode", "size of erosion (mm) used when creating marker", 
                              false, 5, "float");
    cmd.add(merodeArg);

    ValueArg<float> mdilateArg("", "markerdilate", "size of dilation (mm) used when creating marker", 
                               false, 10, "float");
    cmd.add(mdilateArg);

    SwitchArg debugArg("d", "debug", "save debug images", debug);
    cmd.add( debugArg );

    // Parse the args.
    cmd.parse( argc, argv );

    CmdLineObj.InputIm = inArg.getValue();
    CmdLineObj.OutputIm = outArg.getValue();
    CmdLineObj.OutputMaskIm = maskArg.getValue();
    debug = debugArg.getValue();
    CmdLineObj.erodesize = erodeArg.getValue();
    CmdLineObj.gradsize = gradArg.getValue();
    CmdLineObj.merodesize = merodeArg.getValue();
    CmdLineObj.mdilatesize = mdilateArg.getValue();

    }
  catch (ArgException &e)  // catch any exceptions
    {
    std::cerr << "error: " << e.error() << " for arg " << e.argId() << std::endl;
    }
}

//////////////////////////////////////////////////////////////
#include "vibes_common.h"

/////////////////////////////////////////////////////////////////
template <class RawImType, class MaskImType>
typename MaskImType::Pointer findMarker(typename RawImType::Pointer raw, 
					float erode, float dilate)
{
  
  itk::Instance<itk::OtsuThresholdImageFilter <RawImType, MaskImType> > Thresh;
  itk::Instance<itk::BinaryShapeKeepNObjectsImageFilter<MaskImType> > discarder;
  itk::Instance<itk::BinaryFillholeImageFilter<MaskImType> > FillHoles;
  Thresh->SetInput(raw);
  Thresh->SetInsideValue(0);
  Thresh->SetOutsideValue(1);

  FillHoles->SetInput(Thresh->GetOutput());
  FillHoles->SetForegroundValue(1);


  discarder->SetNumberOfObjects(1);
  discarder->SetInput(FillHoles->GetOutput());
  discarder->SetForegroundValue(1);

  typename MaskImType::Pointer mask = discarder->GetOutput();
  mask->Update();
  mask->DisconnectPipeline();

  // Large erosion and keep biggest.
  itk::Instance<itk::BinaryErodeParaImageFilter<MaskImType> > Eroder;
  Eroder->SetInput(mask);
  Eroder->SetRadius(erode);
  Eroder->SetUseImageSpacing(true);
  itk::Instance<itk::BinaryShapeKeepNObjectsImageFilter<MaskImType> > discarder2;

  discarder->SetNumberOfObjects(1);
  discarder->SetInput(Eroder->GetOutput());
  discarder->SetForegroundValue(1);

  // dilate and invert.
  itk::Instance<itk::BinaryDilateParaImageFilter<MaskImType> > Dilater;
  Dilater->SetInput(discarder->GetOutput());
  Dilater->SetRadius(erode+dilate);
  Dilater->SetUseImageSpacing(true);

  itk::Instance<itk::BinaryThresholdImageFilter<MaskImType, MaskImType> > Inverter;
  Inverter->SetInput(Dilater->GetOutput());
  Inverter->SetUpperThreshold(1);
  Inverter->SetLowerThreshold(1);
  Inverter->SetInsideValue(0);
  Inverter->SetOutsideValue(2);
  itk::Instance< itk::MaximumImageFilter <MaskImType, MaskImType, MaskImType> > Combine;
  Combine->SetInput(discarder->GetOutput());
  Combine->SetInput2(Inverter->GetOutput());
  
  typename MaskImType::Pointer result = Combine->GetOutput();
  result->Update();
  return(result);
}
/////////////////////////////////////////////////////////////////
template <class PixType, int dimension>
void doSeg(const CmdLineType &CmdLineObj)
{
  // floating point image for spm prob maps
  typedef itk::Image<PixType, dimension> ImageType;
  typedef typename ImageType::Pointer IPtr;
  typedef typename itk::Image<float, ImageType::ImageDimension> FloatImType;
  //typedef typename FloatImType::Pointer FIPtr;
  typedef typename itk::Image<unsigned char, ImageType::ImageDimension> MaskImType;
  typedef typename MaskImType::Pointer MIPtr;

  IPtr T2orig = readIm<ImageType>(CmdLineObj.InputIm);

  // do everything on eroded images, then dilate the result
  float erad = CmdLineObj.erodesize;
  IPtr T2 = doErodeMM<ImageType>(T2orig, erad);

  MIPtr marker = findMarker<ImageType, MaskImType>(T2, CmdLineObj.merodesize, CmdLineObj.mdilatesize);
  writeImDbg<MaskImType>(marker, "marker");
  writeImDbg<ImageType>(T2, "eroded");

  // see if we can get away with a simple gradient.
  itk::Instance <itk::GradientMagnitudeRecursiveGaussianImageFilter<ImageType, FloatImType> > GradFilt;
  GradFilt->SetInput(T2);
  GradFilt->SetSigma(CmdLineObj.gradsize);

  itk::Instance< itk::MorphologicalWatershedFromMarkersImageFilter<FloatImType, MaskImType> > WSFilt;
  WSFilt->SetInput(GradFilt->GetOutput());
  WSFilt->SetMarkerImage(marker);

  writeImDbg<FloatImType>(GradFilt->GetOutput(), "grad");
  itk::Instance<itk::BinaryThresholdImageFilter<MaskImType, MaskImType> > SelectBrain;
  SelectBrain->SetInput(WSFilt->GetOutput());
  SelectBrain->SetUpperThreshold(1);
  SelectBrain->SetLowerThreshold(1);
  SelectBrain->SetInsideValue(1);
  SelectBrain->SetOutsideValue(0);

  writeImDbg<MaskImType>(SelectBrain->GetOutput(), "phase1");
  // Now for a phase 2?? Use a thinner gradient, with local
  // orientation so that we pick up a decrease in intensity only

  //MIPtr NewMask = doRefine<ImageType, MaskImType>(T2, SelectBrain->GetOutput(), 3);
  writeIm<MaskImType>(doDilateMM<MaskImType>(SelectBrain->GetOutput(), erad), CmdLineObj.OutputIm);


}

int main(int argc, char * argv[])
{
  CmdLineType CmdLineObj;
  ParseCmdLine(argc, argv, CmdLineObj);

  const int dimension = 3;
  int dim1 = 0;
  itk::ImageIOBase::IOComponentType ComponentType;
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
    case (itk::ImageIOBase::SHORT):
      doSeg<short, dimension>(CmdLineObj);
      break;
    case (itk::ImageIOBase::USHORT):
      doSeg<unsigned short, dimension>(CmdLineObj);
      break;
    case (itk::ImageIOBase::INT):
      doSeg<int, dimension>(CmdLineObj);
      break;
    default:
      doSeg<float, dimension>(CmdLineObj);
      break;
    }

  return(EXIT_SUCCESS);
}
