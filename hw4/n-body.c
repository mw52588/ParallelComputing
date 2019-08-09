#include <omp.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#define N 8
#define T 100
#define G 6.670E-11


struct body
{
    double x;           /* coordinates */
    double y;
    double mass;
	double x_velocity;
	double y_velocity;
};

int main(int argc, char *argv) {
	int a, i, t;
	int bodysize = ((int) sizeof(body))
	double x_diff, y_diff, r, F, Fx, Fy = 0;
	body  *NBody, *A;
	NBody = (body *)  malloc((size_t) N*bodysize);
	A = (body *) malloc((size_t) N*bodysize);
	int delta_t = 0;
	for (i=0; i<N; i++)
    {
		Nbody[i].x  = rand()*1.0; //initialize body n x coords.
        Nbody[i].y  = rand()*1.0; //initialize body n y coords.
        Nbody[i].mass = rand()*1.0; //initialize body n mass
		Nbody[i].x_velocity = 0;
		Nbody[i].y_velocity = 0;
		Nbody[i].force_x = 0;
		Nbody[i].force_y = 0;
    }
	
	
	for (t = 0; t < T; t++) { // for each time period
		for (a = 0; a < N; a++) { // for each pair of bodies calculate force on body due to other bodies
			for (i = 0; i < N; i++) {
				if (a != i) { // for different bodies
					x_diff = Nbody[a].x - Nbody[i].x; // compute distance between body a and body i in x direction
					y_diff = Nbody[a].y - Nbody[i].y; // compute distance between body a and body i in y direction
					r = sqrt(pow(x_diff,2) + pow(y_diff,2)); // compute distance r
					F = ((Nbody[a].mass*Nbody[i].mass*G)/(pow(r,2))); // compute force on bodies
					Fx += F*(x_diff/r); // resolve and accumulate force in x direction
					Fy += F*(y_diff/r); // resolve and accumulate force in y direction
					Nbody[a].force_x = Fx;
					Nbody[a].force_y = Fy;
				}
			}
		}
		for (i = 0; i < N; i++) { // for each body, compute and update positions and velocity
			Nbody[i].x_velocity+= Nbody[i].force_x/Nbody[i].mass;
			Nbody[i].y_velocity+= Nbody[i].force_y/Nbody[i].mass;
			Nbody[i].x += Nbody[i].x_velocity +((Nbody[i].force_x/Nbody[i].mass)/2);
			Nbody[i].y += Nbody[i].y_velocity + ((Nbody[i].force_y/Nbody[i].mass/2);	
		}
		
		printf("\tBody  <-->\tMass <--> \tX-Pos <--> \tY-Pos <--> \tX-Vel <--> \tY-Vel\n");
		for (i = 0; i < N; i++) {
			printf("[ %i\t, %.2f\t, %.2f\t, %.2f\t, %.2f\t, %.2f\t", i, Nbody[i].mass, Nbody[i].x, Nbody[i].y, Nbody[i].x_velocity, Nbody[i].y_velocity);
		}
	}
} // end time period