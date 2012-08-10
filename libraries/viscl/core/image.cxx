/*ckwg +5
 * Copyright 2012 by Kitware, Inc. All Rights Reserved. Please refer to
 * KITWARE_LICENSE.TXT for licensing information, or contact General Counsel,
 * Kitware, Inc., 28 Corporate Drive, Clifton Park, NY 12065.
 */

#include <viscl/core/image.h>

namespace viscl
{

image::image(const boost::shared_ptr<cl::Image2D> &image) : img(image)
{

}

//*****************************************************************************

size_t image::width() const
{
  size_t width;
  img->getImageInfo<size_t>(CL_IMAGE_WIDTH, &width);
  return width;
}

//*****************************************************************************

size_t image::height() const
{
  size_t height;
  img->getImageInfo<size_t>(CL_IMAGE_HEIGHT, &height);
  return height;
}

//*****************************************************************************

cl::ImageFormat image::format() const
{
  cl::ImageFormat imgf;
  img->getImageInfo<cl::ImageFormat>(CL_IMAGE_FORMAT, &imgf);
  return imgf;
}

//*****************************************************************************


}