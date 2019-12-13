#include "ioutils.h"
#include "tclap/CmdLine.h"

#include "itkLabelOverlapMeasuresImageFilter.h"

#include <itkSmartPointer.h>

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
    CmdLine cmd("compareMasks ", ' ', "0.9");

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

  typedef typename itk::LabelOverlapMeasuresImageFilter <ImType>  CompareImsType;
  typename CompareImsType::Pointer CompareIms = CompareImsType::New();

  CompareIms->SetSourceImage(mask);
  CompareIms->SetTargetImage(gtruth);
  CompareIms->Update();
  std::cout  << "Total,"
	     << "Jaccard,"
	     << "Dice,"
	     << "VolumeSim,"
	     << "FalseNegative,"
	     << "FalsePositive" << std::endl;
  std::cout  << CompareIms->GetTotalOverlap() << ",";
  std::cout  << CompareIms->GetUnionOverlap() << ",";
  std::cout  << CompareIms->GetMeanOverlap() << ",";
  std::cout  << CompareIms->GetVolumeSimilarity() << ",";
  std::cout  << CompareIms->GetFalseNegativeError() << ",";
  std::cout  << CompareIms->GetFalsePositiveError();
  std::cout << std::endl;

#if 0

  std::cout << "                                       "
            << "************ Individual Labels *************" << std::endl;
  std::cout << std::setw( 10 ) << "Label"
            << std::setw( 17 ) << "Target"
            << std::setw( 17 ) << "Union (jaccard)"
            << std::setw( 17 ) << "Mean (dice)"
            << std::setw( 17 ) << "Volume sim."
            << std::setw( 17 ) << "False negative"
            << std::setw( 17 ) << "False positive" << std::endl;
  typename CompareImsType::MapType labelMap = CompareIms->GetLabelSetMeasures();
  typename CompareImsType::MapType::const_iterator it;
  for( it = labelMap.begin(); it != labelMap.end(); ++it )
    {
    if( (*it).first == 0 )
      {
      continue;
      }

    int label = (*it).first;

    std::cout << std::setw( 10 ) << label;
    std::cout << std::setw( 17 ) << CompareIms->GetTargetOverlap( label );
    std::cout << std::setw( 17 ) << CompareIms->GetUnionOverlap( label );
    std::cout << std::setw( 17 ) << CompareIms->GetMeanOverlap( label );
    std::cout << std::setw( 17 ) << CompareIms->GetVolumeSimilarity( label );
    std::cout << std::setw( 17 ) << CompareIms->GetFalseNegativeError( label );
    std::cout << std::setw( 17 ) << CompareIms->GetFalsePositiveError( label );
    std::cout << std::endl;
    }

#endif
}

int main(int argc, char * argv[])
{
  itk::MultiThreaderBase::SetGlobalMaximumNumberOfThreads(1);
  const unsigned dim = 3;
  CmdLineType CmdLineObj;
  ParseCmdLine(argc, argv, CmdLineObj);
  typedef itk::Image<unsigned char, dim> LabImType;

  doCompare<LabImType>(CmdLineObj);

  return EXIT_SUCCESS;

}

