#!/usr/bin/env bash

apt-get update
apt-get install -y apt-utils nano
apt-get upgrade -y
apt-get -y install wget libssl-dev openssl git

#Install Python
cd ~
wget https://www.python.org/ftp/python/3.5.0/Python-3.5.0.tgz
tar xzvf Python-3.5.0.tgz
cd Python-3.5.0
./configure
make && make install
pip3 install --upgrade pip

#Install Miniconda
#cd~
#wget -c https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-ppc64le.sh
#chmod 744 Miniconda3-latest-Linux-ppc64le.sh
#./Miniconda3-latest-Linux-ppc64le.sh -b
#
#~/miniconda3/bin/conda install openblas

# Install Bazel
# Set up Bazel.

# Running bazel inside a `docker build` command causes trouble, cf:
# https://github.com/bazelbuild/bazel/issues/134
# The easiest solution is to set up a bazelrc file forcing --batch.
echo "startup --batch" >>/etc/bazel.bazelrc
# Similarly, we need to workaround sandboxing issues:
# https://github.com/bazelbuild/bazel/issues/418
echo "build --spawn_strategy=standalone --genrule_strategy=standalone" >>/etc/bazel.bazelrc

apt-get install -y build-essential openjdk-8-jdk python zip unzip
cd ~
wget https://github.com/bazelbuild/bazel/releases/download/0.15.0/bazel-0.15.0-dist.zip
mkdir bazel
cd bazel
unzip ../bazel-0.15.0-dist.zip
./compile.sh
mkdir -p ~/bin
cp output/bazel ~/bin
#echo 'export PATH="$PATH:$HOME/bin"' >> ~/.bashrc

#Install TensorFlow
apt-get install -y python-dev python-pip python-wheel python3-numpy python3-dev python3-pip python3-wheel
#apt-get install python-h5py
apt-get install -y libblas-dev liblapack-dev libatlas-base-dev gfortran
apt-get install -y libhdf5-10 libhdf5-serial-dev libhdf5-dev libhdf5-cpp-11
apt-get install -y  libnccl2=2.1.15-1+cuda9.1 libnccl-dev=2.1.15-1+cuda9.1
pip3 install wheel

#export CPATH="/usr/include/hdf5/serial/hdf5.h"
export CPATH="/usr/include/hdf5/serial/"
find . -type f -exec sed -i -e 's^"hdf5.h"^"hdf5/serial/hdf5.h"^g' -e 's^"hdf5_hl.h"^"hdf5/serial/hdf5_hl.h"^g' '{}' \;
ln -s /usr/lib/powerpc64le-linux-gnu/libhdf5_serial.so.10 /usr/lib/powerpc64le-linux-gnu/libhdf5.so
ln -s /usr/lib/powerpc64le-linux-gnu/libhdf5_serial_hl.so.10 /usr/lib/powerpc64le-linux-gnu/libhdf5_hl.so
pip3 --no-cache-dir  install h5py
pip3 install numpy
pip3 install keras
cd ~
git clone https://github.com/tensorflow/tensorflow
cd tensorflow
git checkout r1.11

export PATH="$PATH:$HOME/bin"
# Configure the build for our CUDA configuration.
ENV CI_BUILD_PYTHON python
ENV LD_LIBRARY_PATH /usr/local/cuda/extras/CUPTI/lib64:$LD_LIBRARY_PATH
ENV TF_NEED_CUDA 1
ENV TF_NEED_TENSORRT 1
ENV TF_CUDA_COMPUTE_CAPABILITIES=3.5,5.2,6.0,6.1,7.0
ENV TF_CUDA_VERSION=9.1
ENV TF_CUDNN_VERSION=7

# NCCL 2.x
ENV TF_NCCL_VERSION=2

#cp /root/.tf_configure.bazelrc /root/tensorflow
tensorflow/tools/ci_build/builds/configured GPU
bazel build -c opt --copt=-mavx --config=cuda --cxxopt="-D_GLIBCXX_USE_CXX11_ABI=0" //tensorflow/tools/pip_package:build_pip_package
bazel-bin/tensorflow/tools/pip_package/build_pip_package ../tensorflow_pkg
cd ~/tensorflow_pkg/
pip3 install tensorflow-1.11.0-cp35-cp35m-linux_ppc64le.whl