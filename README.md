# datascience-docker-container-nvidia
Docker image for IBM Power8 which contain GPUs.

Contains widely used Python libraries such as:
* TensorFlow (r1.11)
* Keras
* Turicreate
* numpy               
* pandas
* sklearn
* sympy
* scipy 
* matplotlib

For using you need to perform following commands:
```
git clone https://github.com/Ilyushin/datascience-docker-container-nvidia.git
cd datascience-docker-container-nvidia
nvidia-docker build . -t ilyushin/datascience-container-nvidia:latest
nvidia-docker run -it ilyushin/datascience-container-nvidia bash
```