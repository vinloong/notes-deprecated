# 给你的镜像瘦身

镜像构建时，我们希望是镜像在满足我们的服务需求的前提下，体积越小越好，那么应该怎么做呢？



## 选择合适的基础镜像



 ```bash
 dragon@LWL-PC:~/images$ docker images | { head -1; grep node; }
 REPOSITORY          TAG                    IMAGE ID       CREATED         SIZE
 node                12                     fb17a1009e1c   8 days ago      918MB
 node                12-alpine              106bb94759ad   12 days ago     89.5MB
 ```

`node:12-alpine` 的镜像大小不到 `node:12` 的 1/10.

所以相同的构建使用 ``node:12-alpine` `肯定会小很多

## 使用多阶段构建







## 使用镜像瘦身工具



