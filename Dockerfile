FROM nvidia/cuda-ppc64le:9.1-cudnn7-devel-ubuntu16.04
LABEL maintainer="Evgene Ilyushin <evgene.ilyushin@gmail.com>"

RUN apt-get update && apt-get upgrade -y && \
#    apt-get -y install software-properties-common &&\
#    add-apt-repository ppa:jonathonf/python-3.6 && \
#    apt-get update && \
#    apt-get -y install python3.6 && \
#    apt-get -y install python3.6-dev && \
#    apt-get -y install python3.6-venv && \
    apt-get -y install wget && \
    wget https://bootstrap.pypa.io/get-pip.py && \
    python3.6 get-pip.py && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.5 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 2 && \
    pip3 install --upgrade pip && \
    pip3 install jupyter

RUN apt-get install -y libblas3 liblapack3 libstdc++6 python-setuptools && \
    pip3 install --upgrade numpy && \
    pip3 install turicreate && \
    pip3 install -U tensorflow==1.8

RUN pip3 install sympy scipy sklearn matplotlib

COPY start-notebook.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start-notebook.sh

CMD ["start-notebook.sh"]
