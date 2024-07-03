ARG BASE=python:3.13.0b2
FROM ${BASE}

ENV CUDA_VERSION 10.0.130
ENV CUDA_PKG_VERSION 10-0=$CUDA_VERSION-1
ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64

ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
ENV NVIDIA_REQUIRE_CUDA "cuda>=10.0 brand=tesla,driver>=384,driver<385 brand=tesla,driver>=410,driver<411"
ENV NCCL_VERSION 2.4.2
ENV CUDNN_VERSION 7.6.0.64

LABEL com.nvidia.cuda.version="${CUDA_VERSION}"
LABEL com.nvidia.cudnn.version="${CUDNN_VERSION}"
LABEL com.nvidia.volumes.needed="nvidia_driver"

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        gnupg2 \
        curl \
        ca-certificates \
    && curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub | apt-key add - \
    && echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/cuda.list \
    && echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list \
    && apt-get purge --autoremove -y curl \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        cuda-cudart-$CUDA_PKG_VERSION \
        cuda-compat-10-0 \
    && ln -s cuda-10.0 /usr/local/cuda \
    && echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf \
    && echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf \
    && apt-get install -y --no-install-recommends \
        cuda-toolkit-10-0 \
        cuda-libraries-$CUDA_PKG_VERSION \
        cuda-nvtx-$CUDA_PKG_VERSION \
        libnccl2=$NCCL_VERSION-1+cuda10.0 \
        libcudnn7=$CUDNN_VERSION-1+cuda10.0 \
    && apt-mark hold libnccl2 \
    && apt-mark hold libcudnn7 \
    && rm -rf /var/lib/apt/lists/*
