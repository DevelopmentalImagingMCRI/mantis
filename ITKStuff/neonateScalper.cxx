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
  std::string InputIm, OutputIm; //
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
    CmdLine cmd("neonateScalper", ' ', "0.9");

    ValueArg<std::string> inArg("i","input","T2 input image",true,"result","string");
    cmd.add( inArg );

    ValueArg<std::string> outArg("","outputprefix","output image",true,"result","string");
    cmd.add( outArg );

    SwitchArg debugArg("d", "debug", "save debug images", debug);
    cmd.add( debugArg );

    // Parse the args.
    cmd.parse( argc, argv );

    CmdLineObj.InputIm = inArg.getValue();
    CmdLineObj.OutputImPrefix = outArg.getValue();
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
    return(0);
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
template <class RawImType>
void findTop(typename RawImType::Pointer raw, float distance, float slice, 
	     int &outtop, int &outbottom, int &x, int &y)
{
  typedef typename itk::Image<unsigned char, RawImType::ImageDimension> MaskImType;

  itk::Instance<itk::OtsuThresholdImageFilter <RawImType, MaskImType> > Thresh;
  itk::Instance<itk::BinaryShapeKeepNObjectsImageFilter<MaskImType> > discarder;
  Thresh->SetInput(raw);
  Thresh->SetInsideValue(0);
  Thresh->SetOutsideValue(1);
  discarder->SetNumberOfObjects(1);
  discarder->SetInput(Thresh->GetOutput());
  discarder->SetForegroundValue(1);

  typename MaskImType::Pointer mask = discarder->GetOutput();
  mask->Update();
  mask->DisconnectPipeline();

  // find the top
  typedef typename itk::BinaryImageToShapeLabelMapFilter<MaskImType> LabellerType;
  typename LabellerType::Pointer labeller = LabellerType::New();

  labeller->SetInput(mask);
  labeller->SetFullyConnected(true);
  labeller->SetInputForegroundValue(1);

  typedef typename LabellerType::OutputImageType LabelMapType;
  typedef typename LabellerType::OutputImagePointer LabelMapPointerType;
  typedef typename LabelMapType::LabelObjectType LabelObjectType;

  writeImDbg<MaskImType>(mask, "cropmask");

  LabelMapPointerType labmap = labeller->GetOutput();
  labmap->Update();
  labmap->DisconnectPipeline();

  // can only be one object
  LabelObjectType * labelObject = labmap->GetLabelObject(1);
  typename MaskImType::RegionType bb = labelObject->GetBoundingBox();


  typename RawImType::SpacingType sp = raw->GetSpacing();
  int top = bb.GetIndex()[2] + bb.GetSize()[2] - 1;
  {
  // estimate the centroid using the top 15mm
  typedef typename itk::LabelImageToShapeLabelMapFilter<MaskImType> LabellerTypeB;
  typename LabellerTypeB::Pointer labellerB = LabellerTypeB::New();

  typedef typename LabellerTypeB::OutputImageType LabelMapTypeB;
  typedef typename LabellerTypeB::OutputImagePointer LabelMapPointerTypeB;
  typedef typename LabelMapTypeB::LabelObjectType LabelObjectTypeB;

  typename MaskImType::RegionType blank = mask->GetLargestPossibleRegion();
  typename MaskImType::RegionType::SizeType s = blank.GetSize();
  s[2] = top - slice/sp[2];
  blank.SetSize(s);

  fillRegion<MaskImType>(mask, blank, 0);
  writeImDbg<MaskImType>(mask, "topmask");
  labellerB->SetInput(mask);
  LabelMapPointerTypeB labmapB = labellerB->GetOutput();
  labmapB->Update();
  labmapB->DisconnectPipeline();
  LabelObjectTypeB * labelObjectB = labmapB->GetLabelObject(1);
  typename MaskImType::PointType cent = labelObjectB->GetCentroid();
  typename MaskImType::IndexType ind;
  mask->TransformPhysicalPointToIndex(cent, ind);
  x=ind[0];
  y=ind[1];
  }

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

  IPtr T2 = readIm<ImageType>(CmdLineObj.InputIm);
}

int main(int argc, char * argv[])
{
  CmdLineType CmdLineObj;
  ParseCmdLine(argc, argv, CmdLineObj);

  const int dimension = 3;

  // These tolerances are being set high because we rely on spm to pass in
  // appropriate data. Problems arise because spm uses the sform when
  // the sform and qform are different while ITK seems to use the
  // qform.
  // This code doesn't use orientation info, so we'll ignore the
  // headers.
  // We'll use spm code to copy the headers in spm style.

  itk::ImageToImageFilterCommon::SetGlobalDefaultCoordinateTolerance(1000.0);
  itk::ImageToImageFilterCommon::SetGlobalDefaultDirectionTolerance(1000.0);

  doSeg<short, dimension>(CmdLineObj);


  return(EXIT_SUCCESS);
}
