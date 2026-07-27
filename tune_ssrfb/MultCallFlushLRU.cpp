#include <iostream>
#include <cstdlib>
#include <omp.h>
#include <plasma_core_blas.h>


// Generate random number matrix
void Gen_rand_mat(const int m, const int n, double *A)
{
	srand(20210604);

	#pragma omp parallel for
	for (int i=0; i<m*n; i++)
		A[i] = 1.0 - 2.0*(double)rand() / RAND_MAX;
}

// 既定値（引数省略時に使う）。MAT_SIZE と N_IT は実行時引数で上書きできる。
#define DEFAULT_MAT_SIZE 16384
#define DEFAULT_N_IT 50

int main(const int argc, const char **argv)
{
	if (argc < 3)
	{
		std::cerr << "usage: FlushLRU [min NB size] [max NB size] "
		             "[MAT_SIZE=" << DEFAULT_MAT_SIZE << "] "
		             "[N_IT=" << DEFAULT_N_IT << "]\n";
		return EXIT_FAILURE;
	}

	const int minNB = atoi(argv[1]);
	const int maxNB = atoi(argv[2]);
	// MAT_SIZE / N_IT を実行時引数で指定できるようにした（省略時は既定値）。
	const int mat_size = (argc > 3) ? atoi(argv[3]) : DEFAULT_MAT_SIZE;
	const int n_it     = (argc > 4) ? atoi(argv[4]) : DEFAULT_N_IT;

	if (minNB <= 0 || maxNB <= 0 || mat_size <= 0 || n_it <= 0)
	{
		std::cerr << "error: minNB, maxNB, MAT_SIZE, N_IT はすべて正の整数で指定してください。\n";
		return EXIT_FAILURE;
	}
	// A は A1, A2, V の3タイル分（各 maxNB*maxNB）を格納できる必要がある。
	if ((long)mat_size * mat_size < 3L * maxNB * maxNB)
	{
		std::cerr << "error: MAT_SIZE^2 (" << (long)mat_size * mat_size
		          << ") < 3*maxNB*maxNB (" << 3L * maxNB * maxNB
		          << ")。MAT_SIZE を大きくするか maxNB を小さくしてください。\n";
		return EXIT_FAILURE;
	}

	int nb;   // Tile size
	int ib;   // Inner block size
	double timer;

	double* A = new double [(long)mat_size * mat_size];
	double* T = new double[maxNB * maxNB];
	double* W = new double[maxNB * maxNB];

	// Generate random matirx
	Gen_rand_mat(mat_size, mat_size, A);
	Gen_rand_mat(maxNB, maxNB, T);

	for (nb = minNB; nb <= maxNB; nb+=32)
	{
		for (ib = 2; ib <= nb/2; ib++)
		{
			if (nb % ib != 0)
				continue;

			double* A1 = A;
			double* A2 = A + nb*nb;
			double* V  = A + 2*nb*nb;

			timer = omp_get_wtime();
			for (int i=0; i<n_it; i++)
			{
				plasma_core_dtsmqr(PlasmaLeft, PlasmaNoTrans, nb, nb, nb, nb, nb, ib,
					A1, nb, A2, nb, V, nb, T, ib, W, ib);
			}
			timer = omp_get_wtime() - timer;
			std::cout << nb << ", " << ib << ", " << timer / n_it << std::endl;
		}
	}

	delete [] A;
	delete [] T;
	delete [] W;

	return EXIT_SUCCESS;
}
