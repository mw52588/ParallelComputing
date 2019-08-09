#define N 512
#include <stdio.h>
#include <math.h>
#include <sys/time.h>
print_results(char *prompt, float a[N][N]);

int main(int argc, char *argv[])
{
	int size, /* number of tasks in partition */
	rank, /* a task identifier */
	numworkers, /* number of worker tasks */
	source, /* task id of message source */
	dest, /* task id of message destination */
	nbytes, /* number of bytes in message */
	mtype, /* message type */
	intsize, /* size of an integer in bytes */
	dbsize, /* size of a double float in bytes */
	rows, /* rows of matrix A sent to each worker */
	averow, extra, offset, /* used to determine rows sent to each worker */
	i, j, k, /* misc */
	count, sum;
	float a[N][N], b[N][N], c[N][N];
	char *usage = "Usage: %s file\n";
	FILE *fd;
	double elapsed_time, start_time, end_time;
	struct timeval tv1, tv2;
	
	MPI_Init(&argc, &argv);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank)
	MPI_Comm_size(MPI_COMM_WORLD, &size);
	/*
	if (argc < 2) {
		fprintf (stderr, usage, argv[0]);
		return -1;
	}
	if ((fd = fopen (argv[1], "r")) == NULL) {
		fprintf (stderr, "%s: Cannot open file %s for reading.\n",argv[0], argv[1]);
		fprintf (stderr, usage, argv[0]);
		return -1;
	}

	*/
	// Read input from file for matrices a and b.
	// The I/O is not timed because this I/O needs
	// to be done regardless of whether this program
	// is run sequentially on one processor or in
	// parallel on many processors. Therefore, it is
	// irrelevant when considering speedup.
	if(rank == 0) {
		for (i = 0; i < N; i++)
			for (j = 0; j < N; j++)
				a[i][j]) = i * j;
		for (i = 0; i < N; i++)
			for (j = 0; j < N; j++)
				b[i][j] = i *j;
		//Transpose matrix B.
	}
	
	//TODO: Add a barrier prior to the time stamp.
	MPI_Barrier(MPI_COMM_WORLD);
	
	// Take a time stamp
	gettimeofday(&tv1, NULL);
	
	//TODO: Scatter the input matrices a and b.
	MPI_Scatter(a, N*N/size, MPI_INT, a, N*N/size, MPI_INT, 0, MPI_COMM_WORLD);
	MPI_Bcast(b, N*N, MPI_INT, 0, MPI_COMM_WORLD);
	//TODO: Add code to implement matrix multiplication (C=AxB) in parallel.
		
	for (i = 0; i < N/size; i++)
		for (j = 0; j < N; j++) {
			c[i][j] = 0;
				for (k = 0; k < N; k++)
					c[i][j] += a[i][k] * b[k][j];
		}
	MPI_Gather(c, N*N/size, MPI_INT, c, N*N/size,MPI_INT, 0, MPI_COMM_WORLD);
	
	
	// Take a time stamp. This won't happen until after the master
	// process has gathered all the input from the other processes.
	gettimeofday(&tv2, NULL);
	

	elapsed_time = (tv2.tv_sec - tv1.tv_sec) +((tv2.tv_usec - tv1.tv_usec) / 1000000.0);
	printf ("elapsed_time=\t%lf (seconds)\n", elapsed_time);
	// print results
	if (rank == 0) {
		print_results("C = ", c);
	}
	MPI_Finalize();
	return 0;
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