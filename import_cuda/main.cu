#include "cuda_runtime.h"
#include "cub/cub.cuh"
#include <cstdio>


template <int BLOCK_SIZE>
__global__ void reduce_sum(float *d_x, float *d_y, int count) {
  int g_id = threadIdx.x + blockDim.x * blockIdx.x;
  using BlockRudce = cub::BlockReduce<float, BLOCK_SIZE>;
  __shared__ typename BlockRudce::TempStorage t_sum;
  float x = g_id < count ? d_x[g_id] : 0.0f;
  __syncthreads();
  float sum = BlockRudce(t_sum).Reduce(x, cub::Sum());
  if (threadIdx.x == 0)
    atomicAdd(d_y, sum);
}

float ReduceSum(float *x, int count, cudaStream_t stream = 0) {
    float sum = 0.0f;
    float *h_x, *d_x_and_y;
    cudaError_t status = cudaMallocHost(&h_x, sizeof(float) * count);

    if (status != cudaSuccess) {
      printf("fail to malloc host\n");
      return sum;
    }
    

    status = cudaMalloc(&d_x_and_y, sizeof(float) * (count + 1));
    if (status != cudaSuccess) {
      cudaFree(h_x);
      printf("fail to malloc device\n");
      return sum;
    }

    for (int i = 0; i < count; ++i) {
        h_x[i] = x[i];
    }

    const int nBlock = (count + 383) / 384;
    status = cudaMemcpyAsync(d_x_and_y, h_x, count * sizeof(float), cudaMemcpyHostToDevice, stream);
    if (status != cudaSuccess) {
      printf("fail to copy to device\n");
      goto error_break;
    }
    
    reduce_sum<384><<<nBlock, 384, 0, stream>>>(d_x_and_y, d_x_and_y + count, count);
    status = cudaMemcpyAsync(h_x, d_x_and_y + count, sizeof(float), cudaMemcpyDeviceToHost, stream);
        if (status != cudaSuccess) {
        
      printf("fail to copy to host\n");
      goto error_break;
    }

    status = cudaStreamSynchronize(stream);
    if (status != cudaSuccess) {
        
      printf("fail to sync\n");
      goto error_break;
    }

    
    sum = h_x[0];


    error_break:
      cudaFree(h_x);
      cudaFree(d_x_and_y);
      
      return sum;
    

}

int main() {

    float *x = new float[384];
    for (int i = 0; i < 384; ++i) {
        x[i] = i * 0.01f;
    }

    cudaStream_t stream;
    cudaStreamCreate(&stream);
    float sum = ReduceSum(x, 384, stream);

    float true_sum = (383) * (384 / 2) * 0.01f;

    cudaStreamDestroy(stream);
    printf("%f %f\n", sum, true_sum);

    delete x;
    return 0;
}