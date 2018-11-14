FROM nvidia/cuda-ppc64le:9.1-cudnn7-devel-ubuntu16.04
LABEL maintainer="Eugene Ilyushin <eugene.ilyushin@gmail.com>"

RUN apt-get update && apt-get upgrade -y && \
    apt-get -y install apt-utils wget curl unzip openssl git libreadline-gplv2-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev && \
    cd ~ && wget https://www.python.org/ftp/python/3.6.7/Python-3.6.7.tgz && \
    tar xzvf Python-3.6.7.tgz && \
    cd Python-3.6.7 && \
    ./configure --enable-optimizations && \
    make && \
    make install && \
    pip3 install --upgrade pip && \
    cd ~ && rm -rf Python-3.6.7*

# Install Tensorflow
RUN apt-get install -y python-dev python-pip python-wheel python3-numpy python3-dev python3-pip python3-wheel && \
    apt-get install -y libblas-dev liblapack-dev libatlas-base-dev gfortran && \
    apt-get install -y libhdf5-10 libhdf5-serial-dev libhdf5-dev libhdf5-cpp-11 && \
    pip3 install wheel

# Install h5py
ENV CPATH="/usr/include/hdf5/serial/"
RUN find . -type f -exec sed -i -e 's^"hdf5.h"^"hdf5/serial/hdf5.h"^g' -e 's^"hdf5_hl.h"^"hdf5/serial/hdf5_hl.h"^g' '{}' \; && \
    ln -s /usr/lib/powerpc64le-linux-gnu/libhdf5_serial.so.10 /usr/lib/powerpc64le-linux-gnu/libhdf5.so && \
    ln -s /usr/lib/powerpc64le-linux-gnu/libhdf5_serial_hl.so.10 /usr/lib/powerpc64le-linux-gnu/libhdf5_hl.so && \
    pip3 --no-cache-dir  install h5py

#RUN apt-get install -y libfreetype6-dev pkg-config libpng12-dev
RUN pip3 install numpy keras pandas sklearn sympy scipy matplotlib

COPY ./tensorflow_distr/tensorflow-1.11.0-cp36-cp36m-linux_ppc64le.whl /root
RUN cd ~ && pip3 install tensorflow-1.11.0-cp36-cp36m-linux_ppc64le.whl && rm tensorflow-1.11.0-cp36-cp36m-linux_ppc64le.whl

RUN apt-get install -y build-essential libzmq3-dev
RUN pip3 install pyzmq
RUN pip3 install jupyter
RUN pip3 install requests tqdm

#RUN cd ~ && \
#    wget --quiet https://repo.anaconda.com/archive/Anaconda3-5.1.0-Linux-ppc64le.sh -O ~/anaconda.sh && \
#    /bin/bash ~/anaconda.sh -b -p /opt/conda && \
#    rm ~/anaconda.sh && \
#    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
#    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
#    echo "conda activate base" >> ~/.bashrc
#

COPY start-notebook.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start-notebook.sh

CMD ["start-notebook.sh"]