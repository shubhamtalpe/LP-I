#include <iostream>
#include<omp.h>
#include<stdio.h>
#include<stdlib.h>
#define ll long long
#define N 1000000

using namespace std;
int a[N];

int maximum(int A[])
{
    ll idx;
    int max_val = 0;
#pragma omp parallel for reduction(max:max_val) 
    for (idx = 0; idx < N; idx++)
        if(max_val < A[idx]) max_val = A[idx];

    return max_val;
}

int minimum(int A[])
{
    ll idx;
    int min_val = 0;
#pragma omp parallel for private(idx) reduction(min:min_val) num_threads(4)
    for (idx = 0; idx < N; idx++)
        if(min_val > A[idx]) min_val = A[idx];

    return min_val;
}

int main(int argc, char const* argv[])
{
    double start, end;
    ll sum1 = 0, sum2 = 0;
    int max, min;
    ll i;

    for (i = 0; i < N; ++i)
    {
        a[i] = rand() % 10;
    }

    //Serial block for array sum
    cout << "The Serial Block for Sum:\n";
    start = omp_get_wtime();
    for (i = 0; i < N; ++i)
    {
        sum1 += a[i];
    }
    end = omp_get_wtime();
    cout << "Sum=" << sum1 << "\n";
    cout << "Average=" << float(sum1) / float(N) << "\n";
    cout << "The time taken is: " << (end - start) << " ms" << "\n\n";
    cout << endl;

    //Parallel block for array sum
    cout << "The Parallel Block for Sum:\n";
    start = omp_get_wtime();
#pragma omp parallel for private(i) reduction(+:sum2) num_threads(4)
    for (i = 0; i < N; ++i)
    {
        sum2 += a[i];
    }
    end = omp_get_wtime();
    cout << "Sum=" << sum2 << "\n";
    cout << "Average=" << float(sum2) / float(N) << "\n";
    cout << "The time taken is:" << (end - start) << " ms" << "\n\n";

    //max
    cout << "Serial block for max:\n";
    start = omp_get_wtime();
    max = a[i];
    for (i = 0; i < N; i++)
    {
        max = max > a[i] ? max : a[i];
    }
    end = omp_get_wtime();
    cout << "Max=" << max << "\n";
    cout << "The time taken is:" << (end - start) << " ms" << "\n\n";

    cout << "Parallel Block for Max:\n";
    start = omp_get_wtime();
    max = maximum(a);
    end = omp_get_wtime();
    cout << "Max=" << max << "\n";
    cout << "The time taken is:" << (end - start) << " ms" << "\n\n";


    //min
    cout << "Serial block for Min:\n";
    start = omp_get_wtime();
    min = a[i];
    for (i = 0; i < N; i++)
    {
        min = min < a[i] ? min : a[i];
    }
    end = omp_get_wtime();
    cout << "Min=" << min << "\n";
    cout << "The time taken is:" << (end - start) << " ms" << "\n\n";

    cout << "Parallel Block for Min:\n";
    start = omp_get_wtime();
    min = minimum(a);
    end = omp_get_wtime();
    cout << "Min=" << min << "\n";
    cout << "The time taken is:" << (end - start) << " ms" << "\n\n";
    return 0;
}