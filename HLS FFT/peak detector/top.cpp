#include <iostream>
#include <complex>
#include<stdio.h>
#include"parameters.h"
#include"fnn.hpp"
#define MAX 8192
#include<math.h>

typedef double elem ;


using namespace std;

#define M_PI 3.1415926535897932384

#define ABS(A,B) (sqrt((A*A)+(B*B)))

int log2(int N)    //function to calculate the log2(.) of int numbers
{
//#pragma HLS inline region
  int k = N, i = 0;
  while(k) {
    k >>= 1;
    i++;
  }
  return i - 1;
}


int reverse(int N, int n)    //calculating revers number
{
//#pragma HLS inline region
  int j, p = 0;
  for(j = 1; j <= log2(N); j++) {
    if(n & (1 << (log2(N) - j)))
      p |= 1 << (j - 1);
  }

  return p;
}

void ordina(complex<float>f1[MAX], int N) //using the reverse order in the array
{
//#pragma HLS inline region
  complex<float> f2[MAX] = {0,0};
  for(int i = 0; i < N; i++)
    f2[i] = f1[reverse(N, i)];

  for(int j = 0; j < N; j++)
    f1[j] = f2[j];

}

void transform(complex<float> f[MAX], int N) //
{
//#pragma HLS inline region
  ordina(f, N);    //first: reverse order

  complex<float> W[MAX] = {0,0};
  W[1] = polar(1., -2. * M_PI / N);
  W[0] = 1;
  for(int i = 2; i < N / 2; i++)
  W[i] = pow(W[1], i);
  int n = 1;
  int a = N / 2;
  for(int j = 0; j < log2(N); j++) {
    for(int i = 0; i < N; i++) {
      if(!(i & n)) {
        complex<float> temp = f[i];
        complex<float> Temp = W[(i * a) % (n * a)] * f[i + n];
        f[i] = temp + Temp;
        f[i + n] = temp - Temp;
      }
    }
    n *= 2;
    a = a / 2;
  }
}

//peak// peak

static bool isPeak(float arr[MAX], int n, float num, int i, int j)
{
if (i >= 0 && arr[i] >= num)
return false;

if (j <= n && arr[j] >= num)
return false;

return true;
}

/*
float *Peaks(float arr[MAX], int n)
{

    float NNarr[35] = {0,};
    int j = 0;

 for (int i = 0; i < n; i++)
{
if (isPeak(arr, n, arr[i], i - 1, i + 1))
{
	if(arr[i] >= 10.00000){
	//cout <<  arr[i] << "----at ---->" << i << endl;
	NNarr[j] = arr[i];
  //  cout << "Check NNarr" << NNarr[j] << endl;
		j++;

	}
}
}
cout << endl;
return NNarr;
}*/
// peak close
elem NNarr[35] = {0.0,};
void Peaks(float arr[MAX], int n)
{

    int j = 0;

 for (int i = 0; i < n; i++)
{
if (isPeak(arr, n, arr[i], i - 1, i + 1))
{
	if(arr[i] >= 5.00000){
	//cout <<  arr[i] << "----at ---->" << i << endl;
	NNarr[j] = arr[i];
  //  cout << "Check NNarr" << NNarr[j] << endl;
		j++;
	}
}
}
cout << endl;

}



void NNtop (elem in[35], elem out[6], bool init, int numBatches)
{



	elem inter1[16] = {0,};
    elem inter2[8] =  {0,};
    elem NNout[6] = {0,};


FullyConnectedLayers1(in,inter1,numBatches,weight1,bias1);
FullyConnectedLayers2(inter1,inter2,numBatches,weight2,bias2);
FullyConnectedLayers3(inter2,out,numBatches,weight3,bias3);
}


void FFT(complex<float>f[MAX], float out[6])
{

	int N = 8192;
#pragma HLS INTERFACE bram port = out bundle=CRTLS
#pragma HLS INTERFACE bram port = f bundle=CRTLS
#pragma HLS INTERFACE s_axilite port=return bundle=BUS_A


	//#pragma HLS inline regions
  transform(f, N);
int d =1;
  for(int i = 0; i < N; i++){
   f[i] *= d; //multiplying by step
 // cout << f[i] << endl;
//  cout << "ABS" << abs(f[i]) <<endl;
  }

     float magvec[MAX] = {0,};
     for(int j = 0; j < N; j++){
    	 magvec[j] = ABS(real(f[j]), imag(f[j]));
      //  cout << "my abs"<< magvec[j] << endl;	 // FFFFTTTTTT output
       }
     //  int l = sizeof(magvec) / sizeof(magvec[0]);


//n    float *NNarr_pointer ;
//n    NNarr_pointer =  Peaks(magvec, MAX);

     Peaks(magvec, MAX);
//master
 /*   elem ran[35] = {-56.1118, -55.4423, -58.2629, -62.6515, -67.6260, -71.8878, -77.9820,
            -81.7234, -82.6294, -77.6667, -70.2043, -66.7026, -66.0494, -66.9979,
            -63.6631, -62.8577, -64.8098, -69.0471, -73.2807, -71.9034, -69.0906,
            -65.7843, -64.6057, -62.2151, -59.6958, -59.4090, -61.2652, -65.5335,
            -65.2160, -63.2480, -61.0909, -60.4505, -60.1723, -57.1152, -55.7277};
*/

     //1mb predecting
 /*    float ran[35] = { -56.66116,	-55.98098,	-59.057848	,-63.791844,	-68.852157,	-73.947412,	-80.912109,	-85.137232,
    		 -83.711679,	-78.878694,	-72.444549	,-68.73368,	-67.934012	,-68.284461,	-64.779488,	-64.26481,	-66.729322,
			 -71.752206,	-74.520841,	-73.808641,	-71.260638,	-67.564308,	-66.05097,	-62.643573,	-60.323761,	-60.175921,
			 -62.424469	,-66.527477,	-65.877521,	-64.565046,	-62.280524,
    		 -61.573816,	-60.472723,	-57.550839,	-56.225986};
*/

     //2mb predecting
 /*    float ran[35] = {    -55.407102,	-54.457591	,-57.086676,	-61.074555,	-64.925358,	-68.27299,	-73.852025,	-77.690222,
    		 -78.538818,	-72.814972,	-67.197127,	-64.357433,	-64.051036,	-65.095795,	-61.839582,	-61.173234,	-63.027574,
			 -67.125807,	-69.527894,	-68.437767,	-66.337306,	-63.775495,	-63.244147,	-60.484691,	-58.3829,	-58.225018,
			 -60.182185,	-63.841954,	-62.677355,	-61.439688,	-59.853586,	-59.792835	,-59.164659,	-56.498173,	-55.386388
     };
*/
// 3mb
 /*   double ran[35] = {    -54.164225,	-52.949312,	-55.134432,	-58.380286,	-60.994493,	-62.489037,	-66.089885,	-68.961873,	-70.269358,
    		 -66.177405,	-61.892989,	-60.010213,	-60.226842,	-61.901882,	-58.914799,	-58.11869,	-59.387667,	-62.590573,	-64.476428,
			 -63.031105,	-61.439422,	-60.036582,	-60.480571,	-58.355269,	-56.471633,	-56.312127,	-57.981472,	-61.180532,	-59.509947,
			 -58.364833,	-57.466548,	-58.037963,	-57.871078,	-55.458487,	-54.560806 };
*/
    double ran[35] ={  -52.230099,	-52.548188,	-54.766319,	-56.184603,	-57.892799	,-58.421881,	-59.935615,	-61.506541,	-63.551798,
    		-61.048567,	-57.844203,	-56.701015,	-57.501703,	-59.534135,	-56.6538,	-55.720561,	-56.393134,	-58.694919	,-60.215543,
			-58.411351,	-57.121876,	-56.701149,	-57.894635,	-56.449598,	-54.66574,	-54.413958,	-55.757792,	-58.872411,	-56.669262,
			-55.443968,	-55.040916,	-56.052394,	-56.59428,	-54.255965,	-53.441568
    };

     // 5mb working
 /*   elem ran[35] = {-51.215547,	-51.287294,	-53.116466,	-53.897822,	-54.576253,	-53.465181,	-52.996259,	-53.449335,	-55.867869,	-54.996413,
    		-53.3088,	-53.044847,	-54.309017,	-56.82345,	-54.196867,	-53.190975,	-53.400375,	-54.987304,	-55.907393,	-53.818527,	-53.045588,
			-53.615276,	-55.633348, -54.680829,	-53.084526,	-52.836509,	-53.963484,	-56.634638,	-54.010656,	-52.905773,	-53.073785,	-54.618766,	-55.51226,
			-53.389855,	-52.746814};
*/




    for (int i=0 ;i<35 ; i++){

     NNarr[i] = ran[i];
    // cout << "d" << setprecision(8) << NNarr[i] << endl;
    	 }

     elem NNout[6] = {0,};


   NNtop(NNarr,NNout, true,0);
for (int i =0; i< 6; i++)
	{out[i] = NNout[i];
  cout << out[i] << endl;}



}


