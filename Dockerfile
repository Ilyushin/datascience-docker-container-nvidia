FROM nvidia/cuda-ppc64le:9.1-cudnn7-devel-ubuntu16.04
LABEL maintainer="Eugene Ilyushin <eugene.ilyushin@gmail.com>"

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y apt-utils  && \
    apt-get -y install wget libssl-dev openssl git && \
    wget https://www.python.org/ftp/python/3.5.0/Python-3.5.0.tgz && \
    tar xzvf Python-3.5.0.tgz && \
    cd Python-3.5.0 && \
    ./configure && \
    make && \
    make install && \
    pip3 install --upgrade pip
#    pip3 install jupyter

## Install mini-conda
#RUN cd ~  && \
#    wget -c https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-ppc64le.sh  && \
#    chmod 744 Miniconda3-latest-Linux-ppc64le.sh  && \
#    ./Miniconda3-latest-Linux-ppc64le.sh -b
#
## Install openBLAS
#RUN ~/miniconda3/bin/conda install openblas

# Install Bazel
RUN apt-get update --fix-missing && apt-get upgrade -y && \
    apt-get install -y build-essential openjdk-8-jdk python zip unzip  && \
    cd ~ && \
    wget https://github.com/bazelbuild/bazel/releases/download/0.15.0/bazel-0.15.0-dist.zip && \
    mkdir bazel && \
    cd bazel && \
    unzip ../bazel-0.15.0-dist.zip && \
    ./compile.sh && \
    mkdir -p ~/bin && \
    cp output/bazel ~/bin

# Install Tensorflow
RUN apt-get install -y python-dev python-pip python-wheel python3-numpy python3-dev python3-pip python3-wheel && \
    apt-get install -y libblas-dev liblapack-dev libatlas-base-dev gfortran && \
    apt-get install -y libhdf5-10 libhdf5-serial-dev libhdf5-dev libhdf5-cpp-11 && \
    pip3 install wheel

ENV CPATH="/usr/include/hdf5/serial/"
RUN find . -type f -exec sed -i -e 's^"hdf5.h"^"hdf5/serial/hdf5.h"^g' -e 's^"hdf5_hl.h"^"hdf5/serial/hdf5_hl.h"^g' '{}' \; && \
    ln -s /usr/lib/powerpc64le-linux-gnu/libhdf5_serial.so.10 /usr/lib/powerpc64le-linux-gnu/libhdf5.so && \
    ln -s /usr/lib/powerpc64le-linux-gnu/libhdf5_serial_hl.so.10 /usr/lib/powerpc64le-linux-gnu/libhdf5_hl.so && \
    pip3 --no-cache-dir  install h5py

RUN pip3 install numpy && \
    pip3 install keras && \
    cd ~ && \
    git clone https://github.com/tensorflow/tensorflow

COPY ./.tf_configure.bazelrc /root/tensorflow

ENV PATH $PATH:$HOME/bin
RUN cd ~/tensorflow && \
    git checkout r1.11 && \
    bazel build //tensorflow/tools/pip_package:build_pip_package && \
    bazel-bin/tensorflow/tools/pip_package/build_pip_package ../tensorflow_pkg && \
    cd ~/tensorflow_pkg/ && \
    pip3 install tensorflow-1.11.0-cp35-cp35m-linux_ppc64le.whl && \

#RUN apt-get install -y libblas3 liblapack3 libstdc++6 python-setuptools && \
#    pip3 install --upgrade numpy && \
##    pip3 install turicreate && \
#    pip3 install -U tensorflow-gpu==1.8
#
RUN pip3 install sympy scipy sklearn matplotlib

#COPY start-notebook.sh /usr/local/bin/
#RUN chmod +x /usr/local/bin/start-notebook.sh
#
#CMD ["start-notebook.sh"]
