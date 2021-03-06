#include "ioutils.h"
#include "tclap/CmdLine.h"

#include <itkSmartPointer.h>
#include <itkContourMeanDistanceImageFilter.h>
#include <itkHausdorffDistanceImageFilter.h>

typedef class CmdLineType
{
public:
  std::string InputIm, GTIm;
} CmdLineType;

void ParseCmdLine(int argc, char* argv[],
                  CmdLineType &CmdLineObj
                  )
{
  using namespace TCLAP;
  try
    {
    // Define the command line object.
    CmdLine cmd("compareMasksSurf ", ' ', "0.9");

    ValueArg<std::string> inArg("i","input","input image",true,"result","string");
    cmd.add( inArg );

    ValueArg<std::string> outArg("g","groundtruth","ground truth image", true,"","string");
    cmd.add( outArg );

    // Parse the args.
    cmd.parse( argc, argv );

    CmdLineObj.InputIm = inArg.getValue();
    CmdLineObj.GTIm = outArg.getValue();


    }
  catch (ArgException &e)  // catch any exceptions
    {
    std::cerr << "error: " << e.error() << " for arg " << e.argId() << std::endl;
    }

}

template <class ImType>
void doCompare(const CmdLineType &CmdLineObj)
{

  typename ImType::Pointer mask = readIm<ImType>(CmdLineObj.InputIm);
  typename ImType::Pointer gtruth = readIm<ImType>(CmdLineObj.GTIm);

  typedef typename itk::ContourMeanDistanceImageFilter<ImType, ImType>  CompareImsType;
  typename CompareImsType::Pointer CompareIms = CompareImsType::New();

    typedef typename itk::HausdorffDistanceImageFilter<ImType, ImType>  CompareImsType2;
  typename CompareImsType2::Pointer CompareIms2 = CompareImsType2::New();


  CompareIms->SetInput1(mask);
  CompareIms->SetInput2(gtruth);
  CompareIms->SetUseImageSpacing(true);
  CompareIms->Update();
  CompareIms2->SetInput1(mask);
  CompareIms2->SetInput2(gtruth);
  CompareIms2->SetUseImageSpacing(true);
  CompareIms2->Update();
  std::cout  << "MeanSurfDist,HausdorffDist" << std::endl;
  std::cout  << CompareIms->GetMeanDistance() << ",";
  std::cout  << CompareIms2->GetHausdorffDistance() << std::endl;
}

int main(int argc, char * argv[])
{
  itk::MultiThreaderBase::SetGlobalMaximumNumberOfThreads(1);
  const unsigned dim = 3;
  CmdLineType CmdLineObj;
  ParseCmdLine(argc, argv, CmdLineObj);
  typedef itk::Image<unsigned char, dim> LabImType;
  itk::ImageToImageFilterCommon::SetGlobalDefaultCoordinateTolerance(1000.0);
  itk::ImageToImageFilterCommon::SetGlobalDefaultDirectionTolerance(1000.0);

  doCompare<LabImType>(CmdLineObj);

  return EXIT_SUCCESS;

}

