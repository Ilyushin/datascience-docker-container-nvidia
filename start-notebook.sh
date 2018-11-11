#!/usr/bin/env bash

cd /root
tensorboard --logdir=./tensorboard_logs --port=7007 &
jupyter notebook --NotebookApp.token='' --ip=0.0.0.0 --allow-root --port=8888