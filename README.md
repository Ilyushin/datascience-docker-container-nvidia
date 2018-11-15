# Docker image for IBM Power8 which contain GPUs.

Contains widely used Python libraries such as:
* TensorFlow (r1.11)
* Keras
* numpy               
* pandas
* sklearn
* sympy
* scipy 
* matplotlib
* requests

And for interacting with the container Jupyter was pre-installed.

For using you need to perform following commands:
```
git clone https://github.com/Ilyushin/datascience-docker-container-nvidia.git
cd datascience-docker-container-nvidia
nvidia-docker build . -t ilyushin/datascience-container-nvidia:latest
nvidia-docker run -it -d -p 8888:8888 -p 7007:7007 ilyushin/datascience-container-nvidia bash
```

**The folder "tensorflow_distr" contains prebuilt packages of TensorFlow:**
* tensorflow-1.11.0-cp36-cp36m-linux_ppc64le.whl requires:
    * Python 3.6.7 
    * GPU architectures Kepler, Maxwell, Pascal and Volta
    * CUDA 9.1
    * cuDNN 7
    

### How to build your version of TensorFlow:
1. If you need another version of CUDA and cuDNN, you should change the first line in Dockerfile.build and set appropriate version.
    Also, you should set needed parameters in **.tf_configure.bazelrc**
1. Bild an image
    ```bash
    nvidia-docker build -f Dockerfile.build -t ilyushin/datascience-container-nvidia-build:latest
    ```
2. Run the container and connect to it
    ```bash
    nvidia-docker run -it --name build-tensorflow ilyushin/datascience-container-nvidia-build:latest bash
    ```
3. Build TensorFlow
    ```bash
    cd ~/tensorflow
    bazel --bazelrc=/root/tensorflow/.tf_configure.bazelrc build -c opt //tensorflow/tools/pip_package:build_pip_package
    bazel-bin/tensorflow/tools/pip_package/build_pip_package ../tensorflow_pkg
    ``` 
4. Copy the assembled package to a local host
    ```bash
    docker cp build-tensorflow:/root/tensorflow_pkg/<package_name> ~/
    ```
5. Stop and remove the container and the image, if it needs
    ```bash
    docker stop build-tensorflow
    docker rm build-tensorflow
    docker rmi ilyushin/datascience-container-nvidia-build:latest 
    ```
    