#include <stdio.h>
#include <stdlib.h>
int X,Y,mX,mY;
float * cdate=NULL;
float * ccanshu=NULL;

int calkinit(float date[], float canshu[],int strides[],int shapes[])
{
    cdate=date;
    ccanshu=canshu;
    Y=strides[1] / sizeof(float);
    X=strides[0] / sizeof(float);
    mY=shapes[0];
    mX=shapes[1];
    
    // for(int i = 0; i<mX; i++)
    // {
        
    //     for(int j = 0; j <3; j++)
    //     {
    //         cdate[i*X+j*Y]=ccanshu[i*X];
    //     }
        
    // }
    

    return 0;
}
int cal(int time)
{
    int i = 1;
    int t=time;
    for (; i < (mY-1); i++)
    {
        cdate[t*Y+i*X]=ccanshu[i*X]*(cdate[(t-1)*Y+(i-1)*X]+cdate[(t-1)*Y+(i+1)*X]-2*cdate[(t-1)*Y+(i-0)*X])-cdate[(t-2)*Y+(i-0)*X]+2*cdate[(t-1)*Y+(i-0)*X];
        printf("%f ",cdate[t*Y+i*X]);
    }
    printf("***\n");
    
    return (t*Y+i*X);
}
