两步验证是目前比较常用的安全手段，通过设置两步验证，我们可以有效的避免账户密码可能的泄露导致的账户信息泄露，因为每次登录前我们都需要获取一个一次性验证码，没有验证码就无法成功登录。所以决定在我们服务器上配置使用两步验证登录来提升一定的安全性。下面来简单介绍下如何配置使用两步验证。



# 安装配置 `Google Authenticator `

安装 Google Authenticator 

```shell
sudo apt install libpam-google-authenticator
```
初始化配置：

 ```shell
 google-authenticator -t -f -d -w 3 -e 10 -r 3 -R 30 
 ```

 ![image-20220301085819471](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202203010858593.png)

> 配置参数说明：
>
> - -t : 使用 TOTP 验证
> - -f : 将配置保存到 `~/.google_authenticator`
> - -d : 不允许重复使用以前使用的令牌
> - -w 3 : 允许的令牌的窗口大小。 默认情况下，令牌每 30 秒过期一次。 窗口大小 3 允许在当前令牌之前和之后使用令牌进行身份验证以进行时钟偏移。
> - -e 10 : 生成 10 个紧急备用代码
> - -r 3 -R 30 : 限速，每 30 秒允许 3 次登录

更多帮助信息可以使用 `--help` 选项查看。

程序运行后，将会更新配置文件，并且显示下面信息：

- 二维码，您可以使用大多数身份验证器应用程序扫描此代码。
- 一个秘密的钥匙，如果您无法扫描二维码，请在您的应用中输入此密钥。
- 初始验证码，该验证码将在30秒后失效。
- 6 个一次性使用紧急代码的列表

# 配置SSH

- 修改 SSH `pam_google_authenticator`文件，

追加`auth required pam_google_authenticator.so nullok`内容到文件中

```shell
sudo vim /etc/pam.d/sshd
echo 'auth required pam_google_authenticator.so nullok' >> 
```

禁用密码登录

```
# @include common-auth
```

保存并退出。

- 修改 SSH 配置文件:

```shell
$ sudo vim /etc/ssh/sshd_config
ChallengeResponseAuthentication yes
PasswordAuthentication no
PubkeyAuthentication yes
AuthenticationMethods publickey,keyboard-interactive
```

保存并退出

# 重启ssh

```shell
sudo systemctl restart ssh
```

# 扩展

## 配置sudo 二次验证

```shell
$ sudo vim /etc/pam.d/common-auth
... 
...
auth required pam_google_authenticator.so nullok
```

## 恢复

修改 `/etc/ssh/sshd_config`

```
# 找到并移除 ,keyboard-interactive
AuthenticationMethods publickey

# 重启ssh
sudo systemctl restart ssh
```

