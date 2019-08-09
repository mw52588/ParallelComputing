#include <stdio.h>
#include <cuda.h>
#include <time.h>

void random_ints(int* a, int N)
{
   int i;
   for (i = 0; i < N; ++i)
    a[i] = rand();
}

void SeqMatMult(int* a, int* b, int* c, int N)
{
	int sum = 0;
	int i, j, k = 0;
	for (i = 0; i < N; ++i) {
		for (j = 0; j < N; ++j) {
			for (k = 0; k < N; ++k) {
				c[i+N*j] += a[i+N*k] * b[k+N*j];
			}
		}
	}
}

__global__ void multiply( int *a, int *b, int *c ) {
	__shared__ int temp[THREADS_PER_BLOCK];
	int index = threadIdx.x + blockIdx.x * blockDim.x;
	temp[threadIdx.x] = a[index] * b[index];
	__syncthreads();
	if( 0 == threadIdx.x ) {
		int sum = 0;
		for( inti= 0; i< THREADS_PER_BLOCK; i++ )
			sum += temp[i];
		atomicAdd( c , sum );
	}
}


int main(void){
    int N = 0; //array Size.
    int T = 0;
    int B = 0;
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

    int *a, *b, *c;
    int *dev_a, *dev_b, *dev_c;
	int size = N * sizeof( int );
	
	cudaMalloc( (void**)&dev_a, size );
	cudaMalloc( (void**)&dev_b, size );
	cudaMalloc( (void**)&dev_c, sizeof( int ) );
    
	a = (int *)malloc( size );
	b = (int *)malloc( size );
	c = (int *)malloc( sizeof( int ) );
	
	random_ints(a, N);
	random_ints(b, N);
	
	// copy inputs to device
	cudaMemcpy( dev_a, a, size, cudaMemcpyHostToDevice);
	cudaMemcpy( dev_b, b, size, cudaMemcpyHostToDevice);

    
    multiply<<<N/T, B>>>(dev_a, dev_b, dev_c, N);

	cudaMemcpy(c, dev_c, sizeof(int), cudaMemcpyDeviceToHost);
	
	cudaFree(dev_a);
	cudaFree(dev_b);
	cudaFree(dev_c);

	free(a);
	free(b);
	free(c);
		
    return 0;
}








