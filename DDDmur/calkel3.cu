#include <stdio.h>
#include <stdlib.h>

extern "C"
{
    int cal(float *P1,float *VX,float *VY,float *VZ,float *Z0,int xar,int yar,int zar,int xm,int ym,int zm,int n,int n2,float m,int flag);
}


__global__ void cul1(float * p1j,float * vx1j,float * vy1j,float * vz1j,float *z0j,int xr, int yr,int zr,float m)
{
    // 计算kel1，用于进行梯度运算。
    // printf("%f \n",m);
    int i,j,k;
    i=threadIdx.x;
    j=blockIdx.x;
    k=blockIdx.y;

    if ((i>=1)&&(i<=blockDim.x-2)&&(j>=1)&&(j<=gridDim.x-2)&&(k>=1)&&(k<=gridDim.y-2))
    {
    vx1j[j*yr+i*xr+k*zr]-=(p1j[j*yr+i*xr+k*zr]-p1j[j*yr+(i-1)*xr+k*zr])/z0j[j*yr+i*xr+k*zr]/m;
    vy1j[j*yr+i*xr+k*zr]-=(p1j[(j+1)*yr+i*xr+k*zr]-p1j[j*yr+(i)*xr+k*zr])/z0j[j*yr+i*xr+k*zr]/m;
    vz1j[j*yr+i*xr+k*zr]-=(p1j[(j)*yr+i*xr+(k+1)*zr]-p1j[j*yr+(i)*xr+k*zr])/z0j[j*yr+i*xr+k*zr]/m;
    }
    else if (i==0)
    {
        p1j[(j)*yr+i*xr+(k)*zr]=p1j[(j)*yr+(i+2)*xr+(k)*zr];
    }

    else if (i==blockDim.x-1)
    {
        p1j[(j)*yr+i*xr+(k)*zr]=p1j[(j)*yr+(i-2)*xr+(k)*zr];
    }

    else if (j==0)
    {
        p1j[(j)*yr+i*xr+(k)*zr]=p1j[(j+2)*yr+(i)*xr+(k)*zr];
    }

    else if (j==gridDim.x-1)
    {
        p1j[(j)*yr+i*xr+(k)*zr]=p1j[(j-2)*yr+(i)*xr+(k)*zr];
    }

    else if (k==0)
    {
        p1j[(j)*yr+i*xr+(k)*zr]=p1j[(j)*yr+(i)*xr+(k+2)*zr];
    }

    else if (k==gridDim.y-1)
    {
        p1j[(j)*yr+i*xr+(k)*zr]=p1j[(j)*yr+(i)*xr+(k-2)*zr];
    }

    

}


__global__ void cul2(float * p1j,float * vx1j,float * vy1j,float * vz1j,float *z0j,int xr, int yr,int zr,float m) 
{
    // 计算kel2，用于计算压强。
    int i,j,k;
    i=threadIdx.x;
    j=blockIdx.x;
    k=blockIdx.y;
    if((i>=1)&&(i<=blockDim.x-2)&&(j>=1)&&(j<=gridDim.x-2)&&(k>=1)&&(k<=gridDim.y-2))
    {
        if(i==1)
        {
            float dog;
            dog=p1j[j*yr+(i-1)*xr+k*zr]-(vx1j[j*yr+(i+2)*xr+k*zr]-vx1j[j*yr+(i+1)*xr+k*zr]+vy1j[j*yr+(i+1)*xr+k*zr]-vy1j[(j-1)*yr+(i+1)*xr+k*zr]+vz1j[j*yr+(i+1)*xr+k*zr]-vz1j[(j)*yr+(i+1)*xr+(k-1)*zr])*z0j[j*yr+(i+1)*xr+k*zr]/m;
            p1j[j*yr+i*xr+k*zr]=p1j[j*yr+(i-1)*xr+k*zr]+(1.0-m)/(1.0+m)*(dog-p1j[j*yr+i*xr+k*zr]);
        }
        else if (i==blockDim.x-2)
        {
            float dog;
            dog=p1j[j*yr+(i+1)*xr+k*zr]-(vx1j[j*yr+(i)*xr+k*zr]-vx1j[j*yr+(i-1)*xr+k*zr]+vy1j[j*yr+(i-1)*xr+k*zr]-vy1j[(j-1)*yr+(i-1)*xr+k*zr]+vz1j[j*yr+(i-1)*xr+k*zr]-vz1j[(j)*yr+(i-1)*xr+(k-1)*zr])*z0j[j*yr+(i-1)*xr+k*zr]/m;
            p1j[j*yr+i*xr+k*zr]=p1j[j*yr+(i+1)*xr+k*zr]+(1.0-m)/(1.0+m)*(dog-p1j[j*yr+i*xr+k*zr]);
        }
        else if (j==1)
        {
            float dog;
            dog=p1j[(j-1)*yr+i*xr+k*zr]-(vx1j[(j+1)*yr+(i+1)*xr+k*zr]-vx1j[(+1)*yr+i*xr+k*zr]+vy1j[(j+1)*yr+i*xr+k*zr]-vy1j[(j)*yr+i*xr+k*zr]+vz1j[(j+1)*yr+i*xr+k*zr]-vz1j[(j+1)*yr+i*xr+(k-1)*zr])*z0j[(j+1)*yr+i*xr+k*zr]/m;
            p1j[j*yr+i*xr+k*zr]=p1j[(j-1)*yr+i*xr+k*zr]+(1.0-m)/(1.0+m)*(dog-p1j[j*yr+i*xr+k*zr]);
        }
        else if (j==gridDim.x-2)
        {
            float dog;
            dog=p1j[(j+1)*yr+i*xr+k*zr]-(vx1j[(j-1)*yr+(i+1)*xr+k*zr]-vx1j[(j-1)*yr+i*xr+k*zr]+vy1j[(j-1)*yr+i*xr+k*zr]-vy1j[(j-2)*yr+i*xr+k*zr]+vz1j[(j-1)*yr+i*xr+k*zr]-vz1j[(j-1)*yr+i*xr+(k-1)*zr])*z0j[(j-1)*yr+i*xr+k*zr]/m;
            p1j[j*yr+i*xr+k*zr]=p1j[(j+1)*yr+i*xr+k*zr]+(1.0-m)/(1.0+m)*(dog-p1j[j*yr+i*xr+k*zr]);
        }
        else if (k==1)
        {
            float dog;
            dog=p1j[j*yr+i*xr+(k-1)*zr]-(vx1j[j*yr+(i+1)*xr+(k+1)*zr]-vx1j[j*yr+i*xr+(k+1)*zr]+vy1j[j*yr+i*xr+(k+1)*zr]-vy1j[(j-1)*yr+i*xr+(k+1)*zr]+vz1j[j*yr+i*xr+(k+1)*zr]-vz1j[(j)*yr+i*xr+(k)*zr])*z0j[j*yr+i*xr+(k+1)*zr]/m;
            p1j[j*yr+i*xr+k*zr]=p1j[(j-1)*yr+i*xr+k*zr]+(1.0-m)/(1.0+m)*(dog-p1j[j*yr+i*xr+k*zr]);
        }
        else if(k==gridDim.y-2)
        {
            float dog;
            dog=p1j[j*yr+i*xr+(k+1)*zr]-(vx1j[j*yr+(i+1)*xr+(k-1)*zr]-vx1j[j*yr+i*xr+(k-1)*zr]+vy1j[j*yr+i*xr+(k-1)*zr]-vy1j[(j-1)*yr+i*xr+(k-1)*zr]+vz1j[j*yr+i*xr+(k-1)*zr]-vz1j[(j)*yr+i*xr+(k-2)*zr])*z0j[j*yr+i*xr+(k-1)*zr]/m;
            p1j[j*yr+i*xr+k*zr]=p1j[(j+1)*yr+i*xr+k*zr]+(1.0-m)/(1.0+m)*(dog-p1j[j*yr+i*xr+k*zr]);
        }


        else if ((i>=2)&&(i<=blockDim.x-3)&&(j>=2)&&(j<=gridDim.x-3)&&(k>=2)&&(k<=gridDim.y-3))
        {
        p1j[j*yr+i*xr+k*zr]-=(vx1j[j*yr+(i+1)*xr+k*zr]-vx1j[j*yr+i*xr+k*zr]+vy1j[j*yr+i*xr+k*zr]-vy1j[(j-1)*yr+i*xr+k*zr]+vz1j[j*yr+i*xr+k*zr]-vz1j[(j)*yr+i*xr+(k-1)*zr])*z0j[j*yr+i*xr+k*zr]/m;
        }
    }
}

int cal(float *P1,float *VX,float *VY,float *VZ,float *Z0,int xar,int yar,int zar,int xm,int ym,int zm,int n,int n2,float m,int flag)
{
    // printf("%f %f %f\n",m,P1[400],Z0[400]);
    int size;
    float * p1=NULL;
    float * vx=NULL;
    float * vy=NULL;
    float * vz=NULL;
    float * z0=NULL;
    
    xar=xar/sizeof(float);
    yar=yar/sizeof(float);
    zar=zar/sizeof(float);
    size=(zm*zar)*sizeof(float);
    // printf("%d %d \n",xar,yar);
    // printf("%d %d %d %d\n",xar,yar,xm,ym);
    // printf("%d \n",size);
    // cudaMallocManaged((void**)&p1, size);
    
    cudaMallocManaged((void**)&p1, size);
    cudaMallocManaged((void**)&vx, size);
    cudaMallocManaged((void**)&vy, size);
    cudaMallocManaged((void**)&vz, size);
    cudaMallocManaged((void**)&z0, size);
    cudaDeviceSynchronize();
    // printf("%hd \n",p1);
    memcpy(p1,P1,size);
    
    memcpy(p1,P1,size);
    memcpy(vx,VX,size);
    memcpy(vz,VZ,size);
    memcpy(vy,VY,size);
    memcpy(z0,Z0,size);
    // printf("%s \n", "OK");
    cudaDeviceSynchronize();
    for (int i = n; i < n2; i++)
    {
        p1[128*xar+128*yar+128*zar]=sin(0.008*i);
        dim3 dog(ym,zm);
        cul1<<<dog,xm>>>(p1,vx,vy,vz,z0,xar,yar,zar,m);
        cudaDeviceSynchronize();
        cul2<<<dog,xm>>>(p1,vx,vy,vz,z0,xar,yar,zar,m);
        cudaDeviceSynchronize();
    }
    cudaDeviceSynchronize();
    // for(int i = 0; i<ym; i++)
    // {
        
    //     for(int j = 0; j <xm; j++)
    //     {
    //         printf("%f ",Z0[j*xar+i*yar]);
    //     }
    //     printf("\n");
        
    // }
    memcpy(P1,p1,size);
    memcpy(VX,vx,size);
    memcpy(VZ,vz,size);
    memcpy(VY,vy,size);
    cudaFree(p1);
    cudaFree(vx);
    cudaFree(vz);
    cudaFree(vy);
    cudaFree(z0);
    
    return 0;
}
