#!/bin/bash

dir=microk8s-images

tar zxvf ${dir}.tar.gz

cd ${dir}

images=$(ls ./*.tar )

for image in ${images}
do
    echo "加载镜像： ${image}"
#    docker load < ${image}
    microk8s.ctr --namespace k8s.io image import ${image}
    echo "加载完成"
done



