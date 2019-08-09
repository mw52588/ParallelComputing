#include <math.h>
#include <stdio.h>

__global__ void kernel( int **dev_h, size_t pitch1, int **dev_g, size_t pitch2, int N) {
	int idx = threadIdx.x + blockIdx.x * blockDim.x;
	int idy = threadIdx.y + blockIdx.y * blockDim.y;
	
	int *rowa = (int*) ((char*)dev_h + idx * pitch1);
	int *rowb = (int*) ((char*)dev_g + idx * pitch2);
	
	int gpu_i = idx;
	int gpu_j;
	
   if (idx < N) {
		
   }
 
    __syncthreads();

		for (int iteration = 0; iteration < limit; iteration++) {
		
		int t = N/4;
		h[t][t] = 37;
		h[t][t+1] = 37;
		h[t+1][t] = 37;
		h[t+1][t+1] = 37;

		for (int i = 1; i < N-1; i++) {
			for (int j = 1; j < N-1; j++){ 
				g[i][j] = .25 * (h[i-1][j] + h[i+1][j] + h[i][j-1] + h[i][j+1]);
				h[i][j] = g[i][j];
				h[t][t] = 37;
				h[t][t+1] = 37;
				h[t+1][t] = 37;
				h[t+1][t+1] = 37;	
			}
		}
	
	}
	
}


int main(void) {
	int size = 0;
	int T = 0;
	int B = 0;
	int limit = 1;	
	
	do {
		printf("Enter number for threads per block:(Maximum number of threads per block is 1024)\n");
        scanf(" %d", &T);getchar();
   	}while (T > 1024 || T <= 0);

   	 do {
		printf("Enter blocks per grid: (Maximum number of blocks per grid is 65535)\n");
      	scanf(" %d", &B);getchar();
  	 }while (B > 65535 || B <= 0);
	
	do {
		printf("Enter size of the square room:\n");
      	scanf(" %d", &size);getchar();
  	}while(size <= 0 );

	 const int N = size ; 
	 int block_size = B;
	double h[N][N];
	double g[N][N];
	int **dev_h;
	int **dev_g;
	double s = N/10;
	
	int left = (int)(s * 3);
	int middle = (int)(s * 4) + left;
	int right = (int)s*7 + 1 + left + middle;
	for (int i = 0; i < N; i++) {
		for (int j = 0; j < N; j++) {
			h[i][j] = 0;
		}
	}

	for (int i = 0; i < N; i++) {
		for (int j = 0; j < N; j++) {
			h[0][i] = 20;
			h[i][0] = 20;
			h[N-1][i] = 20;
			h[i][N-1] = 20;
		}
	}

	for (int i = 0; i < N; i++) {

		if (i >= left && i < middle) {
			h[0][i] = 100;
		}
		else {
			h[0][i] = 20;
		}		
	}
	size_t pitch1;
	cudaMallocPitch(&dev_h, &pitch1, N * sizeof(int), N);
	size_t pitch2;
	cudaMallocPitch(&dev_g, &pitch2, N * sizeof(int), N);
	
	cudaMemcpy2D(dev_h, pitch1, a, N * sizeof(int), N * sizeof(int),N, cudaMemcpyHostToDevice);
    cudaMemcpy2D(dev_g, pitch2, b, N * sizeof(int), N * sizeof(int),N, cudaMemcpyHostToDevice);
	
	kernal <<< n_blocks, block_size >>> (dev_h, pitch1, dev_g, pitch2, N);
	
	for (int iteration = 0; iteration < limit; iteration++) {
		
		int t = N/4;
		h[t][t] = 37;
		h[t][t+1] = 37;
		h[t+1][t] = 37;
		h[t+1][t+1] = 37;

		for (int i = 1; i < N-1; i++) {
			for (int j = 1; j < N-1; j++){ 
				g[i][j] = .25 * (h[i-1][j] + h[i+1][j] + h[i][j-1] + h[i][j+1]);
				h[i][j] = g[i][j];
				h[t][t] = 37;
				h[t][t+1] = 37;
				h[t+1][t] = 37;
				h[t+1][t+1] = 37;	
			}
		}
	
	}
	

	
	for (int i = 0; i < N; i++) {
		for (int j = 0; j < N; j++) {
			printf("\nh[%d][%d] = %f",i,j, h[i][j]);
		}
		printf("\n");
	}       

	return 0;
}