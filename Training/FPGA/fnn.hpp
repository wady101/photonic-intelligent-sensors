#include "ap_int.h"
#include "hls_stream.h"

typedef ap_fixed<32,7> elem ;
elem mac(elem output,elem input, elem weight)
    {
      output = output+input*weight;
      return output;
    }

void FullyConnectedLayers1( elem in[35], elem out[512], int numBatches,  elem weights[512][35],  elem bias[512])
    {
#pragma HLS INLINE OFF
      for(int i = 0; i< 512; i++)
      {
        for(int j = 0; j< 35; j++)
        {
          out[i] = mac(out[i],in[j],weights[i][j]) + bias[i];
        }
      }
    }
void FullyConnectedLayers2( elem in[512], elem out[256], int numBatches,  elem weights[256][512],  elem bias[256])
    {
      #pragma HLS INLINE OFF
      for(int i = 0; i< 256; i++)
      {
        for(int j = 0; j< 512; j++)
        {
          out[i] = mac(out[i],in[j],weights[i][j]) + bias[i];
        }
      }
    }
void FullyConnectedLayers3( elem in[256], elem out[6], int numBatches,  elem weights[6][256],  elem bias[6])
    {
      #pragma HLS INLINE OFF
      for(int i = 0; i< 6; i++)
      {
        for(int j = 0; j< 256; j++)
        {
          out[i] = mac(out[i],in[j],weights[i][j]) + bias[i];
        }
      }
    }
