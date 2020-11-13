#include <iostream>
#include <complex>
#include<stdio.h>
#define MAX 8192
#include "PEAK.hpp"

using namespace std;

#define M_PI 3.1415926535897932384
#define ABS(A,B) ( (A) > (B) ) ? ( (A) - (B)) : ((B) - (A))  /// return absolute value

double FFT(complex<double>f[8192], int N, int d)
{

#pragma HLS inline region
  transform(f, N);

  for(int i = 0; i < N; i++){
   f[i] *= d; //multiplying by step
  //cout << f[i] << endl;
  }

     double magvec[8192] = {0,};
     for(int j = 0; j < N; j++){
    	 magvec[j] = ABS(real(f[j]), imag(f[j]));
       cout << magvec[j] << endl;	 // FFFFTTTTTT output
       }
       int l = sizeof(magvec) / sizeof(magvec[0]);
       Peaks(magvec, l);

      // cout << magvec[1] << endl;
       return magvec[6];

}


