#include<iostream>
#include<math.h>

#define n 1000

using namespace std;

//Calculate min element
__global__ void minimum(int *input){
    int threadId = threadIdx.x; //Thread Id
    int stepSize = 1;
    int numberOfThreads = blockDim.x;

    while(numberOfThreads > 0){
        if(threadId < numberOfThreads){
            int first = threadId*stepSize*2;
            int second = first + stepSize;
            if(input[second] < input[first]) input[first] = input[second];
        }
        stepSize <<= 1; //Multiply step size by 2
        numberOfThreads >>= 1; //Divide number of threads by 2
    }
}

//Calculate max element
__global__ void maximum(int *input){
    int threadId = threadIdx.x; //Thread Id
    int stepSize = 1;
    int numberOfThreads = blockDim.x;

    while(numberOfThreads > 0){
        if(threadId < numberOfThreads){
            int first = threadId*stepSize*2;
            int second = first + stepSize;
            if(input[second] > input[first]) input[first] = input[second];
        }
        stepSize <<= 1; //Multiply step size by 2
        numberOfThreads >>= 1; //Divide number of threads by 2
    }
}

//Calculate sum of all elements
__global__ void sum(int *input){
    int threadId = threadIdx.x; //Thread Id
    int stepSize = 1;
    int numberOfThreads = blockDim.x;

    while(numberOfThreads > 0){
        if(threadId < numberOfThreads){
            int first = threadId*stepSize*2;
            int second = first + stepSize;
            input[first] += input[second];
        }
        stepSize <<= 1; //Multiply step size by 2
        numberOfThreads >>= 1; //Divide number of threads by 2
    }
}

//Overload sum function for float
__global__ void sum(float *input){
    int threadId = threadIdx.x; //Thread Id
    int stepSize = 1;
    int numberOfThreads = blockDim.x;

    while(numberOfThreads > 0){
        if(threadId < numberOfThreads){
            int first = threadId*stepSize*2;
            int second = first + stepSize;
            input[first] += input[second];
        }
        stepSize <<= 1; //Multiply step size by 2
        numberOfThreads >>= 1; //Divide number of threads by 2
    }
}

__global__ void meanDiffSq(float *input, float mean){
    input[threadIdx.x] -= mean;
    input[threadIdx.x] *= input[threadIdx.x];
}

void copyIntToFloat(float *dest, int *src, int size){
    for(int i=0; i<size; i++){
        dest[i] = float(src[i]);
    }
}

//initialize array with random elements
void random_ints(int *input, int size){
    for(int i=0; i<size; i++){
        input[i] = rand()%100; // Generate random elements in range 0-99
    }
}

int main(){
    int size = n*sizeof(int);
    cudaEvent_t start, stop;
    int *arr;
    int *arr_d, result;
    float time;

    arr = (int *)malloc(size); //Allocate memory on host

    random_ints(arr, n); //Initialize arr with random elements

    cudaMalloc((void**)&arr_d, size); //Allocate memory on device

    //Calculate Minimum element
    cudaMemcpy(arr_d, arr, size, cudaMemcpyHostToDevice); //Copy elements from host to device
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start, 0);
    minimum<<<1, n/2>>>(arr_d); //Calculate min element
    cudaEventRecord(stop, 0);
    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&time, start, stop);
    cudaMemcpy(&result, arr_d, sizeof(int), cudaMemcpyDeviceToHost); //Copy first element from device to host
    cout << "Minimum element is : " << result << endl;
    cout << "Time taken : " << time << " ms" << endl << endl;

    //Calculate Maximum element
    cudaMemcpy(arr_d, arr, size, cudaMemcpyHostToDevice); //Copy elements from host to device
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start, 0);
    maximum<<<1, n/2>>>(arr_d); //Calculate max element
    cudaEventRecord(stop, 0);
    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&time, start, stop);
    cudaMemcpy(&result, arr_d, sizeof(int), cudaMemcpyDeviceToHost); //Copy first element from device to host
    cout << "Maximum element is : " << result << endl;
    cout << "Time taken : " << time << " ms" << endl << endl;

    //Calculate Sum of all elements
    cudaMemcpy(arr_d, arr, size, cudaMemcpyHostToDevice); //Copy elements from host to device
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start, 0);
    sum<<<1, n/2>>>(arr_d); //Calculate sum
    cudaEventRecord(stop, 0);
    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&time, start, stop);
    cudaMemcpy(&result, arr_d, sizeof(int), cudaMemcpyDeviceToHost); //Copy first element from device to host
    cout << "Sum of all element is : " << result << endl;
    cout << "Time taken : " << time << " ms" << endl << endl;

    //Calculate mean
    float mean = float(result)/n;
    cout << "Mean of all element is : " << mean << endl << endl;

    //Calculate standard deviation
    float *arr_float;
    float *arr_std, stdValue;

    arr_float = (float*)malloc(n*sizeof(float));
    cudaMalloc((void**)&arr_std, n*sizeof(float));
    copyIntToFloat(arr_float, arr, n); //Initialize float array
    
    cudaMemcpy(arr_std, arr_float, n*sizeof(float), cudaMemcpyHostToDevice); //Copy elements from host to device
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start, 0);
    meanDiffSq<<<1, n>>>(arr_std, mean); //Calculate mean difference
    sum<<<1, n/2>>>(arr_std); //Calculate sum
    cudaEventRecord(stop, 0);
    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&time, start, stop);
    cudaMemcpy(&stdValue, arr_std, sizeof(float), cudaMemcpyDeviceToHost); //Copy first element from device to host
    stdValue /= n;
    stdValue = sqrt(stdValue);
    cout << "Standard deviation is : " << stdValue << endl;
    cout << "Time taken : " << time << " ms" << endl << endl;

    cudaFree(arr_d);
    cudaFree(arr_std);
    free(arr);
    free(arr_float);
}