



```shell
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash

wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
```



```shell
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
```



```shell
npm config set registry http://registry.npm.taobao.org

```



nvm 安装 node 速度慢



linux:

```shell
echo "export NVM_NODEJS_ORG_MIRROR=https://npm.taobao.org/mirrors/node" >> $HOME/.profile
```



windows:

编辑 nvm 目录下 settings.txt 文件

```basic
node_mirror: https://npm.taobao.org/mirrors/node/
npm_mirror: https://npm.taobao.org/mirrors/npm/
```

```shell
 npm config set registry https://registry.npmjs.org
```





npm 使用淘宝镜像

```shell
npm config set registry https://registry.npm.taobao.org
```



