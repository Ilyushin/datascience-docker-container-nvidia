#!/usr/bin/env bash

cd /home
exec jupyter notebook --NotebookApp.token='' --ip=0.0.0.0 --allow-root --port=8888