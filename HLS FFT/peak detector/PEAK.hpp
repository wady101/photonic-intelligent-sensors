#include <iostream>
#include <complex>
#include<stdio.h>
#define MAX 8192

using namespace std;

#define M_PI 3.1415926535897932384
#define ABS(A,B) ( (A) > (B) ) ? ( (A) - (B)) : ((B) - (A))  /// return absolute value

int log2(int N)    /*function to calculate the log2(.) of int numbers*/
{
#pragma HLS inline region
  int k = N, i = 0;
  while(k) {
    k >>= 1;
    i++;
  }
  return i - 1;
}


int reverse(int N, int n)    //calculating revers number
{
#pragma HLS inline region
  int j, p = 0;
  for(j = 1; j <= log2(N); j++) {
    if(n & (1 << (log2(N) - j)))
      p |= 1 << (j - 1);
  }

  return p;
}

void ordina(complex<double>f1[8192], int N) //using the reverse order in the array
{
#pragma HLS inline region
  complex<double> f2[MAX] = {0,0};
  for(int i = 0; i < N; i++)
    f2[i] = f1[reverse(N, i)];

  for(int j = 0; j < N; j++)
    f1[j] = f2[j];

}

void transform(complex<double> f[8192], int N) //
{
#pragma HLS inline region
  ordina(f, N);    //first: reverse order

  complex<double> W[MAX] = {0,0};
  W[1] = polar(1., -2. * M_PI / N);
  W[0] = 1;
  for(int i = 2; i < N / 2; i++)
  W[i] = pow(W[1], i);
  int n = 1;
  int a = N / 2;
  for(int j = 0; j < log2(N); j++) {
    for(int i = 0; i < N; i++) {
      if(!(i & n)) {
        complex<double> temp = f[i];
        complex<double> Temp = W[(i * a) % (n * a)] * f[i + n];
        f[i] = temp + Temp;
        f[i + n] = temp - Temp;
      }
    }
    n *= 2;
    a = a / 2;
  }
}

//peak// peak

static bool isPeak(double arr[8192], int n, double num, int i, int j)
{

if (i >= 0 && arr[i] >= num)
return false;


if (j <= n && arr[j] >= num)
return false;

return true;
}


void Peaks(double arr[8192], int n)
{
 for (int i = 0; i < n; i++)
{
if (isPeak(arr, n, arr[i], i - 1, i + 1))
{
	if(arr[i] >= 3.00000){
	cout <<  arr[i] << "----at ---->" << i << endl;
	}
}
}
cout << endl;

}
// peak close

