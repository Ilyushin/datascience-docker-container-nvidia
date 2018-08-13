FROM nvidia/cuda-ppc64le:9.1-cudnn7-devel-ubuntu16.04
ENV POWERAI_REPO mldl-repo-local_4.0.0_ppc64el.deb

# echo nameserver 8.8.8.8 > /etc/resolve.conf && \

RUN apt-get update && apt-get install -y \
git \
wget \
ssh \
curl && \
apt-get clean

# import PowerAI repo
RUN cd /tmp && \
wget https://public.dhe.ibm.com/software/server/POWER/Linux/mldl/ubuntu/${POWERAI_REPO} && \
dpkg -i ${POWERAI_REPO} && \
rm ${POWERAI_REPO}

# install PowerAI
RUN echo nameserver 8.8.8.8 > /etc/resolve.conf && \
apt-get update && \
apt-get install -y power-mldl && \
apt-get clean
