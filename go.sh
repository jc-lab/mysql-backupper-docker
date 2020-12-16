#!/bin/bash

set -e

sudo docker build --tag temp01 .
sudo docker run --rm -it -e REMOTE_USER=backupagent-k8s-etcd -e REMOTE_HOST=10.1.4.201 -e REMOTE_PATH=/tmp/backuppedfile.txt temp01 /bin/bash

