# datascience-docker-container-nvidia
Docker image for IBM supercomputers which contain GPUs.

```
nvidia-docker run -it --env LICENSE=yes --name ilyushin -v /home/ilyyushin/container_disk:/root nvidia/cuda-ppc64le:9.1-cudnn7-devel-ubuntu16.04 bash
```