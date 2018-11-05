FROM nvidia/cuda-ppc64le:9.1-cudnn7-devel-ubuntu16.04
LABEL maintainer="Eugene Ilyushin <eugene.ilyushin@gmail.com>"

#COPY ./install.sh /root/
#COPY ./.tf_configure.bazelrc /root/tensorflow
#RUN cd ~ && \
#    chmod +x install.sh && \
#    ./install.sh

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y apt-utils  && \
    apt-get -y install wget curl unzip libssl-dev openssl git && \
    wget https://www.python.org/ftp/python/3.6.7/Python-3.6.7.tgz && \
    tar xzvf Python-3.6.7.tgz && \
    cd Python-3.6.7 && \
    ./configure && \
    make && \
    make install && \
    pip3 install --upgrade pip && \
    rm -rf ~/Python-3.6.7 Python-3.6.7.tgz
#    pip3 install jupyter

# Install Bazel
## Set up Bazel.
#
## Running bazel inside a `docker build` command causes trouble, cf:
## https://github.com/bazelbuild/bazel/issues/134
## The easiest solution is to set up a bazelrc file forcing --batch.
#RUN echo "startup --batch" >>/etc/bazel.bazelrc
## Similarly, we need to workaround sandboxing issues:
## https://github.com/bazelbuild/bazel/issues/418
#RUN echo "build --spawn_strategy=standalone --genrule_strategy=standalone" \
#    >>/etc/bazel.bazelrc
## Install the most recent bazel release.
#ENV BAZEL_VERSION 0.15.0
#WORKDIR /
#RUN mkdir /bazel && \
#    cd /bazel && \
#    curl -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.133 Safari/537.36" -fSsL -O https://github.com/bazelbuild/bazel/releases/download/$BAZEL_VERSION/bazel-$BAZEL_VERSION-installer-linux-x86_64.sh && \
#    curl -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.133 Safari/537.36" -fSsL -o /bazel/LICENSE.txt https://raw.githubusercontent.com/bazelbuild/bazel/master/LICENSE && \
#    chmod +x bazel-*.sh && \
#    ./bazel-$BAZEL_VERSION-installer-linux-x86_64.sh && \
#    cd / && \
#    rm -f /bazel/bazel-$BAZEL_VERSION-installer-linux-x86_64.sh


RUN apt-get update --fix-missing && apt-get upgrade -y && \
    apt-get install -y build-essential openjdk-8-jdk python zip unzip  && \
    cd ~ && \
    wget https://github.com/bazelbuild/bazel/releases/download/0.15.0/bazel-0.15.0-dist.zip && \
    mkdir bazel && \
    cd bazel && \
    unzip ../bazel-0.15.0-dist.zip && \
    ./compile.sh && \
    mkdir -p ~/bin && \
    cp output/bazel ~/bin && \
    rm -rf ~/bazel-0.15.0-dist.zip bazel

# Install Tensorflow
RUN apt-get install -y python-dev python-pip python-wheel python3-numpy python3-dev python3-pip python3-wheel && \
    apt-get install -y libblas-dev liblapack-dev libatlas-base-dev gfortran && \
    apt-get install -y libhdf5-10 libhdf5-serial-dev libhdf5-dev libhdf5-cpp-11 && \
#    apt-get install -y  libnccl2=2.1.15-1+cuda9.1 libnccl-dev=2.1.15-1+cuda9.1 && \
    pip3 install wheel

# Install h5py
ENV CPATH="/usr/include/hdf5/serial/"
RUN find . -type f -exec sed -i -e 's^"hdf5.h"^"hdf5/serial/hdf5.h"^g' -e 's^"hdf5_hl.h"^"hdf5/serial/hdf5_hl.h"^g' '{}' \; && \
    ln -s /usr/lib/powerpc64le-linux-gnu/libhdf5_serial.so.10 /usr/lib/powerpc64le-linux-gnu/libhdf5.so && \
    ln -s /usr/lib/powerpc64le-linux-gnu/libhdf5_serial_hl.so.10 /usr/lib/powerpc64le-linux-gnu/libhdf5_hl.so && \
    pip3 --no-cache-dir  install h5py


RUN pip3 install numpy && \
    pip3 install keras && \
    cd ~ && \
    git clone https://github.com/tensorflow/tensorflow

ENV PATH $PATH:$HOME/bin
RUN echo export PATH="$PATH:$HOME/bin" >> ~/.bashrc

RUN cd ~ && \
    wget https://powerci.osuosl.org/job/TensorFlow_PPC64LE_GPU_Release_Build/lastSuccessfulBuild/artifact/tensorflow_pkg/tensorflow_gpu-1.11.0-cp36-cp36m-linux_ppc64le.whl
RUN apt-get install -y libfreetype6-dev pkg-config libpng12-dev
RUN cd ~ && \pip3 install tensorflow_gpu-1.11.0-cp36-cp36m-linux_ppc64le.whl


## Configure the build for our CUDA configuration.
#ENV CI_BUILD_PYTHON python
#ENV LD_LIBRARY_PATH /usr/local/cuda/extras/CUPTI/lib64:$LD_LIBRARY_PATH
#ENV TF_NEED_CUDA 1
#ENV TF_NEED_TENSORRT 1
#ENV TF_CUDA_COMPUTE_CAPABILITIES=3.5,5.2,6.0,6.1,7.0
#ENV TF_CUDA_VERSION=9.0
#ENV TF_CUDNN_VERSION=7
#
## NCCL 2.x
#ENV TF_NCCL_VERSION=2

#RUN cd ~/tensorflow && \
#    git checkout r1.11 && \
#
#    bazel build \
#        --action_env PYTHON_BIN_PATH="/usr/local/bin/python3" \
#        --action_env PYTHON_LIB_PATH="/usr/local/lib/python3.6/site-packages" \
#        --python_path="/usr/local/bin/python3" \
#        --action_env OMP_NUM_THREADS="1" \
#        --define with_gcp_support=true \
#        --define with_hdfs_support=true \
#        --define with_aws_support=true \
#        --define with_kafka_support=true \
#        --define with_xla_support=true \
#        --define with_gdr_support=true \
#        --define with_verbs_support=true \
#        --define with_ngraph_support=true
#        --action_env TF_NEED_OPENCL_SYCL="0" \
#        --action_env TF_NEED_CUDA="1" \
#        --action_env CUDA_TOOLKIT_PATH="/usr/local/cuda" \
#        --action_env TF_CUDA_VERSION="9.1" \
#        --action_env CUDNN_INSTALL_PATH="/usr/lib/powerpc64le-linux-gnu" \
#        --action_env TF_CUDNN_VERSION="7" \
#        --action_env TF_NCCL_VERSION="1" \
#        --action_env TF_CUDA_COMPUTE_CAPABILITIES="6.0" \
#        --action_env LD_LIBRARY_PATH="/usr/local/nvidia/lib:/usr/local/nvidia/lib64" \
#        --action_env TF_CUDA_CLANG="0" \
#        --action_env GCC_HOST_COMPILER_PATH="/usr/bin/gcc" \
#        --config=cuda \
#        --define grpc_no_ares=true \
#        --copt=-mcpu=power8 \
#        --copt=-mtune=power8 \
#        --define with_default_optimizations=true \
#        //tensorflow/tools/pip_package:build_pip_package && \
#    bazel-bin/tensorflow/tools/pip_package/build_pip_package ../tensorflow_pkg && \
#    cd ~/tensorflow_pkg/ && \
#    pip3 install tensorflow-1.11.0-cp35-cp35m-linux_ppc64le.whl && \
#    rm -rf ~/tensorflow ~/tensorflow_pkg

RUN pip3 install sympy scipy sklearn matplotlib

RUN cd ~ && \
    wget --quiet https://repo.anaconda.com/archive/Anaconda3-5.1.0-Linux-ppc64le.sh -O ~/anaconda.sh && \
    /bin/bash ~/anaconda.sh -b -p /opt/conda && \
    rm ~/anaconda.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

CMD [ "/bin/bash" ]

#COPY start-notebook.sh /usr/local/bin/
#RUN chmod +x /usr/local/bin/start-notebook.sh
#
#CMD ["start-notebook.sh"]
