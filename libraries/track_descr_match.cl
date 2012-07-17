/*ckwg +5
 * Copyright 2012 by Kitware, Inc. All Rights Reserved. Please refer to
 * KITWARE_LICENSE.TXT for licensing information, or contact General Counsel,
 * Kitware, Inc., 28 Corporate Drive, Clifton Park, NY 12065.
 */

__constant sampler_t imageSampler = CLK_NORMALIZED_COORDS_FALSE | CLK_ADDRESS_CLAMP_TO_EDGE | CLK_FILTER_NEAREST;

// A Brief descriptor is represented as 128 bits
//using 4 32 bit integers in the int4 datat type 
typedef int4 brief_descr;

//Hamming distance between brief descriptors.  This function counts the number of bits
//(pop count) between 4 32 ints in parallel then sums the result
int brief_dist(brief_descr b1, brief_descr b2)
{
  int4 v = b1 ^ b2; //Find the bits that differ

  //Count the bits in v in parallel
  v = v - ((v >> 1) & 0x55555555);
  v = (v & 0x33333333) + ((v >> 2) & 0x33333333);
  int4 c = ((v + (v >> 4) & 0xF0F0F0F) * 0x1010101) >> 24;

  //Sum the counts
  return c.x + c.y + c.z + c.w;
}

__kernel void track(__global int2 *kpts2, __read_only image2d_t kptmap1,
                    __global brief_descr *descriptors1, __global brief_descr *descriptors2, 
                    __global int *tracks, int window)
{
  //index into kpts1 and descriptors1
  int index = get_global_id(0);
  brief_descr descr = descriptors2[index];

  //kptmap is 1/2 the size of the original image
  int2 pixel = kpts2[index] / 2;

  int2 loc;
  int closest_dist = 15;
  int closest_index = -1;
  for (loc.x = pixel.x - window; loc.x <= pixel.x + window; loc.x++)
  {
    for (loc.y = pixel.y - window; loc.y <= pixel.y + window; loc.y++)
    {
      int val = read_imagei(kptmap1, imageSampler, loc).x;
      if (val > -1)
      {
        int dist = brief_dist(descriptors1[val], descr);
        if (dist <= closest_dist)
        {
          closest_dist = dist;
          closest_index = val;
        }
      }
    }
  }

  tracks[index] = closest_index;
}
