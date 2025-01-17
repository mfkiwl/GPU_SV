#ifndef kernelfunc_cuh
#define kernelfunc_cuh


#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include <string.h>
#include <unistd.h>
#include <cuda.h>
#include "io.cuh"
#include "vector.cuh"
#include "random.cuh"
#include "normalmodel.cuh"
#include "regmodel.cuh"
#include "ar1model.cuh"
#include "dlm.cuh"
#include "sv.cuh"
#include "svt.cuh"
#include "svl.cuh"
#include "svtl.cuh"


__global__ void kernel_dlm(float *x,int n,unsigned int *seed,float *sigmavs,float *mus,float *phis,float *sigmas,int niter)
{
  int idx = blockDim.x*blockIdx.x + threadIdx.x;
  if(idx < niter)
  {
    int nwarmup = 5000;
    float sigmav = 0.2;
    float mu = 0.0;
    float phi = 0.95;
    float sigma = 0.2;
    //
    DLMModel<float> *model = new DLMModel<float>(x,n,sigmav,mu,phi,sigma);
    model->setseed(seed[idx]);
    //
    for(int i=0;i<100;i++){
      model->simulatestates();
    }
    // warmup
    for(int i=0;i<nwarmup;i++){ 
      model->simulatestates();
      model->simulatesigmav();
      model->simulatemu();
      model->simulatephi();
      model->simulatesigma();
    }
    //
    sigmavs[idx] = model->simulatesigmav();
    mus[idx] = model->simulatemu();
    phis[idx] = model->simulatephi();
    sigmas[idx] = model->simulatesigma();
    //
    delete model;
  }
}



__global__ void kernel_sv(float *x,int n,unsigned int *seed,float *mus,float *phis,float *sigmas,int niter)
{
  int idx = blockDim.x*blockIdx.x + threadIdx.x;
  if(idx < niter)
  {
    int nwarmup = 5000;
    float mu = 0.0;
    float phi = 0.95;
    float sigma = 0.2;
    //
    SVModel<float> *model = new SVModel<float>(x,n,mu,phi,sigma);
    model->setseed(seed[idx]);
    //
    for(int i=0;i<100;i++){
      model->simulatestates();
    }
    //
    // warmup
    for(int i=0;i<nwarmup;i++){ 
      model->simulatestates();
      model->simulateparameters();
    }
    //
    mus[idx] = model->getmu();
    phis[idx] = model->getphi();
    sigmas[idx] = model->getsigma();
    //
    delete model;
  }
}
//
//
__global__ void kernel_svl(float *x,int n,unsigned int *seed,float *mus,float *phis,float *sigmas,float *rhos,int niter)
{
  int idx = blockDim.x*blockIdx.x + threadIdx.x;
  if(idx < niter)
  {
    int nwarmup = 5000;
    float mu = 0.0;
    float phi = 0.95;
    float sigma = 0.2;
    float rho = -0.5;
    //
    //
    SVLModel<float> *model = new SVLModel<float>(x,n,mu,phi,sigma,rho);
    model->setseed(seed[idx]);
    //
    for(int i=0;i<100;i++){
      model->simulatestates();
    }
    //
    // warmup
    for(int i=0;i<nwarmup;i++){ 
      model->simulatestates();
      model->simulatemu();
      model->simulatephi();
      model->simulatesigmarho();
    }
    //
    mus[idx] = model->simulatemu();
    phis[idx] = model->simulatephi();
    model->simulatesigmarho();
    sigmas[idx] = model->getsigma();
    rhos[idx] = model->getrho();
    //
    delete model;
  }
}
//
//
__global__ void kernel_svt(float *x,int n,unsigned int *seed,float *mus,float *phis,float *sigmas,int *nus,int niter)
{
  int idx = blockDim.x*blockIdx.x + threadIdx.x;
  if(idx < niter)
  {
    int nwarmup = 5000;
    float mu = 0.0;
    float phi = 0.95;
    float sigma = 0.2;
    int nu = 20;
    //
    //
    SVTModel<float> *model = new SVTModel<float>(x,n,mu,phi,sigma,nu);
    model->setseed(seed[idx]);
    //
    for(int i=0;i<100;i++){
      model->simulatestates();
    }
    //
    //
    // warmup
    for(int i=0;i<nwarmup;i++){ 
      model->simulatestates();
      model->simulateparameters();
    }
    //
    mus[idx] = model->getmu();
    phis[idx] = model->getphi();
    sigmas[idx] = model->getsigma();
    nus[idx] = model->getnu();
    //
    delete model;
  }
}
//
//
__global__ void kernel_svtl(float *x,int n,unsigned int *seed,float *mus,float *phis,float *sigmas,float *rhos,int *nus,int niter)
{
  int idx = blockDim.x*blockIdx.x + threadIdx.x;
  if(idx < niter)
  {
    //
    //
    int nwarmup = 5000;
    float mu = 0.0;
    float phi = 0.95;
    float sigma = 0.2;
    float rho = -0.5;
    int nu = 20;
    //
    //
    //
    SVTLModel<float> *model = new SVTLModel<float>(x,n,mu,phi,sigma,rho,nu);
    model->setseed(seed[idx]);
    //
    for(int i=0;i<100;i++){
      model->simulatestates();
    }
    //
    // warmup
    for(int i=0;i<nwarmup;i++){ 
      model->simulatestates();
      model->simulateparameters();
    }
    //
    mus[idx] = model->getmu();
    phis[idx] = model->getphi();
    sigmas[idx] = model->getsigma();
    rhos[idx] = model->getrho();
    nus[idx] = model->getnu();
    //
    delete model;
  }
}


#endif
