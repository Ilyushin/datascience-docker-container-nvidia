FROM nvidia/cuda-ppc64le:9.0-cudnn7-devel-ubuntu16.04
LABEL maintainer="Eugene Ilyushin <eugene.ilyushin@gmail.com>"

RUN apt-get update && apt-get upgrade -y && \
    apt-get -y install apt-utils wget curl unzip libssl-dev openssl git && \
    wget https://www.python.org/ftp/python/3.6.7/Python-3.6.7.tgz && \
    tar xzvf Python-3.6.7.tgz && \
    cd Python-3.6.7 && \
    ./configure && \
    make && \
    make install && \
    pip3 install --upgrade pip && \
    rm -rf ~/Python-3.6.7 Python-3.6.7.tgz
#    pip3 install jupyter

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

RUN apt-get install -y libfreetype6-dev pkg-config libpng12-dev
RUN pip3 install numpy keras pandas sklearn sympy scipy matplotlib

RUN cd ~ && \
    wget https://powerci.osuosl.org/job/TensorFlow_PPC64LE_GPU_Release_Build/lastSuccessfulBuild/artifact/tensorflow_pkg/tensorflow_gpu-1.11.0-cp36-cp36m-linux_ppc64le.whl

RUN cd ~ && pip3 install tensorflow_gpu-1.11.0-cp36-cp36m-linux_ppc64le.whl

#RUN cd ~ && \
#    wget --quiet https://repo.anaconda.com/archive/Anaconda3-5.1.0-Linux-ppc64le.sh -O ~/anaconda.sh && \
#    /bin/bash ~/anaconda.sh -b -p /opt/conda && \
#    rm ~/anaconda.sh && \
#    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
#    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
#    echo "conda activate base" >> ~/.bashrc

CMD [ "/bin/bash" ]

#COPY start-notebook.sh /usr/local/bin/
#RUN chmod +x /usr/local/bin/start-notebook.sh
#
#CMD ["start-notebook.sh"]
