#include <stdio.h>
#include <stdlib.h>



extern "C" int cucaldog(float * date,int xar,int yar,int xm,int ym);

__global__ void calkel(float * date,int xr,int yr) 
{
    int i,j;
    i=threadIdx.x;
    j=blockIdx.x;
    // printf("%d-%d :%f\n",i,j, date[j*yr+i*xr]);
    date[j*yr+i*xr]=(float)(i+j)*(i-j);
    
}
int cucaldog(float * date,int xar,int yar,int xm,int ym)
{
    int size;
    float * num=NULL;
    xar=xar/sizeof(float);
    yar=yar/sizeof(float);
    size=(ym*yar)*sizeof(float);
    // printf("%f \n",date[(xm-1)*yar+(ym-1)*xar-1]);
    // for(int i = 0; i < ym; i++)
    // {
    //     for (int j = 0; j < xm; j++)
    //     {
    //         printf("%f@%d ",date[j*xar+i*yar],j*xar+i*yar);
    //         // p[j*xar+i*yar]=(float)sin(i+j);
    //     }
    //     printf("\n");
    // }
    cudaMallocManaged((void**)&num, size);
    // cudaMemcpy(num, date, size, cudaMemcpyHostToDevice);
    // printf("***%d \n",xar*yar);
    memcpy(num, date,size);
    calkel<<<ym,xm>>>(num,xar,yar);
    cudaDeviceSynchronize();
    memcpy(date,num,size);
    cudaFree(num);
    

    return 0;
}
