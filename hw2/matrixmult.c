#define N 512
#include <stdio.h>
#include <math.h>
#include <sys/time.h>
print_results(char *prompt, float a[N][N]);
int main(int argc, char *argv[])
{
	int i, j, k, blksz;
	float a[N][N], b[N][N], c[N][N];
	char *usage = "Usage: %s file\n";
	FILE *fd;
	double elapsed_time, start_time, end_time;
	struct timeval tv1, tv2;
	if (argc < 2) {
		fprintf (stderr, usage, argv[0]);
		return -1;
	}
	if ((fd = fopen (argv[1], "r")) == NULL) {
		fprintf (stderr, "%s: Cannot open file %s for reading.\n",argv[0], argv[1]);
		fprintf (stderr, usage, argv[0]);
		return -1;
	}
	// Read input from file for matrices a and b.
	// The I/O is not timed because this I/O needs
	// to be done regardless of whether this program
	// is run sequentially on one processor or in
	// parallel on many processors. Therefore, it is
	// irrelevant when considering speedup.
	for (i = 0; i < N; i++)
		for (j = 0; j < N; j++)
			fscanf (fd, "%f", &a[i][j]);
	for (i = 0; i < N; i++)
		for (j = 0; j < N; j++)
			fscanf (fd, "%f", &b[i][j]);
	TODO: Add a barrier prior to the time stamp.
	// Take a time stamp
	gettimeofday(&tv1, NULL);
	TODO: Scatter the input matrices a and b.
	TODO: Add code to implement matrix multiplication (C=AxB) in parallel.
	for (i=0; i<N; i++) {
  		for (j=0; j<N; j++) {
    			c[i][j] = 0.0;
    			for (j=0; j<NCA; j++) {
      				c[i][j] = c[i][j] + a[i][j] * b[j][k];
			}
    		}
	}

	TODO: Gather partial result back to the master process.
	// Take a time stamp. This won't happen until after the master
	// process has gathered all the input from the other processes.
	gettimeofday(&tv2, NULL);
	elapsed_time = (tv2.tv_sec - tv1.tv_sec) +((tv2.tv_usec - tv1.tv_usec) / 1000000.0);
	printf ("elapsed_time=\t%lf (seconds)\n", elapsed_time);
	// print results
	print_results("C = ", c);
}

print_results(char *prompt, float a[N][N])
{
	int i, j;
	printf ("\n\n%s\n", prompt);
	for (i = 0; i < N; i++) {
		for (j = 0; j < N; j++) {
			printf(" %.2f", a[i][j]);
		}
		printf ("\n");
	}
	printf ("\n\n");
}
