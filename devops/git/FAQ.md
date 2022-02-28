# 无法 clone github 仓库

报错如下：

> ssh: connect to host github.com port 22: Connection timed out
> fatal: Could not read from remote repository.

仓库明明存在就是不能clone到本地。

**解决方案**

编辑 `.ssh/config`文件，没有的话就新建一个：

追加如下内容：

```
Host github.com
    Hostname ssh.github.com
    Port 443
```

运行如下命令测试：

```shell
ssh -T git@github.com
```

返回：

```
Hi vinloong! You've successfully authenticated, but GitHub does not provide shell access.
```

