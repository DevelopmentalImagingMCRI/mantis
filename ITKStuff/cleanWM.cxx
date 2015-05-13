// Intended to remove the annoying bright parts of WM at the end of
// the sulcus. It is designed to be run after stage 1, before csf
// segmentation is done.

// only makes sense for T2, where CSF is bright

#include <iostream>
#include <cstdio>
#include <vector>

#include "tclap/CmdLine.h"

#include "ioutils.h"
#include <itkMaximumImageFilter.h>
#include <itkReconstructionByDilationImageFilter.h>
#include <itkBinaryShapeOpeningImageFilter.h>
#include <itkImageToImageFilterCommon.h>

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
#include "vibes_common.h"

typedef class CmdLineType
{
public:
  std::string InputIm, OutputIm, MarkerIm;
  std::string CSFProbIm, TemplateCSFProbIm;
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
    CmdLine cmd("cleanWM", ' ', "0.9");

    ValueArg<std::string> inArg("i","input","input image",true, "result","string");
    cmd.add( inArg );

    ValueArg<std::string> outArg("o","output","output image", true, "","string");
    cmd.add( outArg );
    ValueArg<std::string> markArg("m","marker","marker image", false, "","string");
    cmd.add( markArg );

    ValueArg<std::string> csfArg("","csf","CSF prob image", false,"","string");
    cmd.add( csfArg );
    ValueArg<std::string> templateCSFArg("","templatecsf","the csf template warped to native space", false,"","string");
    cmd.add(templateCSFArg  );

    ValueArg<std::string> prefixArg("","prefix","write output images with this prefix",false, debugprefix, "string");
    cmd.add( prefixArg );
    SwitchArg debugArg("d", "debug", "save debug images", debug);
    cmd.add( debugArg );

    // Parse the args.
    cmd.parse( argc, argv );

    CmdLineObj.InputIm = inArg.getValue();
    CmdLineObj.OutputIm = outArg.getValue();
    CmdLineObj.MarkerIm = markArg.getValue();
    CmdLineObj.CSFProbIm = csfArg.getValue();
    CmdLineObj.TemplateCSFProbIm = templateCSFArg.getValue();
    debugprefix = prefixArg.getValue();
    debug=debugArg.getValue();
    }
  catch (ArgException &e)  // catch any exceptions
    {
    std::cerr << "error: " << e.error() << " for arg " << e.argId() << std::endl;
    }
}
template <class PixType, int dimension>
void doFilt(const CmdLineType &CmdLineObj)
{
  typedef itk::Image<PixType, dimension> ImageType;
  typedef typename ImageType::Pointer IPtr;
  typedef typename itk::Image<float, ImageType::ImageDimension> FloatImType;
  typedef typename FloatImType::Pointer FIPtr;
  typedef typename itk::Image<unsigned char, ImageType::ImageDimension> MaskImType;
  typedef typename MaskImType::Pointer MIPtr;
  IPtr T2 = readIm<ImageType>(CmdLineObj.InputIm);
  //MIPtr csfmask = doThresh<FloatImType, MaskImType>(csf, 0.9, 3);
  MIPtr csfmask;

  if (CmdLineObj.MarkerIm != "") 
    {
      csfmask = readIm<MaskImType>(CmdLineObj.MarkerIm);
    }
  else
    {
      FIPtr csf   = readIm<FloatImType>(CmdLineObj.CSFProbIm);
      FIPtr templateCSF = readIm<FloatImType>(CmdLineObj.TemplateCSFProbIm);
      csfmask = goodCSFMarker<ImageType, MaskImType, FloatImType>
	(T2, csf, templateCSF, 3, 3, 0.9, 0.75, 10000);
    }

  // mask the T2 to create the marker
  itk::Instance< itk::MaskImageFilter<ImageType, MaskImType> >  Masker;
  itk::Instance< itk::ReconstructionByDilationImageFilter<ImageType, ImageType> > ReconFilt;

  Masker->SetInput(T2);
  Masker->SetInput2(csfmask);
  writeImDbg<MaskImType>(csfmask, "marker");

  ReconFilt->SetMarkerImage(Masker->GetOutput());
  ReconFilt->SetMaskImage(T2);
  ReconFilt->SetFullyConnected(false);

  writeIm<ImageType>(ReconFilt->GetOutput(), CmdLineObj.OutputIm);
  //writeImDbg<ImageType>(Masker->GetOutput(), "marker");
}
int main(int argc, char * argv[])
{
  CmdLineType CmdLineObj;
  ParseCmdLine(argc, argv, CmdLineObj);

  const int dimension = 3;
  //itk::ImageToImageFilterCommon::SetGlobalDefaultCoordinateTolerance(1.0);
  itk::ImageToImageFilterCommon::SetGlobalDefaultDirectionTolerance(1.0);
  doFilt<float, dimension>(CmdLineObj);

  return(EXIT_SUCCESS);
}

