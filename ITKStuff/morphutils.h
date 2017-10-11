// A collection of utilities to support morphological operations. All
// structuring element sizes are in mm.
//
// This file includes the slightly dodgy practice of a global vector to
// store filter classes and hence permit streaming to continue
#ifndef __morphutils_h
#define __morphutils_h

#include "itkFlatStructuringElement.h"
#include "itkGrayscaleErodeImageFilter.h"
#include "itkGrayscaleDilateImageFilter.h"
#include "itkGrayscaleMorphologicalOpeningImageFilter.h"
#include "itkGrayscaleMorphologicalClosingImageFilter.h"
#include "itkMorphologicalGradientImageFilter.h"
#include <itkSubtractImageFilter.h>
#include <itkNumericTraits.h>
#include <itkMaximumImageFilter.h>
#include <itkMinimumImageFilter.h>
#include <itkBinaryThresholdImageFilter.h>
#include <itkMaskImageFilter.h>

template <class TImage>
typename TImage::SizeType getRadius(float xrad, float yrad, float zrad,
                                    typename TImage::SpacingType spacing)
{
  if (yrad < 0) yrad = xrad;
  if (zrad < 0) zrad = xrad;

  typename TImage::SizeType result;
  result[0] = (long unsigned int)(xrad / spacing[0]);
  result[1] = (long unsigned int)(yrad / spacing[1]);
  if (TImage::ImageDimension > 2)
    {
    // dodgy
    result[2] = (long unsigned int)(zrad / spacing[2]);
    }
  long unsigned int mrad=0;
  for (unsigned k=0;k<TImage::ImageDimension;k++)
    {
    mrad = std::max(mrad, (long unsigned int)result[k]);
    }
  if (mrad==0)
    {
    std::cerr << "Attempting to use morphology kernel with all radius == 0 - crazy results expected" << std::endl;
    }
  //std::cout << result << std::endl;
  return result;
}

void fixRadius(int &xrad, int &yrad, int &zrad)
{
  if (yrad < 0)
    yrad = xrad;
  if (zrad < 0)
    zrad = xrad;
}

template <class TImage>
typename TImage::Pointer doErodeMM(const typename TImage::Pointer input, float xrad,
                                   float yrad=-1, float zrad=-1)
{
  const unsigned int dim = TImage::ImageDimension;
  typedef typename itk::FlatStructuringElement< dim > SRType;
  input->Update();

  typename SRType::RadiusType rad = getRadius<TImage>(xrad, yrad, zrad, input->GetSpacing());
  SRType kernel;

  kernel = SRType::Box(rad);

  typedef typename itk::GrayscaleErodeImageFilter<TImage, TImage, SRType> FiltType;
  typename FiltType::Pointer filt = FiltType::New();
  filt->SetInput(input);
  filt->SetKernel(kernel);

  filt->SetAlgorithm(FiltType::VHGW);

  typename TImage::Pointer result = filt->GetOutput();
  result->Update();
  result->DisconnectPipeline();
  return(result);
}

template <class TImage>
typename TImage::Pointer doErodeMM2(const typename TImage::Pointer input, float xrad,
                                   float yrad=-1, float zrad=-1)
{
  const unsigned int dim = TImage::ImageDimension;
  typedef typename itk::FlatStructuringElement< dim > SRType;
  input->Update();

  typename SRType::RadiusType rad = getRadius<TImage>(xrad, yrad, zrad, input->GetSpacing());
  SRType kernel;

  kernel = SRType::Box(rad);

  typedef typename itk::GrayscaleErodeImageFilter<TImage, TImage, SRType> FiltType;
  typename FiltType::Pointer filt = FiltType::New();
  filt->SetInput(input);
  filt->SetKernel(kernel);
  filt->SetBoundary(0);

  filt->SetAlgorithm(FiltType::VHGW);

  typename TImage::Pointer result = filt->GetOutput();
  result->Update();
  result->DisconnectPipeline();
  return(result);
}

template <class TImage>
typename TImage::Pointer doErodeBallMM(const typename TImage::Pointer input, float xrad,
                                   float yrad=-1, float zrad=-1)
{
  const unsigned int dim = TImage::ImageDimension;
  typedef typename itk::FlatStructuringElement< dim > SRType;
  input->Update();

  typename SRType::RadiusType rad = getRadius<TImage>(xrad, yrad, zrad, input->GetSpacing());
  SRType kernel;

  kernel = SRType::Ball(rad);

  typedef typename itk::GrayscaleErodeImageFilter<TImage, TImage, SRType> FiltType;
  typename FiltType::Pointer filt = FiltType::New();
  filt->SetInput(input);
  filt->SetKernel(kernel);

  typename TImage::Pointer result = filt->GetOutput();
  result->Update();
  result->DisconnectPipeline();
  return(result);
}

template <class TImage>
typename TImage::Pointer doErode(const typename TImage::Pointer input, int xrad,
                                 int yrad=-1, int zrad=-1)
{
  const unsigned int dim = TImage::ImageDimension;
  typedef typename itk::FlatStructuringElement< dim > SRType;

  fixRadius(xrad, yrad, zrad);

  typename SRType::RadiusType rad;
  rad[0]=xrad;
  rad[1]=yrad;
  if (dim > 2)
    rad[2]=zrad;

  SRType kernel;

  kernel = SRType::Box(rad);

  typedef typename itk::GrayscaleErodeImageFilter<TImage, TImage, SRType> FiltType;
  typename FiltType::Pointer filt = FiltType::New();
  filt->SetInput(input);
  filt->SetKernel(kernel);

  filt->SetAlgorithm(FiltType::VHGW);
  typename TImage::Pointer result = filt->GetOutput();
  result->Update();
  result->DisconnectPipeline();
  return(result);
//   AddToStack(filt);
//   return(filt->GetOutput());
}

template <class TImage>
typename TImage::Pointer doErode2(const typename TImage::Pointer input, int xrad,
                                 int yrad=-1, int zrad=-1)
{
  const unsigned int dim = TImage::ImageDimension;
  typedef typename itk::FlatStructuringElement< dim > SRType;

  fixRadius(xrad, yrad, zrad);

  typename SRType::RadiusType rad;
  rad[0]=xrad;
  rad[1]=yrad;
  if (dim > 2)
    rad[2]=zrad;

  SRType kernel;

  kernel = SRType::Box(rad);

  typedef typename itk::GrayscaleErodeImageFilter<TImage, TImage, SRType> FiltType;
  typename FiltType::Pointer filt = FiltType::New();
  filt->SetInput(input);
  filt->SetKernel(kernel);
  filt->SetBoundaryvalue(0);

  filt->SetAlgorithm(FiltType::VHGW);
  typename TImage::Pointer result = filt->GetOutput();
  result->Update();
  result->DisconnectPipeline();
  return(result);
//   AddToStack(filt);
//   return(filt->GetOutput());
}

template <class TImage>
typename TImage::Pointer doDilate(const typename TImage::Pointer input, int xrad,
                                  int yrad=-1, int zrad=-1)
{
  const unsigned int dim = TImage::ImageDimension;
  typedef typename itk::FlatStructuringElement< dim > SRType;

  fixRadius(xrad, yrad, zrad);

  typename SRType::RadiusType rad;
  rad[0]=xrad;
  rad[1]=yrad;
  if (dim > 2)
    rad[2]=zrad;

  SRType kernel;

  kernel = SRType::Box(rad);

  typedef typename itk::GrayscaleDilateImageFilter<TImage, TImage, SRType> FiltType;
  typename FiltType::Pointer filt = FiltType::New();
  filt->SetInput(input);
  filt->SetKernel(kernel);

  filt->SetAlgorithm(FiltType::VHGW);
  typename TImage::Pointer result = filt->GetOutput();
  result->Update();
  result->DisconnectPipeline();
  return(result);
//   AddToStack(filt);
//   return(filt->GetOutput());
}

template <class TImage>
typename TImage::Pointer doOpening(const typename TImage::Pointer input, int xrad,
                                   int yrad=-1, int zrad=-1)
{
  const unsigned int dim = TImage::ImageDimension;
  typedef typename itk::FlatStructuringElement< dim > SRType;

  fixRadius(xrad, yrad, zrad);

  typename SRType::RadiusType rad;
  rad[0]=xrad;
  rad[1]=yrad;
  if (dim > 2)
    rad[2]=zrad;

  SRType kernel;

  kernel = SRType::Box(rad);

  typedef typename itk::GrayscaleMorphologicalOpeningImageFilter<TImage, TImage, SRType> FiltType;
  typename FiltType::Pointer filt = FiltType::New();
  filt->SetInput(input);
  filt->SetKernel(kernel);

  filt->SetAlgorithm(FiltType::VHGW);
  typename TImage::Pointer result = filt->GetOutput();
  result->Update();
  result->DisconnectPipeline();
  return(result);
//   AddToStack(filt);
//   return(filt->GetOutput());
}

template <class TImage>
typename TImage::Pointer doOpeningCross(const typename TImage::Pointer input, int xrad,
                                   int yrad=-1, int zrad=-1)
{
  const unsigned int dim = TImage::ImageDimension;
  typedef typename itk::FlatStructuringElement< dim > SRType;

  fixRadius(xrad, yrad, zrad);

  typename SRType::RadiusType rad;
  rad[0]=xrad;
  rad[1]=yrad;
  if (dim > 2)
    rad[2]=zrad;

  SRType kernel;

  kernel = SRType::Cross(rad);

  typedef typename itk::GrayscaleMorphologicalOpeningImageFilter<TImage, TImage, SRType> FiltType;
  typename FiltType::Pointer filt = FiltType::New();
  filt->SetInput(input);
  filt->SetKernel(kernel);

  typename TImage::Pointer result = filt->GetOutput();
  result->Update();
  result->DisconnectPipeline();
  return(result);
//   AddToStack(filt);
//   return(filt->GetOutput());
}

#ifdef __itkOpenBunImageFilter_h
template <class TImage>
typename TImage::Pointer doOpenBunBoxMM(const typename TImage::Pointer input, float radius)
{
  // apply an opening by union of line segments
  typedef itk::FlatStructuringElement<TImage::ImageDimension> FlatKernelType;

  typedef itk::OpenBunImageFilter<TImage, FlatKernelType> OpenBunType;
  typename FlatKernelType::RadiusType rad = getRadius<TImage>(radius, radius, radius, input->GetSpacing());

  FlatKernelType kernel = FlatKernelType::Box(rad);

  typename OpenBunType::Pointer cb = OpenBunType::New();
  cb->SetInput(input);
  cb->SetKernel(kernel);
  typename TImage::Pointer result = cb->GetOutput();
  result->Update();
  result->DisconnectPipeline();
  return(result);

}
#endif

template <class TImage>
typename TImage::Pointer doClosing(const typename TImage::Pointer input, int xrad,
                                  int yrad=-1, int zrad=-1)
{
  const unsigned int dim = TImage::ImageDimension;
  typedef typename itk::FlatStructuringElement< dim > SRType;

  fixRadius(xrad, yrad, zrad);

  typename SRType::RadiusType rad;
  rad[0]=xrad;
  rad[1]=yrad;
  if (dim > 2)
    rad[2]=zrad;

  SRType kernel;

  kernel = SRType::Box(rad);

  typedef typename itk::GrayscaleMorphologicalClosingImageFilter<TImage, TImage, SRType> FiltType;
  typename FiltType::Pointer filt = FiltType::New();
  filt->SetInput(input);
  filt->SetKernel(kernel);

  filt->SetAlgorithm(FiltType::VHGW);
  typename TImage::Pointer result = filt->GetOutput();
  result->Update();
  result->DisconnectPipeline();
  return(result);
//   AddToStack(filt);
//   return(filt->GetOutput());
}

template <class TImage>
typename TImage::Pointer doGradient(const typename TImage::Pointer input, int xrad,
                                    int yrad=-1, int zrad=-1)
{
  const unsigned int dim = TImage::ImageDimension;
  typedef typename itk::FlatStructuringElement< dim > SRType;

  fixRadius(xrad, yrad, zrad);

  typename SRType::RadiusType rad;
  rad[0]=xrad;
  rad[1]=yrad;
  if (dim > 2)
    rad[2]=zrad;

  SRType kernel;

  kernel = SRType::Box(rad);

  typedef typename itk::MorphologicalGradientImageFilter<TImage, TImage, SRType> FiltType;
  typename FiltType::Pointer filt = FiltType::New();
  filt->SetInput(input);
  filt->SetKernel(kernel);

  filt->SetAlgorithm(FiltType::VHGW);
  typename TImage::Pointer result = filt->GetOutput();
  result->Update();
  result->DisconnectPipeline();
  return(result);
//   AddToStack(filt);
//   return(filt->GetOutput());
}

template <class TImage>
typename TImage::Pointer doGradientMM(const typename TImage::Pointer input, int xrad,
                                    int yrad=-1, int zrad=-1)
{
  const unsigned int dim = TImage::ImageDimension;
  typedef typename itk::FlatStructuringElement< dim > SRType;

  typename SRType::RadiusType rad = getRadius<TImage>(xrad, yrad, zrad, input->GetSpacing());
  SRType kernel;

  kernel = SRType::Box(rad);

  typedef typename itk::MorphologicalGradientImageFilter<TImage, TImage, SRType> FiltType;
  typename FiltType::Pointer filt = FiltType::New();
  filt->SetInput(input);
  filt->SetKernel(kernel);

  filt->SetAlgorithm(FiltType::VHGW);
  typename TImage::Pointer result = filt->GetOutput();
  result->Update();
  result->DisconnectPipeline();
  return(result);
}

template <class TImage>
typename TImage::Pointer doDilateBallMM(const typename TImage::Pointer input, float xrad,
                                    float yrad=-1, float zrad=-1)
{
  const unsigned int dim = TImage::ImageDimension;
  typedef typename itk::FlatStructuringElement< dim > SRType;
  input->Update();

  typename SRType::RadiusType rad = getRadius<TImage>(xrad, yrad, zrad, input->GetSpacing());
  SRType kernel;
  kernel = SRType::Ball(rad);
  typedef typename itk::GrayscaleDilateImageFilter<TImage, TImage, SRType> FiltType;
  typename FiltType::Pointer filt = FiltType::New();
  filt->SetInput(input);
  filt->SetKernel(kernel);

  typename TImage::Pointer result = filt->GetOutput();
  result->Update();
  result->DisconnectPipeline();
  return(result);
//   AddToStack(filt);
//   return(filt->GetOutput());
}

template <class TImage>
typename TImage::Pointer doDilateMM(const typename TImage::Pointer input, float xrad,
                                    float yrad=-1, float zrad=-1)
{
  const unsigned int dim = TImage::ImageDimension;
  typedef typename itk::FlatStructuringElement< dim > SRType;
  input->Update();

  typename SRType::RadiusType rad = getRadius<TImage>(xrad, yrad, zrad, input->GetSpacing());
  SRType kernel;
  kernel = SRType::Box(rad);

  typedef typename itk::GrayscaleDilateImageFilter<TImage, TImage, SRType> FiltType;
  typename FiltType::Pointer filt = FiltType::New();
  filt->SetInput(input);
  filt->SetKernel(kernel);

  filt->SetAlgorithm(FiltType::VHGW);
  typename TImage::Pointer result = filt->GetOutput();
  result->Update();
  result->DisconnectPipeline();
  return(result);
//   AddToStack(filt);
//   return(filt->GetOutput());
}


template <class TImage>
typename TImage::Pointer doOpeningMM(const typename TImage::Pointer input, float xrad,
                                     float yrad=-1, float zrad=-1)
{
  const unsigned int dim = TImage::ImageDimension;
  typedef typename itk::FlatStructuringElement< dim > SRType;
  input->Update();
  typename SRType::RadiusType rad = getRadius<TImage>(xrad, yrad, zrad, input->GetSpacing());
  SRType kernel;

  kernel = SRType::Box(rad);

  typedef typename itk::GrayscaleMorphologicalOpeningImageFilter<TImage, TImage, SRType> FiltType;
  typename FiltType::Pointer filt = FiltType::New();
  filt->SetInput(input);
  filt->SetKernel(kernel);

  filt->SetAlgorithm(FiltType::VHGW);
  typename TImage::Pointer result = filt->GetOutput();
  result->Update();
  result->DisconnectPipeline();
  return(result);
//   AddToStack(filt);
//   return(filt->GetOutput());
}
template <class TImage>
typename TImage::Pointer doClosingBallMM(const typename TImage::Pointer input, float xrad,
                                     float yrad=-1, float zrad=-1)
{
  const unsigned int dim = TImage::ImageDimension;
  typedef typename itk::FlatStructuringElement< dim > SRType;
  input->Update();
  typename SRType::RadiusType rad = getRadius<TImage>(xrad, yrad, zrad, input->GetSpacing());
  SRType kernel;

  kernel = SRType::Ball(rad);

  typedef typename itk::GrayscaleMorphologicalClosingImageFilter<TImage, TImage, SRType> FiltType;
  typename FiltType::Pointer filt = FiltType::New();
  filt->SetInput(input);
  filt->SetKernel(kernel);

  typename TImage::Pointer result = filt->GetOutput();
  result->Update();
  result->DisconnectPipeline();
  return(result);
//   AddToStack(filt);
//   return(filt->GetOutput());
}
////////////////////////////////////////////////////////////////////

template <class TImage>
typename TImage::Pointer doWhiteTopHatMM(const typename TImage::Pointer input, float xrad,
                                         float yrad=-1, float zrad=-1)
{
  typename TImage::Pointer opened = doOpeningMM<TImage>(input, xrad, yrad, zrad);
  typedef typename itk::SubtractImageFilter<TImage, TImage, TImage> SubType;
  typename SubType::Pointer sub = SubType::New();
  sub->SetInput(input);
  sub->SetInput2(opened);
  typename TImage::Pointer result = sub->GetOutput();
  result->Update();
  result->DisconnectPipeline();
  return(result);
//   AddToStack(sub);
//   return(sub->GetOutput());
}
template <class TImage, class MImage>
typename TImage::Pointer doWhiteTopHatMaskedMM(const typename TImage::Pointer input,
                                               const typename MImage::Pointer mask, float xrad,
                                               float yrad=-1, float zrad=-1)
{
  typedef typename TImage::Pointer PRImage;
  // set the background to high
  itk::Instance<itk::BinaryThresholdImageFilter<MImage, TImage> > LargeBG;
  LargeBG->SetInput(mask);
  LargeBG->SetLowerThreshold(1);
  LargeBG->SetUpperThreshold(1);
  LargeBG->SetInsideValue(itk::NumericTraits<typename TImage::PixelType>::NonpositiveMin());
  LargeBG->SetOutsideValue(itk::NumericTraits<typename TImage::PixelType>::max());

  itk::Instance< itk::MaximumImageFilter<TImage , TImage, TImage> > maxcomb;
  maxcomb->SetInput(input);
  maxcomb->SetInput2(LargeBG->GetOutput());

//  writeIm<TImage>(maxcomb->GetOutput(), "/tmp/b1.nii.gz");

  PRImage ero = doErodeMM<TImage>(maxcomb->GetOutput(), xrad);
  // set the background to low
  // itk::Instance<itk::BinaryThresholdImageFilter<MImage, TImage> > SmallBG;
  // SmallBG->SetInput(mask);
  // SmallBG->SetLowerThreshold(1);
  // SmallBG->SetUpperThreshold(1);
  // SmallBG->SetInsideValue(itk::NumericTraits<typename TImage::PixelType>::max());
  // SmallBG->SetOutsideValue(itk::NumericTraits<typename TImage::PixelType>::NonpositiveMin());

  // itk::Instance< itk::MinimumImageFilter< TImage, TImage, TImage> > mincomb;
  // mincomb->SetInput(SmallBG->GetOutput());
  // mincomb->SetInput2(ero);

  PRImage dil = doDilateMM<TImage>(ero, xrad);


  typedef typename itk::SubtractImageFilter<TImage, TImage, TImage> SubType;
  typename SubType::Pointer sub = SubType::New();
  sub->SetInput(input);
  sub->SetInput2(dil);

  itk::Instance<itk::MaskImageFilter<TImage, MImage, TImage> > masker;
  masker->SetInput(sub->GetOutput());
  masker->SetInput2(mask);

  typename TImage::Pointer result = masker->GetOutput();
  result->Update();
  result->DisconnectPipeline();
  return(result);

}

template <class TImage>
typename TImage::Pointer doWhiteTopHat(const typename TImage::Pointer input, float xrad,
                                         float yrad=-1, float zrad=-1)
{
  typename TImage::Pointer opened = doOpening<TImage>(input, xrad, yrad, zrad);
  typedef typename itk::SubtractImageFilter<TImage, TImage, TImage> SubType;
  typename SubType::Pointer sub = SubType::New();
  sub->SetInput(input);
  sub->SetInput2(opened);
  typename TImage::Pointer result = sub->GetOutput();
  result->Update();
  result->DisconnectPipeline();
  return(result);
//   AddToStack(sub);
//   return(sub->GetOutput());
}


template <class TImage>
typename TImage::Pointer doGradientInner(const typename TImage::Pointer input,
                                         int xrad,
                                         int yrad=-1, int zrad=-1)
{
  typename TImage::Pointer eroded = doErode<TImage>(input, xrad, yrad, zrad);
  typedef typename itk::SubtractImageFilter<TImage, TImage, TImage> SubType;
  typename SubType::Pointer sub = SubType::New();
  sub->SetInput(input);
  sub->SetInput2(eroded);
  typename TImage::Pointer result = sub->GetOutput();
  result->Update();
  result->DisconnectPipeline();
  return(result);
//   AddToStack(sub);
//   return(sub->GetOutput());
}
template <class TImage>
typename TImage::Pointer doGradientInnerMM(const typename TImage::Pointer input,
                                           float xrad,
                                           float yrad=-1, float zrad=-1)
{
  typename TImage::Pointer eroded = doErodeMM2<TImage>(input, xrad, yrad, zrad);
  typedef typename itk::SubtractImageFilter<TImage, TImage, TImage> SubType;
  typename SubType::Pointer sub = SubType::New();
  sub->SetInput(input);
  sub->SetInput2(eroded);
  typename TImage::Pointer result = sub->GetOutput();
  result->Update();
  result->DisconnectPipeline();
  return(result);
//   AddToStack(sub);
//   return(sub->GetOutput());
}

template <class TImage>
typename TImage::Pointer doGradientOuter(const typename TImage::Pointer input,
                                           float xrad,
                                           float yrad=-1, float zrad=-1)
{
  typename TImage::Pointer dilated = doDilate<TImage>(input, xrad, yrad, zrad);
  typedef typename itk::SubtractImageFilter<TImage, TImage, TImage> SubType;
  typename SubType::Pointer sub = SubType::New();
  sub->SetInput2(input);
  sub->SetInput1(dilated);
  typename TImage::Pointer result = sub->GetOutput();
  result->Update();
  result->DisconnectPipeline();
  return(result);
}


template <class TImage>
typename TImage::Pointer doGradientOuterMM(const typename TImage::Pointer input,
                                           float xrad,
                                           float yrad=-1, float zrad=-1)
{
  typename TImage::Pointer dilated = doDilateMM<TImage>(input, xrad, yrad, zrad);
  typedef typename itk::SubtractImageFilter<TImage, TImage, TImage> SubType;
  typename SubType::Pointer sub = SubType::New();
  sub->SetInput2(input);
  sub->SetInput1(dilated);
  typename TImage::Pointer result = sub->GetOutput();
  result->Update();
  result->DisconnectPipeline();
  return(result);
}

template <class TImage>
typename TImage::Pointer doClosingMM(const typename TImage::Pointer input, float xrad,
                                     float yrad=-1, float zrad=-1)
{
  const unsigned int dim = TImage::ImageDimension;
  typedef typename itk::FlatStructuringElement< dim > SRType;
  input->Update();
  typename SRType::RadiusType rad = getRadius<TImage>(xrad, yrad, zrad, input->GetSpacing());
  SRType kernel;

  kernel = SRType::Box(rad);

  typedef typename itk::GrayscaleMorphologicalClosingImageFilter<TImage, TImage, SRType> FiltType;
  typename FiltType::Pointer filt = FiltType::New();
  filt->SetInput(input);
  filt->SetKernel(kernel);

  filt->SetAlgorithm(FiltType::VHGW);
  typename TImage::Pointer result = filt->GetOutput();
  result->Update();
  result->DisconnectPipeline();
  return(result);
//   AddToStack(filt);
//   return(filt->GetOutput());
}


////////////////////////////////////////////////////////////////////////////
template <class TImage>
typename TImage::Pointer doClosingSphere(const typename TImage::Pointer input, float xrad,
                                     float yrad=-1, float zrad=-1)
{
  const unsigned int dim = TImage::ImageDimension;
  typedef typename itk::FlatStructuringElement< dim > SRType;
  input->Update();
  typename SRType::RadiusType rad = getRadius<TImage>(xrad, yrad, zrad, input->GetSpacing());
  SRType kernel;

  kernel = SRType::Ball(rad);
  //std::cout << kernel;
  typedef typename itk::GrayscaleMorphologicalClosingImageFilter<TImage, TImage, SRType> FiltType;
  typename FiltType::Pointer filt = FiltType::New();
  filt->SetInput(input);
  filt->SetKernel(kernel); 
  filt->SetAlgorithm(FiltType::HISTO);


  typename TImage::Pointer result = filt->GetOutput();
  result->Update();
  result->DisconnectPipeline();
  return(result);
//   AddToStack(filt);
//   return(filt->GetOutput());
}

////////////////////////////////////////////////////////////////////

template <class TImage>
typename TImage::Pointer doBlackTopHatMM(const typename TImage::Pointer input, float xrad,
                                         float yrad=-1, float zrad=-1)
{
  typename TImage::Pointer opened = doClosingMM<TImage>(input, xrad, yrad, zrad);
  typedef typename itk::SubtractImageFilter<TImage, TImage, TImage> SubType;
  typename SubType::Pointer sub = SubType::New();
  sub->SetInput2(input);
  sub->SetInput(opened);
  typename TImage::Pointer result = sub->GetOutput();
  result->Update();
  result->DisconnectPipeline();
  return(result);
//   AddToStack(sub);
//   return(sub->GetOutput());
}


template <class TImage>
typename TImage::Pointer doGradientMasked(const typename TImage::Pointer input,
                                          float xrad,
                                          float yrad=-1, float zrad=-1)
{

  // assumes that mask is defined by zero values in input
  // also assume mask has already been applied to input
  typename TImage::Pointer dilated = doDilate<TImage>(input, xrad, yrad, zrad);

  itk::Instance<itk::BinaryThresholdImageFilter<TImage, TImage> > MkMask;
  MkMask->SetInput(input);
  MkMask->SetLowerThreshold(0);
  MkMask->SetUpperThreshold(0);
  MkMask->SetInsideValue(itk::NumericTraits<typename TImage::PixelType>::max());
  MkMask->SetOutsideValue(0);

  itk::Instance<itk::MaximumImageFilter <TImage, TImage, TImage> > MaxFilt;
  MaxFilt->SetInput(MkMask->GetOutput());
  MaxFilt->SetInput2(input);

  typename TImage::Pointer eroded = doErode<TImage>(MaxFilt->GetOutput(), xrad, yrad, zrad);

  typedef typename itk::SubtractImageFilter<TImage, TImage, TImage> SubType;
  typename SubType::Pointer sub = SubType::New();
  sub->SetInput(dilated);
  sub->SetInput2(eroded);

  itk::Instance <itk::MaskImageFilter<TImage, TImage> > MaskGrad;
  MaskGrad->SetInput(sub->GetOutput());
  MaskGrad->SetInput2(input);

  typename TImage::Pointer result = MaskGrad->GetOutput();
  result->Update();
  result->DisconnectPipeline();
  return(result);

}

template <class TImage, class MImage>
typename TImage::Pointer doBlackTopHatMaskedMM(const typename TImage::Pointer input,
                                               const typename MImage::Pointer mask, float xrad,
                                               float yrad=-1, float zrad=-1)
{
  // set the background to low
  itk::Instance<itk::BinaryThresholdImageFilter<MImage, TImage> > SmallBG;
  SmallBG->SetInput(mask);
  SmallBG->SetLowerThreshold(1);
  SmallBG->SetUpperThreshold(1);
  SmallBG->SetInsideValue(itk::NumericTraits<typename TImage::PixelType>::max());
  SmallBG->SetOutsideValue(itk::NumericTraits<typename TImage::PixelType>::NonpositiveMin());

  itk::Instance< itk::MinimumImageFilter< TImage, TImage, TImage> > mincomb;
  mincomb->SetInput(SmallBG->GetOutput());
  mincomb->SetInput2(input);

  typename TImage::Pointer opened = doClosingMM<TImage>(mincomb->GetOutput(), xrad, yrad, zrad);
  typedef typename itk::SubtractImageFilter<TImage, TImage, TImage> SubType;
  typename SubType::Pointer sub = SubType::New();
  sub->SetInput2(input);
  sub->SetInput(opened);
  itk::Instance<itk::MaskImageFilter<TImage, MImage, TImage> > masker;
  masker->SetInput(sub->GetOutput());
  masker->SetInput2(mask);
  typename TImage::Pointer result = masker->GetOutput();
  result->Update();
  result->DisconnectPipeline();
  return(result);
//   AddToStack(sub);
//   return(sub->GetOutput());
}


template <class TImage>
typename TImage::Pointer doBlackTopHat(const typename TImage::Pointer input, float xrad,
                                         float yrad=-1, float zrad=-1)
{
  typename TImage::Pointer opened = doClosing<TImage>(input, xrad, yrad, zrad);
  typedef typename itk::SubtractImageFilter<TImage, TImage, TImage> SubType;
  typename SubType::Pointer sub = SubType::New();
  sub->SetInput2(input);
  sub->SetInput(opened);
  typename TImage::Pointer result = sub->GetOutput();
  result->Update();
  result->DisconnectPipeline();
  return(result);
//   AddToStack(sub);
//   return(sub->GetOutput());
}

////////////////////////////////////////////////////////////////////
template <class LImage>
void fillRegion(typename LImage::Pointer im, typename LImage::RegionType region,                typename LImage::PixelType value)
{
  region.Crop(im->GetLargestPossibleRegion());
  typedef itk::ImageRegionIterator<LImage> ItType;
  ItType It(im, region);
  for (It.GoToBegin();!It.IsAtEnd();++It)
    {
    It.Set(value);
    }
}
////////////////////////////////////////////////////////////////////

template <class LImage>
void fillBoxMM(typename LImage::Pointer im,
               typename LImage::PointType centre,
               typename LImage::PixelType value,
               float xrad, float yrad = -1.0, float zrad = -1.0 )
{
  if (yrad < 0) yrad = xrad;
  if (zrad < 0) zrad = xrad;

  typename LImage::SpacingType spacing = im->GetSpacing();

  int xpts = (int)(xrad / spacing[0]);
  int ypts = (int)(yrad / spacing[1]);
  int zpts = (int)(zrad / spacing[2]);

  // draw a marker
  typename LImage::IndexType COGindex;
  im->TransformPhysicalPointToIndex(centre, COGindex);


  typename LImage::RegionType reg;
  typename LImage::RegionType::IndexType corner;
  corner[0]=COGindex[0] - xpts;
  corner[1]=COGindex[1] - ypts;
  if (LImage::ImageDimension > 2)
    corner[2]=COGindex[2] - zpts;

  typename LImage::RegionType::SizeType size;
  size[0] = 2*xpts + 1;
  size[1] = 2*ypts + 1;
  if (LImage::ImageDimension > 2)
    size[2] = 2*zpts + 1;

  reg.SetSize(size);
  reg.SetIndex(corner);

  fillRegion<LImage>(im, reg, value);
}
#if 0
// not exactly a morphological filter, but got to put it somewhere
template <class MImage>
typename MImage::Pointer keepBiggest(typename MImage::Pointer input)
{
  typedef typename itk::ConnectedComponentImageFilter5<MImage, MImage> LabType;

  typename LabType::Pointer labeller = LabType::New();
  labeller->SetInput(input);
  labeller->SetFullyConnected(true);
  labeller->SetSelectMax(true);
  labeller->SetOutValue(1);
  typename MImage::Pointer result = labeller->GetOutput();
  result->Update();
  result->DisconnectPipeline();
  return(result);
}
#endif
#endif
