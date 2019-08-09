#include <stdio.h>
#include <string.h>

__global__ void kernel( int **dev_a , size_t pitch1, int **dev_b , size_t pitch2, int **dev_c , size_t pitch3, int N) {
     int idx=threadIdx.x+blockIdx.x*blockDim.x;
      int idy=threadIdx.y+blockIdx.y*blockDim.y;


     //Pitch Slices per Row for 2D Array
     int* rowa = (int*)((char*)dev_a + idx*pitch1);
     int* rowb = (int*)((char*)dev_b + idx*pitch2);
     int* rowc = (int*)((char*)dev_c + idx*pitch3);
       
      int gpu_i =idx;
      int gpu_j;
           for(gpu_j = 0;gpu_j< N;gpu_j++)
            {
                int sum=0;
              for (int gpu_k = 0; gpu_k < N; gpu_k++) {
                    int* rowb = (int*)((char*)dev_b + gpu_k*pitch2);
                  sum+= rowa[gpu_k] * rowb[gpu_i];
              }
              rowc[gpu_j] =sum;
           }
 
    __syncthreads();
   
}

int main(int argc, char *argv[]) {
        int i;
        int j;
        int k;
	int size = 0;
	int B = 0;
	int T = 0;
        //Kernel Variables
       

        //CUDA GRID BLOCK SIZE AND NUMBER OF BLOCKS

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
      	  scanf(" %d", &size);getchar();
  	  }while(size <= 0 || size > B * T);
	


	
        int block_size = B;
        const int N = size ;  // Number of elements in arrays


        int n_blocks = N/block_size + (N%block_size == 0 ? 0:1);
	 int a[N][N];
	int **dev_a;
        int b[N][N];
	int **dev_b;
        int c[N][N];
	int **dev_c;

		
	 for (i = 0; i < N; i++) {
             for (j = 0; j < N; j++) {
                  a[i][j] = 1;
                  b[i][j] = j;
                  c[i][j] = 0;
             }
        }
        printf("\n A = ");
        for (i = 0; i < N; i++) {
             printf("\n");
             for (j = 0; j < N; j++) {
                  printf(" %d ",a[i][j]);
             }
        }
        printf("\n B = ");
        for (i = 0; i < N; i++) {
             printf("\n");
             for (j = 0; j < N; j++) {
                  printf(" %d ",b[i][j]);
             }
        }

        // Memory Allocation
        size_t pitch1;
         cudaMallocPitch(&dev_a, &pitch1, N * sizeof(int), N);
         // Allocate 2Darray on device
        size_t pitch2;
         cudaMallocPitch(&dev_b, &pitch2, N * sizeof(int), N);
         // Allocate 2Darray on device
        size_t pitch3;
         cudaMallocPitch(&dev_c, &pitch3, N * sizeof(int), N);
         // Allocate 2Darray on device

	cudaEvent_t start, end, s, e;                    // using cuda events to measure time
    	float time , t;                               // which is applicable for asynchronous code also

    	cudaEventCreate(&start);                 // instrument code to measure start time
    	cudaEventCreate(&end);
	cudaEventCreate(&s);                 // instrument code to measure start time
    	cudaEventCreate(&e);
	
        // Copy Data to device from host
        cudaMemcpy2D(dev_a, pitch1, a, N * sizeof(int), N * sizeof(int),N, cudaMemcpyHostToDevice);
        cudaMemcpy2D(dev_b, pitch2, b, N * sizeof(int), N * sizeof(int),N, cudaMemcpyHostToDevice);
        cudaMemcpy2D(dev_c, pitch3, c, N * sizeof(int), N * sizeof(int),N, cudaMemcpyHostToDevice);

        // call kernel
	 cudaEventRecord(start, 0 );
        kernel <<< n_blocks, block_size >>>( dev_a,pitch1, dev_b,pitch2, dev_c,pitch3, N);
	 cudaEventRecord(end, 0 );                 // instrument code to measure end time
   	 cudaEventSynchronize(end);
    	 cudaEventElapsedTime(&time, start, end);

        // Retrieve result from device and store it in host array
        cudaMemcpy2D(a,N * sizeof(int), dev_a,pitch1,N * sizeof(int),N, cudaMemcpyDeviceToHost);
        cudaMemcpy2D(b,N * sizeof(int), dev_b,pitch2,N * sizeof(int),N, cudaMemcpyDeviceToHost);
        cudaMemcpy2D(c,N * sizeof(int), dev_c,pitch3,N * sizeof(int),N, cudaMemcpyDeviceToHost);

        


        printf("\n C = ");
        for (i = 0; i < N; i++) {
             printf("\n");
             for (j = 0; j < N; j++) {
                  printf(" %d ",c[j][i]);
             }
        }
	cudaEventRecord(s, 0);
	 for (int i = 0; i < N; i++) {
		for (int j = 0; j < N; j++) {
			int sum = 0;
			for (int k = 0; k < N; k++) {
				sum += a[i][k] * b[k][j];
			}
		c[i][j] = sum;
		}
	}
	cudaEventRecord(e, 0 );                 // instrument code to measure end time
    	cudaEventSynchronize(e);
    	cudaEventElapsedTime(&t, s, e);


	  printf("\n C = ");
        for (i = 0; i < N; i++) {
             printf("\n");
             for (j = 0; j < N; j++) {
                  printf(" %d ",c[i][j]);
             }
        }


	printf("\n\nGPU Time using CUDA events: %f ms\n", time);
    	printf("CPU Time using CUDA events: %f ms\n", t);
    	cudaEventDestroy(start);
    	cudaEventDestroy(end);
	cudaEventDestroy(s);
	cudaEventDestroy(e);
	// Free GPU Variables
        cudaFree(dev_a);
        cudaFree(dev_b);
        cudaFree(dev_c);
	
       return 0;

}
