# 启用两步验证(2FA)保护你的SSH连接

> 双重认证（英语：Two-factor authentication，缩写为2FA），又译为双重验证、双因子认证、双因素认证、二元认证，又称两步骤验证（2-Step Verification，又译两步验证），是一种认证方法，使用两种不同的元素，合并在一起，来确认用户的身份，是多因素验证中的一个特例。

二次验证是目前比较常用的安全手段，通过设置二次验证，我们可以有效的避免账户密码可能的泄露导致的账户信息泄露，因为每次登陆前我们都需要获取一个一次性验证码，没有验证码就无法成功登陆。本文将说明如何在 Ubuntu 20.04 TLS 上使用 Google Authenticator PAM 模块进行 SSH 和 sudo 身份验证。



# 准备工作

- Ubuntu 20.04 LTS 服务器
- 二次验证 App，比如谷歌的
- SSH 权限



# 安装 PAM 模块

通过 SSH 登陆 Ubuntu 20.04 TLS 系统，使用下面命令安装 Google Authenticator PAM 模块：

```shell
$ sudo apt update && sudo apt-get install libpam-google-authenticator
```

安装好后，直接在命令行中运行 `google-authenticator`

选项说明：

- -t : 使用 TOTP 验证
- -f : 将配置保存到 `~/.google_authenticator`
- -d : 不允许重复使用以前使用的令牌
- -w 3 : 允许的令牌的窗口大小。 默认情况下，令牌每 30 秒过期一次。 窗口大小 3 允许在当前令牌之前和之后使用令牌进行身份验证以进行时钟偏移。
- -e 10 : 生成 10 个紧急备用代码
- -r 3 -R 30 : 限速，每 30 秒允许 3 次登录

更多帮助信息可以使用 `--help` 选项查看

```shell
$ google-authenticator -t -f -d -w 3 -e 10 -r 3 -R 30 


```

它会提示你是否生成基于时间的 Token，这时候根据你的喜好选择，我这里选择是，输入Y。





此时会出现一张二维码图片，我们这时候打开刚刚下载的身份验证器，点击右下角的加号，选择“扫描条形码”，然后将 SSH 窗口放大，用摄像头扫描出现的二维码，此时就会多出一个账号信息（六位数的动态码），另外记得妥善保存你的`Emergency Key`





**如果成功扫描的话就可跳过此步，如果你无法扫描二维码的话，请点击下方的“输入提供的密钥”**





账号名随便输入，不过建议取一个容易记住的名字，“您的密钥”一栏输入二维码下面跟着的那串`Your new secret key is`后面的内容，“时间选项”里面，如果你在第一步输入了Y，就选择`基于时间`，否则就选`基于计数器`，完成后点击添加。

提示`Do you want me to update your "/home/wb/.google_authenticator" file? (y/n)`，输入Y。
接下来提示你是否设置为动态码复用，以防止攻击，当然选Y。





```
Do you want to disallow multiple uses of the same authentication
token? This restricts you to one login about every 30s, but it increases
your chances to notice or even prevent man-in-the-middle attacks (y/n) y
```





接下来我个人推荐第一项选择N，第二项选Y，这样可以防止攻击。

```
By default, a new token is generated every 30 seconds by the mobile app.
In order to compensate for possible time-skew between the client and the server,
we allow an extra token before and after the current time. This allows for a
time skew of up to 30 seconds between authentication server and client. If you
experience problems with poor time synchronization, you can increase the window
from its default size of 3 permitted codes (one previous code, the current
code, the next code) to 17 permitted codes (the 8 previous codes, the current
code, and the 8 next codes). This will permit for a time skew of up to 4 minutes
between client and server.
Do you want to do so? (y/n) n

If the computer that you are logging into isn't hardened against brute-force
login attempts, you can enable rate-limiting for the authentication module.
By default, this limits attackers to no more than 3 login attempts every 30s.
Do you want to enable rate-limiting? (y/n) y
```







