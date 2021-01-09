#include "hls_stream.h"
#include <iostream>
#include <stdio.h>
#include<math.h>
using namespace std;
typedef double elem ;

elem mac(elem output,elem input, elem weight)
    {
      elem x = output+(input*weight);
      cout << "mac" << output << endl;
      return x;
    }

void FullyConnectedLayers1( elem in[35], elem out[16], int numBatches,  elem weights[16][35],  elem bias[16])
    {

#pragma HLS INLINE OFF
      for(int i = 0; i< 16; i++)
      {
        for(int j = 0; j< 35; j++)
        {
        // out[i] = mac(out[i],in[j],weights[i][j])+bias[i];

        	out[i] = out[i] + (in[j]*weights[i][j]);
        }
out[i] += bias[i];
      }
      for(int i=0;i<16;i++)
                 	cout << "L1-out" << out[i] <<endl;
    }


void FullyConnectedLayers2( elem in[16], elem out[8], int numBatches,  elem weights[8][16],  elem bias[8])
    {


      #pragma HLS INLINE OFF
      for(int i = 0; i< 8; i++)
      {
        for(int j = 0; j< 16; j++)
        {
         // out[i] = mac(out[i],in[j],weights[i][j]) + bias[i];
        	out[i] = out[i] + (in[j]*weights[i][j]);
        }
        out[i] += bias[i];
      }
      for(int i=0;i<8;i++)
                      	cout << "L2-out" << out[i] <<endl;
    }
void FullyConnectedLayers3( elem in[8], elem out[6], int numBatches,  elem weights[6][8],  elem bias[6])
    {
	      #pragma HLS INLINE OFF
      for(int i = 0; i< 6; i++)
      {
        for(int j = 0; j< 8; j++)
        {
        //  out[i] = mac(out[i],in[j],weights[i][j]) + bias[i];
        	out[i] = out[i] + (in[j]*weights[i][j]);
        }
        out[i] += bias[i];
      }
      for(int i=0;i<6;i++)
                      	cout << "L3-out" << out[i] <<endl;
    }
