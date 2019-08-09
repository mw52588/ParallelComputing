#include <stdio.h>
#include <cuda.h>
#include <stdlib.h>
#include <time.h>

__global__ void add(int *a,int *b, int *c, int N) {
    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    if(tid < N) {
        c[tid] = a[tid]+b[tid];
    }
}

void addHost(int *a, int *b, int *c, int N) {
    for(int i =0; i < N; i++) {
        c[i] = a[i] + b[i];
    }
}

int main(void){
    static int N = 0; //array Size.
    static int T = 0;
    static int B = 0;
    bool compareArray = true;

    do {
        printf("Enter number for threads per block:(Maximum number of threads per block is 1024)\n");
        scanf(" %d", &T);getchar();
    }while (T > 1024 || T <= 0);

    do {
        printf("Enter blocks per grid: (Maximum number of blocks per grid is 65535)\n");
        scanf(" %d", &B);getchar();
    }while (B > 65535 || B <= 0);

    do {
        printf("Enter number for size of the array:\n");
        scanf(" %d", &N);getchar();
    }while(N <= 0);

    int a[N],b[N],c[N];
    int hostc[N];
    int *dev_a, *dev_b, *dev_c;
    cudaMalloc((void**)&dev_a,N * sizeof(int));
    cudaMalloc((void**)&dev_b,N * sizeof(int));
    cudaMalloc((void**)&dev_c,N * sizeof(int));
   
    for(int i=0;i<N;i++) {
        a[i] = i;
        b[i] = i;
    }

    cudaEvent_t start, end, s, e;                    // using cuda events to measure time
    float time , t;                               // which is applicable for asynchronous code also

    cudaEventCreate(&start);                 // instrument code to measure start time
    cudaEventCreate(&end);
   
    cudaMemcpy(dev_a, a , N*sizeof(int),cudaMemcpyHostToDevice);
    cudaMemcpy(dev_b, b , N*sizeof(int),cudaMemcpyHostToDevice);
    cudaMemcpy(dev_c, c , N*sizeof(int),cudaMemcpyHostToDevice);
	cudaEventRecord(start, 0 );
    add<<<B,T>>>(dev_a,dev_b,dev_c, N);
	cudaEventRecord(end, 0 );                 // instrument code to measure end time
    cudaEventSynchronize(end);
    cudaEventElapsedTime(&time, start, end);
    cudaMemcpy(c,dev_c,N*sizeof(int),cudaMemcpyDeviceToHost);
	
    printf("Host to Device: \n");
    for(int i=0;i<N;i++) {
        printf("%d+%d=%d\n",a[i],b[i],c[i]);
    }
   

    printf("\n\nHost process\n");
   
    cudaEventCreate(&s);                 // instrument code to measure start time
    cudaEventCreate(&e);
    cudaEventRecord(s, 0 );
    addHost(a, b, hostc, N);
    cudaEventRecord(e, 0);
    cudaEventSynchronize(e);
    cudaEventElapsedTime(&t, s, e);

   
   
    for (int i =0; i < N; i++) {
        printf("%d+%d=%d\n",a[i],b[i],hostc[i]);
    }
    printf("\n\nCheck to see if device and host are equal\n");
    for (int i = 0; i < N; i++) {
        if (hostc[i] != c[i]) {
            printf("Host c is not equal to device c therefore host and device are not equal");
            compareArray = false;
            break;
        }
        printf("hostc[%i] = %i AND devicec[%i] = %i\n",i,c[i],i,hostc[i]);
    }

    if (compareArray == true) {
   
        printf("\nHostC and DeviceC are the same\n");
    }
    else {
        printf("\nHostC and DeviceC are not the same\n");
    }

    printf("GPU Time using CUDA events: %f ms\n", time);
    printf("CPU Time using CUDA events: %f ms\n", t);
    cudaEventDestroy(start);
    cudaEventDestroy(end);
	cudaEventDestroy(s);
	cudaEventDestroy(e);
    cudaFree(dev_a);
    cudaFree(dev_b);
    cudaFree(dev_c);
   
    return 0;

}