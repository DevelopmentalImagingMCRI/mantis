#ifndef __VIBES_COMMON__
#define __VIBES_COMMON__
#include <itkBinaryFillholeImageFilter.h>
#include "itkBinaryDilateParaImageFilter.h"
#include <itkBinaryShapeOpeningImageFilter.h>
#include <itkBinaryShapeKeepNObjectsImageFilter.h>
#include <itkMaskImageFilter.h>
// get a mask from the previously scalped structural scan
template <class ImType, class MaskImType>
typename MaskImType::Pointer mkBrainMask(typename ImType::Pointer T2)
{
  itk::Instance<itk::BinaryThresholdImageFilter<ImType, MaskImType> > Thresh;
  Thresh->SetInput(T2);
  Thresh->SetUpperThreshold(0);
  Thresh->SetInsideValue(0);
  Thresh->SetOutsideValue(1);

  // fill holes
  itk::Instance<itk::BinaryFillholeImageFilter<MaskImType> > Filler;
  Filler->SetInput(Thresh->GetOutput());
  Filler->SetForegroundValue(1);

  typename MaskImType::Pointer result = Filler->GetOutput();
  result->Update();
  result->DisconnectPipeline();
  return(result);
}

//////////////////////////////////////////////////////////////
template <class RawIm, class MaskIm>
typename MaskIm::Pointer doThresh(typename RawIm::Pointer raw, float threshVal, typename MaskIm::PixelType outside=1)
{
  // a convenience function - sacrifices streaming
  typedef typename itk::BinaryThresholdImageFilter<RawIm, MaskIm> ThreshType;
  typename ThreshType::Pointer wthresh = ThreshType::New();
  wthresh->SetInput(raw);
  wthresh->SetUpperThreshold((typename RawIm::PixelType)(threshVal));
  wthresh->SetLowerThreshold(0);
  wthresh->SetInsideValue(0);
  wthresh->SetOutsideValue(outside);

  typename MaskIm::Pointer result = wthresh->GetOutput();
  result->Update();
  result->DisconnectPipeline();
  return(result);
}

//////////////////////////////////////////////////////////////
template <class RawImType, class MaskImType, class ProbImType>
typename MaskImType::Pointer goodCSFMarker(typename RawImType::Pointer T2,
                                       typename ProbImType::Pointer csfprob,
                                       typename ProbImType::Pointer csfprior,
                                       int label,
                                       float radius,
                                       float csfprobthresh=0.95,
                                       float csfpriorthresh=0.75,
                                       int edgeobjsize=1000)
{
  // this function produces a marker for CSF as follows.
  // Ventricles: mask thresholded prob map with thresholded prior map
  // and keep the largest connected component.
  // Periphery: Keep large components of csf within "radius" mm of the
  // edge, where edge is the region defined by zero in T2.
  //
  // label is the value we want the csf marker to have
  typedef typename MaskImType::Pointer MIPtr;
  MIPtr csfmask = doThresh<ProbImType, MaskImType>(csfprob, csfprobthresh, label);
  MIPtr templatecsfmask = doThresh<ProbImType, MaskImType>(csfprior, csfpriorthresh, 1);

  // ventricle marker first:
  itk::Instance< itk::MaskImageFilter<MaskImType, MaskImType, MaskImType> > TemplateMasker;
  itk::Instance< itk::BinaryShapeKeepNObjectsImageFilter< MaskImType> > SizeFilter;

  // masking
  TemplateMasker->SetInput(csfmask);
  TemplateMasker->SetInput2(templatecsfmask);
  // keep biggest bit
  SizeFilter->SetInput(TemplateMasker->GetOutput());
  SizeFilter->SetForegroundValue(3);
  SizeFilter->SetNumberOfObjects(1);

  // now for the edge
  itk::Instance< itk::BinaryThresholdImageFilter<RawImType, MaskImType> > T2Thresh;
  itk::Instance< itk::MaskImageFilter<MaskImType, MaskImType, MaskImType> > EdgeMasker;
  itk::Instance< itk::BinaryShapeKeepNObjectsImageFilter< MaskImType> > BGSizeFilter;
  T2Thresh->SetInput(T2);
  T2Thresh->SetUpperThreshold(0);
  T2Thresh->SetLowerThreshold(0);
  T2Thresh->SetInsideValue(1);
  T2Thresh->SetOutsideValue(0);

  // keep the largest component of this, to be safe.
  BGSizeFilter->SetInput(T2Thresh->GetOutput());
  BGSizeFilter->SetForegroundValue(1);
  BGSizeFilter->SetNumberOfObjects(1);

  itk::Instance<itk::BinaryDilateParaImageFilter<MaskImType> > Dilater;
  Dilater->SetInput(BGSizeFilter->GetOutput());
  Dilater->SetRadius(radius);
  Dilater->SetUseImageSpacing(true);

  EdgeMasker->SetInput(csfmask);
  EdgeMasker->SetInput2(Dilater->GetOutput());

  itk::Instance< itk::BinaryShapeOpeningImageFilter<MaskImType> > EdgeSizeFilter;
  EdgeSizeFilter->SetInput(EdgeMasker->GetOutput());
  EdgeSizeFilter->SetLambda(edgeobjsize);
  EdgeSizeFilter->SetForegroundValue(3);
  // combine
  itk::Instance<itk::MaximumImageFilter<MaskImType, MaskImType, MaskImType> > Combiner;
  Combiner->SetInput1(SizeFilter->GetOutput());
  Combiner->SetInput2(EdgeSizeFilter->GetOutput());

  typename MaskImType::Pointer result = Combiner->GetOutput();
  result->Update();
  result->DisconnectPipeline();
  return(result);
}


#endif
